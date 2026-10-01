import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectInquiryService {
  ProjectInquiryService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('project_inquiries');

  Future<String> submitPublicInquiry({
    required String name,
    required String email,
    String? company,
    required String projectType,
    required String budgetRange,
    required String timeline,
    required String message,
    String source = 'project_inquiry_contact_page',
  }) async {
    final callable = _functions.httpsCallable('submitProjectInquiry');
    final result = await callable.call(<String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'company': company?.trim() ?? '',
      'projectType': projectType,
      'budgetRange': budgetRange,
      'timeline': timeline,
      'message': message.trim(),
      'source': source,
      'website': '',
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    final inquiryId = data['inquiryId']?.toString();
    if (inquiryId == null || inquiryId.isEmpty) {
      throw StateError('Inquiry was accepted without an inquiry id.');
    }
    return inquiryId;
  }

  Future<List<Map<String, dynamic>>> getAdminInquiries() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot =
          await _collection.orderBy('createdAt', descending: true).get();
    } catch (_) {
      snapshot = await _collection.get();
    }

    final items = snapshot.docs.map(_mapDoc).toList();
    items.sort(_compareCreatedAtDescending);
    return items;
  }

  Future<List<Map<String, dynamic>>> getMyInquiriesOnce() async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) return const [];

    final claim = _functions.httpsCallable('claimMyProjectInquiries');
    await claim.call();

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _collection
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
    } catch (_) {
      snapshot =
          await _collection.where('userId', isEqualTo: user.uid).get();
    }

    final items = snapshot.docs.map(_mapDoc).toList();
    items.sort(_compareCreatedAtDescending);
    return items;
  }

  Future<void> createImportedInquiry({
    required String name,
    required String email,
    String? company,
    required String projectType,
    required String budgetRange,
    required String timeline,
    required String message,
    String source = 'admin_manual_import',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    await _collection.add(<String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'emailLower': normalizedEmail,
      'company':
          company == null || company.trim().isEmpty ? '—' : company.trim(),
      'projectType': projectType.trim(),
      'budgetRange': budgetRange.trim(),
      'timeline': timeline.trim(),
      'message': message.trim(),
      'source': source,
      'status': 'new',
      'adminReply': '',
      'adminNotes': '',
      'clientReply': '',
      'userId': null,
      'linkedOrderId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAdminInquiry({
    required String inquiryId,
    required String status,
    required String adminReply,
    required String adminNotes,
  }) {
    return _collection.doc(inquiryId).update(<String, dynamic>{
      'status': status,
      'adminReply': adminReply.trim(),
      'adminNotes': adminNotes.trim(),
      'adminRepliedAt':
          adminReply.trim().isEmpty ? null : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> sendAdminResponse({
    required String inquiryId,
    required String response,
    String adminNotes = '',
  }) async {
    final callable =
        _functions.httpsCallable('sendProjectInquiryResponse');
    final result = await callable.call(<String, dynamic>{
      'inquiryId': inquiryId,
      'response': response.trim(),
      'adminNotes': adminNotes.trim(),
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> addClientReply({
    required String inquiryId,
    required String response,
  }) {
    return _collection.doc(inquiryId).update(<String, dynamic>{
      'clientReply': response.trim(),
      'clientReplyDate': FieldValue.serverTimestamp(),
      'status': 'client_replied',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> convertInquiryToProject(String inquiryId) async {
    final callable =
        _functions.httpsCallable('convertProjectInquiryToOrder');
    final result = await callable.call(<String, dynamic>{
      'inquiryId': inquiryId,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    final orderId = data['orderId']?.toString();
    if (orderId == null || orderId.isEmpty) {
      throw StateError('Conversion completed without an order id.');
    }
    return orderId;
  }

  Map<String, dynamic> _mapDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = <String, dynamic>{...doc.data(), 'id': doc.id};
    for (final key in <String>[
      'createdAt',
      'updatedAt',
      'adminRepliedAt',
      'clientReplyDate',
      'claimedAt',
      'convertedAt',
    ]) {
      final value = data[key];
      if (value is Timestamp) {
        data[key] = value.toDate().toIso8601String();
      }
    }
    return data;
  }

  int _compareCreatedAtDescending(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final av = a['createdAt']?.toString() ?? '';
    final bv = b['createdAt']?.toString() ?? '';
    return bv.compareTo(av);
  }
}
