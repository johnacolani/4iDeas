import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:four_ideas/data/contact_data.dart';

/// Firestore-backed CRUD for contact entries. Admin can add/update/remove.
class ContactContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'contact_entries';

  Future<List<ContactEntry>> getEntries() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return (doc.id, ContactEntry.fromMap(doc.id, data), (data['order'] as num?)?.toInt() ?? 0);
      }).toList();
      list.sort((a, b) => a.$3.compareTo(b.$3));
      return list.map((e) => e.$2).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasEntries() async {
    try {
      final snapshot = await _firestore.collection(_collection).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<String> addEntry(ContactEntry entry) async {
    final col = _firestore.collection(_collection);
    final snapshot = await col.orderBy('order', descending: true).limit(1).get();
    final nextOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data()['order'] as num? ?? 0).toInt() + 1;
    final data = entry.toMap()..['order'] = nextOrder;
    final ref = await col.add(data);
    return ref.id;
  }

  Future<void> updateEntry(String docId, ContactEntry entry) async {
    await _firestore.collection(_collection).doc(docId).update(entry.toMap());
  }

  Future<void> deleteEntry(String docId) async {
    await _firestore.collection(_collection).doc(docId).delete();
  }
}
