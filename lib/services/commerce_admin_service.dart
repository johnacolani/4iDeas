import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:four_ideas/data/commerce_data.dart';

/// A Stripe promotion code as reported by the backend. This is live Stripe
/// state — no discount value is stored in Firestore and then trusted.
class PromotionCodeView {
  const PromotionCodeView({
    required this.id,
    required this.code,
    required this.active,
    this.percentOff,
    this.maxRedemptions,
    this.timesRedeemed = 0,
    this.expiresAt,
    this.firstTimeOnly = false,
  });

  final String id;
  final String code;
  final bool active;
  final num? percentOff;
  final int? maxRedemptions;
  final int timesRedeemed;
  final DateTime? expiresAt;
  final bool firstTimeOnly;

  factory PromotionCodeView.fromMap(Map<String, dynamic> map) {
    final expires = (map['expiresAt'] as num?)?.toInt();
    return PromotionCodeView(
      id: map['id'] as String,
      code: map['code'] as String,
      active: map['active'] as bool? ?? false,
      percentOff: map['percentOff'] as num?,
      maxRedemptions: (map['maxRedemptions'] as num?)?.toInt(),
      timesRedeemed: (map['timesRedeemed'] as num?)?.toInt() ?? 0,
      expiresAt: expires == null ? null : DateTime.fromMillisecondsSinceEpoch(expires * 1000),
      firstTimeOnly: map['firstTimeOnly'] as bool? ?? false,
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

  /// Creates a real Stripe Coupon + Promotion Code pair.
  Future<PromotionCodeView> createPromotionCode({
    required String code,
    required int percentOff,
    int? maxRedemptions,
    DateTime? expiresAt,
    bool firstTimeOnly = false,
  }) async {
    final result =
        await _functions.httpsCallable('createPromotionCode').call<Map<String, dynamic>>({
      'code': code.trim().toUpperCase(),
      'percentOff': percentOff,
      if (maxRedemptions != null) 'maxRedemptions': maxRedemptions,
      if (expiresAt != null) 'expiresAt': expiresAt.millisecondsSinceEpoch ~/ 1000,
      'firstTimeTransactionOnly': firstTimeOnly,
    });
    return PromotionCodeView.fromMap(result.data);
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
