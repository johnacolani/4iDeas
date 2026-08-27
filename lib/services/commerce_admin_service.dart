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

enum PromotionProductScope {
  /// Works with every 4iCAD product sold through Stripe.
  all,

  /// Legacy code restricted to the original Windows Stripe product.
  windows,
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

/// How much stock one discount tier has left, as the backend counts it.
class TierStock {
  const TierStock({
    required this.percentOff,
    required this.available,
    required this.used,
    this.unusable = 0,
    this.missing = 0,
  });

  final int percentOff;

  /// Codes still spendable — the ones there are left to give away.
  final int available;

  /// Codes a customer has redeemed.
  final int used;

  /// Expired or switched off: neither stock nor evidence of a sale.
  final int unusable;

  /// How many to create to bring this tier back to target.
  final int missing;

  factory TierStock.fromMap(Map<String, dynamic> map) => TierStock(
        percentOff: (map['percentOff'] as num?)?.toInt() ?? 0,
        available: (map['available'] as num?)?.toInt() ?? 0,
        used: (map['used'] as num?)?.toInt() ?? 0,
        unusable: (map['unusable'] as num?)?.toInt() ?? 0,
        missing: (map['missing'] as num?)?.toInt() ?? 0,
      );
}

/// The promotion screen's whole picture: the codes, and the per-tier counts.
class PromotionBoard {
  const PromotionBoard({this.codes = const [], this.stock = const []});

  final List<PromotionCodeView> codes;
  final List<TierStock> stock;

  int get totalAvailable => stock.fold(0, (running, t) => running + t.available);
  int get totalUsed => stock.fold(0, (running, t) => running + t.used);
}

class PromotionCodeView {
  const PromotionCodeView({
    required this.id,
    required this.code,
    required this.active,
    this.productScope = PromotionProductScope.all,
    this.status = PromotionCodeStatus.active,
    this.percentOff,
    this.maxRedemptions,
    this.timesRedeemed = 0,
    this.expiresAt,
    this.createdAt,
    this.firstTimeOnly = false,
    this.note,
    this.issuedBy,
    this.sentTo,
    this.sentAt,
    this.redeemedBy,
  });

  final String id;
  final String code;
  final bool active;
  final PromotionProductScope productScope;
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

  /// Who the admin recorded sending it to. A label, not a restriction: anyone
  /// holding the code can spend it, which is why [redeemedBy] is worth
  /// comparing against this.
  final String? sentTo;
  final DateTime? sentAt;
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
      productScope: map['productScope'] == 'windows'
          ? PromotionProductScope.windows
          : PromotionProductScope.all,
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
      sentTo: map['sentTo'] as String?,
      sentAt: (map['sentAt'] as num?) == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch((map['sentAt'] as num).toInt()),
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

  Future<PromotionBoard> listPromotionCodes() async {
    final result =
        await _functions.httpsCallable('listPromotionCodes').call<Map<String, dynamic>>();
    final codes = (result.data['codes'] as List?) ?? const [];
    final stock = (result.data['stock'] as List?) ?? const [];
    return PromotionBoard(
      codes: codes
          .whereType<Map>()
          .map((m) => PromotionCodeView.fromMap(m.cast<String, dynamic>()))
          .toList(),
      stock: stock
          .whereType<Map>()
          .map((m) => TierStock.fromMap(m.cast<String, dynamic>()))
          .toList(),
    );
  }

  /// Brings every tier back up to five spendable codes.
  ///
  /// Idempotent — a tier that is already full is left alone — so this is safe
  /// to press whenever the stock looks low. Returns how many were created.
  Future<int> restockPromotionCodes() async {
    final result =
        await _functions.httpsCallable('restockPromotionCodes').call<Map<String, dynamic>>();
    return (result.data['created'] as num?)?.toInt() ?? 0;
  }

  /// Records who a code was sent to, so the screen can show it later beside
  /// whoever actually redeemed it.
  Future<void> assignPromotionCode({required String id, required String sentTo}) async {
    await _functions.httpsCallable('assignPromotionCode').call<Map<String, dynamic>>({
      'id': id,
      'sentTo': sentTo.trim(),
    });
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
