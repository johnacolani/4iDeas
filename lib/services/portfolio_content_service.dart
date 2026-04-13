import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:four_ideas/data/portfolio_data.dart';

/// Firestore-backed CRUD for portfolio content (apps, etc.). Admin can add/update/remove.
class PortfolioContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _appsCollection = 'portfolio_apps';

  /// Each entry is `(firestoreDocumentId, app)` so admin edit/delete use the real doc path
  /// when [PortfolioApp.id] in data is a logical slug.
  Future<List<(String docId, PortfolioApp app)>> getAppsWithDocIds() async {
    try {
      final snapshot = await _firestore.collection(_appsCollection).get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        final app = PortfolioApp.fromMap(doc.id, data);
        final order = (data['order'] as num?)?.toInt() ?? 0;
        return (doc.id, app, order);
      }).toList();
      list.sort((a, b) => a.$3.compareTo(b.$3));
      return list.map((e) => (e.$1, e.$2)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch all portfolio apps from Firestore. Returns empty list if none or error.
  Future<List<PortfolioApp>> getApps() async {
    final withIds = await getAppsWithDocIds();
    return withIds.map((e) => e.$2).toList();
  }

  /// Whether Firestore has any portfolio apps (so UI can prefer them over static).
  Future<bool> hasApps() async {
    try {
      final snapshot = await _firestore.collection(_appsCollection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Add a new portfolio app. Returns the new document id.
  Future<String> addApp(PortfolioApp app) async {
    final col = _firestore.collection(_appsCollection);
    final snapshot = await col.orderBy('order', descending: true).limit(1).get();
    final nextOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data()['order'] as num? ?? 0).toInt() + 1;
    final data = app.toMap()..['order'] = nextOrder;
    final ref = await col.add(data);
    return ref.id;
  }

  /// Update an existing app by Firestore document id.
  Future<void> updateApp(String docId, PortfolioApp app) async {
    await _firestore.collection(_appsCollection).doc(docId).update(app.toMap());
  }

  /// Delete an app by Firestore document id.
  Future<void> deleteApp(String docId) async {
    await _firestore.collection(_appsCollection).doc(docId).delete();
  }

  /// Get a single app by doc id (for edit screen).
  Future<PortfolioApp?> getAppById(String docId) async {
    try {
      final doc = await _firestore.collection(_appsCollection).doc(docId).get();
      if (doc.exists && doc.data() != null) {
        return PortfolioApp.fromMap(doc.id, doc.data()!);
      }
    } catch (_) {}
    return null;
  }
}
