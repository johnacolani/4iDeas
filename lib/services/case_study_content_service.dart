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
        return (
          doc.id,
          PortfolioCaseStudy.fromMap(doc.id, data),
          (data['order'] as num?)?.toInt() ?? 0
        );
      }).toList();
      list.sort((a, b) => a.$3.compareTo(b.$3));
      return list.map((e) => e.$2).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch a single case study by its Firestore document id. Returns null if it
  /// doesn't exist (e.g. a static-only case study) or on error.
  Future<PortfolioCaseStudy?> getCaseStudyById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return PortfolioCaseStudy.fromMap(doc.id, data);
    } catch (_) {
      return null;
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
    final snapshot = await col.orderBy('order').limit(1).get();
    final firestoreMinOrder = snapshot.docs.isEmpty
        ? null
        : (snapshot.docs.first.data()['order'] as num? ?? 0).toInt();
    final staticMinOrder = PortfolioData.caseStudies
        .map((caseStudy) => caseStudy.order)
        .fold<int?>(
            null, (min, order) => min == null || order < min ? order : min);
    final candidates = [
      if (firestoreMinOrder != null) firestoreMinOrder,
      if (staticMinOrder != null) staticMinOrder,
    ];
    final firstOrder =
        candidates.isEmpty ? 0 : candidates.reduce((a, b) => a < b ? a : b) - 1;
    final data = cs.toMap()..['order'] = firstOrder;
    final ref = await col.add(data);
    return ref.id;
  }

  /// Set a case study with a specific document id (e.g. 'asd'). Use when editing
  /// a case study that was from static data so it can be updated in Firestore.
  Future<void> setCaseStudyWithId(String docId, PortfolioCaseStudy cs) async {
    final col = _firestore.collection(_collection);
    final doc = col.doc(docId);
    final snapshot = await doc.get();
    final data = cs.toMap();
    if (!snapshot.exists) {
      final orderSnapshot =
          await col.orderBy('order', descending: true).limit(1).get();
      data['order'] = orderSnapshot.docs.isEmpty
          ? 0
          : (orderSnapshot.docs.first.data()['order'] as num? ?? 0).toInt() + 1;
    } else {
      data['order'] = snapshot.data()?['order'] ?? 0;
    }
    await doc.set(data);
  }

  Future<void> updateCaseStudy(String docId, PortfolioCaseStudy cs) async {
    await _firestore.collection(_collection).doc(docId).update(cs.toMap());
  }

  Future<void> deleteCaseStudy(String docId) async {
    await _firestore.collection(_collection).doc(docId).delete();
  }
}
