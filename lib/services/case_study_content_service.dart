import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:four_ideas/data/portfolio_data.dart';

/// Firestore-backed CRUD for portfolio case studies. Admin can add/update/remove.
class CaseStudyContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'portfolio_case_studies';

  Future<List<PortfolioCaseStudy>> getCaseStudies() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return (doc.id, PortfolioCaseStudy.fromMap(doc.id, data), (data['order'] as num?)?.toInt() ?? 0);
      }).toList();
      list.sort((a, b) => a.$3.compareTo(b.$3));
      return list.map((e) => e.$2).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasCaseStudies() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<String> addCaseStudy(PortfolioCaseStudy cs) async {
    final col = _firestore.collection(_collection);
    final snapshot = await col.orderBy('order', descending: true).limit(1).get();
    final nextOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data()['order'] as num? ?? 0).toInt() + 1;
    final data = cs.toMap()..['order'] = nextOrder;
    final ref = await col.add(data);
    return ref.id;
  }

  Future<void> updateCaseStudy(String docId, PortfolioCaseStudy cs) async {
    await _firestore.collection(_collection).doc(docId).update(cs.toMap());
  }

  Future<void> deleteCaseStudy(String docId) async {
    await _firestore.collection(_collection).doc(docId).delete();
  }
}
