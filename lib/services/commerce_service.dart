import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:four_ideas/data/commerce_data.dart';

/// Outcome of a server-verified purchase status check.
enum PurchaseState {
  /// The signed-in user owns the product.
  entitled,

  /// Stripe confirms a real, settled session for this user; the webhook has
  /// not finished writing yet.
  processing,

  /// Checkout exists but was not settled.
  unpaid,

  /// No purchase found for this user.
  none,
}

/// Result of asking the backend for a download link.
class DownloadGrant {
  const DownloadGrant({
    required this.url,
    required this.expiresAt,
    this.version,
    this.fileName,
    this.fileSizeBytes,
    this.sha256,
  });

  final String url;
  final DateTime expiresAt;
  final String? version;
  final String? fileName;
  final int? fileSizeBytes;
  final String? sha256;
}

/// Client wrapper over the trusted commerce backend.
///
/// This class deliberately holds no pricing, no discount arithmetic and no
/// entitlement logic. It asks the server and renders the answer.
class CommerceService {
  CommerceService({FirebaseFunctions? functions, FirebaseFirestore? firestore})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'us-central1'),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  static const String _products = 'products';
  static const String _entitlements = 'entitlements';
  static const String _productOrders = 'product_orders';

  static String _entitlementId(String uid, String productKey) => '${uid}__$productKey';

  /// Public product display data, including the Current release version.
  /// Falls back to truthful static defaults if the document does not exist yet.
  Future<CommerceProduct> getProduct([String productKey = kFourICadWindowsKey]) async {
    try {
      final doc = await _firestore.collection(_products).doc(productKey).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        return CommerceProduct.fromMap(doc.id, data);
      }
    } catch (_) {
      // Rules or connectivity issue — fall through to the static defaults.
    }
    return CommerceProduct.fourICadFallback();
  }

  /// Live product stream so the page reflects a newly published version without
  /// a manual refresh.
  Stream<CommerceProduct> watchProduct([String productKey = kFourICadWindowsKey]) {
    return _firestore.collection(_products).doc(productKey).snapshots().map((doc) {
      final data = doc.data();
      if (doc.exists && data != null) return CommerceProduct.fromMap(doc.id, data);
      return CommerceProduct.fourICadFallback();
    }).handleError((_) => CommerceProduct.fourICadFallback());
  }

  /// Whether the signed-in user currently owns [productKey].
  ///
  /// Reads the entitlement document, which only the webhook can write. Returns
  /// false when signed out.
  Future<bool> ownsProduct([String productKey = kFourICadWindowsKey]) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    try {
      final doc = await _firestore
          .collection(_entitlements)
          .doc(_entitlementId(uid, productKey))
          .get();
      return doc.exists && doc.data()?['active'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Live ownership stream, so the page flips from Buy to Download the moment
  /// the webhook grants entitlement.
  Stream<bool> watchOwnership([String productKey = kFourICadWindowsKey]) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream<bool>.value(false);
    return _firestore
        .collection(_entitlements)
        .doc(_entitlementId(uid, productKey))
        .snapshots()
        .map((doc) => doc.exists && doc.data()?['active'] == true)
        .handleError((_) => false);
  }

  /// The signed-in user's own purchases, newest first.
  Future<List<ProductOrder>> myOrders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const [];
    try {
      final snap = await _firestore
          .collection(_productOrders)
          .where('uid', isEqualTo: uid)
          .get();
      final orders = snap.docs.map((d) => ProductOrder.fromMap(d.id, d.data())).toList();
      orders.sort((a, b) {
        final ad = a.purchasedAt, bd = b.purchasedAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return orders;
    } catch (_) {
      return const [];
    }
  }

  /// Starts Stripe Checkout. Returns the hosted Checkout URL to redirect to.
  ///
  /// No amount is sent — the server resolves the Price.
  Future<String> createCheckoutSession([String productKey = kFourICadWindowsKey]) async {
    final result = await _functions
        .httpsCallable('createCheckoutSession')
        .call<Map<String, dynamic>>({'productKey': productKey});
    final url = result.data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw StateError('Stripe did not return a checkout URL.');
    }
    return url;
  }

  /// Server-verified purchase status for the success page.
  ///
  /// [sessionId] is passed as a lookup hint only. The backend never treats it
  /// as proof of payment.
  Future<PurchaseState> getPurchaseStatus({
    String? sessionId,
    String productKey = kFourICadWindowsKey,
  }) async {
    final result = await _functions
        .httpsCallable('getPurchaseStatus')
        .call<Map<String, dynamic>>({
      'productKey': productKey,
      if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
    });
    return switch (result.data['state'] as String?) {
      'entitled' => PurchaseState.entitled,
      'processing' => PurchaseState.processing,
      'unpaid' => PurchaseState.unpaid,
      _ => PurchaseState.none,
    };
  }

  /// Requests a short-lived authorized installer link.
  ///
  /// Throws a [FirebaseFunctionsException] with code `permission-denied` when
  /// the caller has no entitlement.
  Future<DownloadGrant> getDownloadUrl([String productKey = kFourICadWindowsKey]) async {
    final result = await _functions
        .httpsCallable('getDownloadUrl')
        .call<Map<String, dynamic>>({'productKey': productKey});
    final data = result.data;
    return DownloadGrant(
      url: data['url'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch((data['expiresAt'] as num).toInt()),
      version: data['version'] as String?,
      fileName: data['fileName'] as String?,
      fileSizeBytes: (data['fileSizeBytes'] as num?)?.toInt(),
      sha256: data['sha256'] as String?,
    );
  }
}
