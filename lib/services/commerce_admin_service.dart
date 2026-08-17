import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:four_ideas/data/commerce_data.dart';

/// A Stripe promotion code as reported by the backend. This is live Stripe
/// state — no discount value is stored in Firestore and then trusted.
/// Where a promotion code stands. Decided by the backend from live Stripe
/// state, never stored — a status written into our own database could disagree
/// with the only system that actually accepts or refuses a code.
enum PromotionCodeStatus {
  /// Still spendable.
  active,

  /// Every redemption has been spent. For a single-use code, someone used it.
  used,

  /// Past its expiry date.
  expired,

  /// Switched off by an admin.
  disabled,
}

/// Who spent a code, joined from the order the webhook wrote.
class PromotionRedemption {
  const PromotionRedemption({
    this.email,
    this.uid,
    this.sessionId,
    this.amountPaid,
    this.amountDiscount,
    this.currency,
    this.at,
  });

  final String? email;
  final String? uid;
  final String? sessionId;
  final int? amountPaid;
  final int? amountDiscount;
  final String? currency;
  final DateTime? at;

  static PromotionRedemption? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final at = (map['at'] as num?)?.toInt();
    return PromotionRedemption(
      email: map['email'] as String?,
      uid: map['uid'] as String?,
      sessionId: map['sessionId'] as String?,
      amountPaid: (map['amountPaid'] as num?)?.toInt(),
      amountDiscount: (map['amountDiscount'] as num?)?.toInt(),
      currency: map['currency'] as String?,
      at: at == null ? null : DateTime.fromMillisecondsSinceEpoch(at),
    );
  }
}

class PromotionCodeView {
  const PromotionCodeView({
    required this.id,
    required this.code,
    required this.active,
    this.status = PromotionCodeStatus.active,
    this.percentOff,
    this.maxRedemptions,
    this.timesRedeemed = 0,
    this.expiresAt,
    this.createdAt,
    this.firstTimeOnly = false,
    this.note,
    this.issuedBy,
    this.redeemedBy,
  });

  final String id;
  final String code;
  final bool active;
  final PromotionCodeStatus status;
  final num? percentOff;
  final int? maxRedemptions;
  final int timesRedeemed;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final bool firstTimeOnly;

  /// Free-text label the admin attached when generating it — typically who it
  /// is meant for.
  final String? note;
  final String? issuedBy;
  final PromotionRedemption? redeemedBy;

  /// True once the code can no longer be spent, for any reason.
  bool get isSpent => status != PromotionCodeStatus.active;

  /// A single-use code that someone has redeemed — the case the admin screen
  /// exists to show.
  bool get isUsed => status == PromotionCodeStatus.used;

  factory PromotionCodeView.fromMap(Map<String, dynamic> map) {
    final expires = (map['expiresAt'] as num?)?.toInt();
    final created = (map['createdAt'] as num?)?.toInt();
    return PromotionCodeView(
      id: map['id'] as String,
      code: map['code'] as String,
      active: map['active'] as bool? ?? false,
      status: switch (map['status'] as String?) {
        'used' => PromotionCodeStatus.used,
        'expired' => PromotionCodeStatus.expired,
        'disabled' => PromotionCodeStatus.disabled,
        _ => PromotionCodeStatus.active,
      },
      percentOff: map['percentOff'] as num?,
      maxRedemptions: (map['maxRedemptions'] as num?)?.toInt(),
      timesRedeemed: (map['timesRedeemed'] as num?)?.toInt() ?? 0,
      expiresAt: expires == null ? null : DateTime.fromMillisecondsSinceEpoch(expires * 1000),
      createdAt: created == null ? null : DateTime.fromMillisecondsSinceEpoch(created),
      firstTimeOnly: map['firstTimeOnly'] as bool? ?? false,
      note: map['note'] as String?,
      issuedBy: map['issuedBy'] as String?,
      redeemedBy: PromotionRedemption.fromMap(
        (map['redeemedBy'] as Map?)?.cast<String, dynamic>(),
      ),
    );
  }
}

/// Admin views over commerce data.
///
/// Orders are read-only here by design: payment truth belongs to Stripe and the
/// webhook, and Firestore rules forbid client writes to order documents.
class CommerceAdminService {
  CommerceAdminService({FirebaseFirestore? firestore, FirebaseFunctions? functions})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  static const String _productOrders = 'product_orders';
  static const String _entitlements = 'entitlements';

  /// All product orders, newest first.
  Stream<List<ProductOrder>> watchOrders() {
    return _firestore.collection(_productOrders).snapshots().map((snap) {
      final list = snap.docs.map((d) => ProductOrder.fromMap(d.id, d.data())).toList();
      list.sort((a, b) {
        final ad = a.purchasedAt, bd = b.purchasedAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  /// Whether a given buyer still holds an active entitlement, so the admin can
  /// see order and access state side by side.
  Future<bool> entitlementActive(String uid, String productKey) async {
    try {
      final doc = await _firestore.collection(_entitlements).doc('${uid}__$productKey').get();
      return doc.exists && doc.data()?['active'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<PromotionCodeView>> listPromotionCodes() async {
    final result =
        await _functions.httpsCallable('listPromotionCodes').call<Map<String, dynamic>>();
    final codes = (result.data['codes'] as List?) ?? const [];
    return codes
        .whereType<Map>()
        .map((m) => PromotionCodeView.fromMap(m.cast<String, dynamic>()))
        .toList();
  }

  /// Creates real Stripe Coupon + Promotion Code pairs.
  ///
  /// Leave [code] blank to have the backend generate unique codes — that is how
  /// a stock of hand-out codes is minted. Pass one to name it yourself, in
  /// which case [count] must be 1.
  Future<List<PromotionCodeView>> createPromotionCodes({
    required int percentOff,
    String? code,
    int count = 1,
    int? maxRedemptions,
    DateTime? expiresAt,
    bool firstTimeOnly = false,
    String? note,
  }) async {
    final named = code?.trim().toUpperCase() ?? '';
    final result =
        await _functions.httpsCallable('createPromotionCode').call<Map<String, dynamic>>({
      if (named.isNotEmpty) 'code': named,
      'percentOff': percentOff,
      'count': count,
      if (maxRedemptions != null) 'maxRedemptions': maxRedemptions,
      if (expiresAt != null) 'expiresAt': expiresAt.millisecondsSinceEpoch ~/ 1000,
      'firstTimeTransactionOnly': firstTimeOnly,
      if ((note ?? '').trim().isNotEmpty) 'note': note!.trim(),
    });
    final codes = (result.data['codes'] as List?) ?? const [];
    return codes
        .whereType<Map>()
        .map((m) => PromotionCodeView.fromMap(m.cast<String, dynamic>()))
        .toList();
  }

  Future<void> setPromotionCodeActive(String id, bool active) async {
    await _functions.httpsCallable('setPromotionCodeActive').call<Map<String, dynamic>>({
      'id': id,
      'active': active,
    });
  }

  /// One-time migration helper: mints the caller's own `admin: true` claim if
  /// their verified email is on the backend's legacy allowlist.
  Future<Map<String, dynamic>> bootstrapAdminClaim() async {
    final result =
        await _functions.httpsCallable('bootstrapAdminClaim').call<Map<String, dynamic>>();
    return result.data;
  }
}
