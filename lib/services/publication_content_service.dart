import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:four_ideas/data/portfolio_data.dart';

/// Firestore-backed CRUD for portfolio publications. Admin can add/update/remove.
class PublicationContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'portfolio_publications';

  Future<List<PortfolioPublication>> getPublications() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return (doc.id, PortfolioPublication.fromMap(doc.id, data), (data['order'] as num?)?.toInt() ?? 0);
      }).toList();
      list.sort((a, b) => a.$3.compareTo(b.$3));
      return list.map((e) => e.$2).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasPublications() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<String> addPublication(PortfolioPublication p) async {
    final col = _firestore.collection(_collection);
    final snapshot = await col.orderBy('order', descending: true).limit(1).get();
    final nextOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data()['order'] as num? ?? 0).toInt() + 1;
    final data = p.toMap()..['order'] = nextOrder;
    final ref = await col.add(data);
    return ref.id;
  }

  Future<void> updatePublication(String docId, PortfolioPublication p) async {
    await _firestore.collection(_collection).doc(docId).update(p.toMap());
  }

  Future<void> deletePublication(String docId) async {
    await _firestore.collection(_collection).doc(docId).delete();
  }
}
