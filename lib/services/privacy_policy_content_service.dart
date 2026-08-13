import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:four_ideas/data/privacy_policy_data.dart';

/// Firestore-backed CRUD for app privacy policies. Admin can add/update/remove
/// policies (including uploading a `.md` file) with no code changes.
class PrivacyPolicyContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'privacy_policies';

  /// Each entry is `(firestoreDocumentId, policy)`, ordered by `order`.
  Future<List<(String docId, PrivacyPolicy policy)>>
      getPoliciesWithDocIds() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        final policy = PrivacyPolicy.fromMap(doc.id, data);
        final order = (data['order'] as num?)?.toInt() ?? 0;
        return (doc.id, policy, order);
      }).toList();
      list.sort((a, b) => a.$3.compareTo(b.$3));
      return list.map((e) => (e.$1, e.$2)).toList();
    } catch (_) {
      return [];
    }
  }

  /// All policies (without doc ids), for the public list.
  Future<List<PrivacyPolicy>> getPolicies() async {
    final withIds = await getPoliciesWithDocIds();
    return withIds.map((e) => e.$2).toList();
  }

  /// Fetch a single policy by its logical [slug] (for the public detail page).
  /// Falls back to a document-id lookup so legacy rows with an empty/missing
  /// slug field still resolve.
  Future<PrivacyPolicy?> getBySlug(String slug) async {
    final target = slug.trim().toLowerCase();
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('slug', isEqualTo: target)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return PrivacyPolicy.fromMap(doc.id, doc.data());
      }
    } catch (_) {}
    // Fallback: the slug in the URL may actually be a document id.
    return getByDocId(target);
  }

  /// Return a slug unique across the collection. If [desired] is already taken
  /// by a different document, appends `-2`, `-3`, … until free.
  Future<String> _uniqueSlug(String desired, {String? excludeDocId}) async {
    var base = PrivacyPolicy.slugify(desired);
    if (base.isEmpty) base = 'policy';
    var candidate = base;
    var n = 1;
    while (true) {
      final snapshot = await _firestore
          .collection(_collection)
          .where('slug', isEqualTo: candidate)
          .get();
      final clash = snapshot.docs.any((d) => d.id != excludeDocId);
      if (!clash) return candidate;
      n += 1;
      candidate = '$base-$n';
    }
  }

  /// Get a single policy by Firestore document id (for the edit screen).
  Future<PrivacyPolicy?> getByDocId(String docId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(docId).get();
      if (doc.exists && doc.data() != null) {
        return PrivacyPolicy.fromMap(doc.id, doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  /// Add a new policy. Returns the new document id. The slug is made unique
  /// across the collection so every policy has its own URL.
  Future<String> addPolicy(PrivacyPolicy policy) async {
    final col = _firestore.collection(_collection);
    final snapshot =
        await col.orderBy('order', descending: true).limit(1).get();
    final nextOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data()['order'] as num? ?? 0).toInt() + 1;
    final slug = await _uniqueSlug(policy.slug);
    final data = policy.copyWith(slug: slug).toMap()..['order'] = nextOrder;
    final ref = await col.add(data);
    return ref.id;
  }

  /// Update an existing policy by Firestore document id. The slug is kept unique
  /// (a collision with another policy is auto-suffixed).
  Future<void> updatePolicy(String docId, PrivacyPolicy policy) async {
    final slug = await _uniqueSlug(policy.slug, excludeDocId: docId);
    await _firestore
        .collection(_collection)
        .doc(docId)
        .update(policy.copyWith(slug: slug).toMap());
  }

  /// Delete a policy by Firestore document id.
  Future<void> deletePolicy(String docId) async {
    await _firestore.collection(_collection).doc(docId).delete();
  }
}
