import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminFileService {
  AdminFileService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  static const siteOrigin = 'https://4ideasapp.com';

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('shared_files');

  Future<List<Map<String, dynamic>>> listFiles() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot =
          await _collection.orderBy('createdAt', descending: true).get();
    } catch (_) {
      snapshot = await _collection.get();
    }

    final items = snapshot.docs
        .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
        .toList();
    items.sort((a, b) =>
        (b['createdAt']?.toString() ?? '').compareTo(a['createdAt']?.toString() ?? ''));
    return items.map(_convertTimestamps).toList();
  }

  Future<String> uploadFile({
    required PlatformFile file,
    required String title,
    required String slug,
    required String audience,
    String description = '',
    String clientEmail = '',
    String inquiryId = '',
    String orderId = '',
    int? expiresInDays,
  }) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('The selected file could not be read.');
    }
    if (bytes.lengthInBytes > 100 * 1024 * 1024) {
      throw StateError('Files must be smaller than 100 MB.');
    }

    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw StateError('Title is required.');

    final cleanSlug = normalizeSlug(slug.isEmpty ? cleanTitle : slug);
    if (cleanSlug.isEmpty) throw StateError('Share path is required.');
    await _ensureSlugAvailable(cleanSlug);

    final doc = _collection.doc();
    final safeName = _safeFileName(file.name);
    final storagePath = 'shared_files/${doc.id}/$safeName';
    final ref = _storage.ref(storagePath);

    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(
        contentType: _contentTypeFor(file),
        customMetadata: <String, String>{
          'sharedFileId': doc.id,
          'audience': audience,
        },
      ),
    );

    final expiresAt = expiresInDays == null
        ? null
        : Timestamp.fromDate(
            DateTime.now().toUtc().add(Duration(days: expiresInDays)),
          );

    await doc.set(<String, dynamic>{
      'title': cleanTitle,
      'description': description.trim(),
      'slug': cleanSlug,
      'shareUrl': shareUrl(cleanSlug),
      'audience': audience,
      'clientEmail': clientEmail.trim(),
      'clientEmailLower': clientEmail.trim().toLowerCase(),
      'inquiryId': inquiryId.trim(),
      'orderId': orderId.trim(),
      'fileName': safeName,
      'storagePath': storagePath,
      'contentType': _contentTypeFor(file),
      'sizeBytes': bytes.lengthInBytes,
      'active': true,
      'expiresAt': expiresAt,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'accessCount': 0,
    });

    return doc.id;
  }

  Future<void> replaceFile({
    required Map<String, dynamic> item,
    required PlatformFile file,
  }) async {
    final id = item['id']?.toString() ?? '';
    if (id.isEmpty) throw StateError('Shared file id is missing.');
    final bytes = file.bytes;
    if (bytes == null) throw StateError('The selected file could not be read.');
    if (bytes.lengthInBytes > 100 * 1024 * 1024) {
      throw StateError('Files must be smaller than 100 MB.');
    }

    final safeName = _safeFileName(file.name);
    final newPath = 'shared_files/$id/$safeName';
    await _storage.ref(newPath).putData(
          Uint8List.fromList(bytes),
          SettableMetadata(
            contentType: _contentTypeFor(file),
            customMetadata: <String, String>{'sharedFileId': id},
          ),
        );

    final oldPath = item['storagePath']?.toString() ?? '';
    await _collection.doc(id).update(<String, dynamic>{
      'fileName': safeName,
      'storagePath': newPath,
      'contentType': _contentTypeFor(file),
      'sizeBytes': bytes.lengthInBytes,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (oldPath.isNotEmpty && oldPath != newPath) {
      try {
        await _storage.ref(oldPath).delete();
      } catch (_) {
        // The metadata already points at the replacement. A missing old object
        // is harmless and should not make the replacement fail.
      }
    }
  }

  Future<void> setActive(String id, bool active) {
    return _collection.doc(id).update(<String, dynamic>{
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFile(Map<String, dynamic> item) async {
    final id = item['id']?.toString() ?? '';
    final storagePath = item['storagePath']?.toString() ?? '';
    if (storagePath.isNotEmpty) {
      try {
        await _storage.ref(storagePath).delete();
      } catch (_) {
        // Continue deleting stale metadata even if the object is already gone.
      }
    }
    if (id.isNotEmpty) await _collection.doc(id).delete();
  }

  static String shareUrl(String slug) =>
      '$siteOrigin/share/${normalizeSlug(slug)}';

  static String normalizeSlug(String input) {
    var value = input.trim().toLowerCase();
    value = value.replaceAll(RegExp(r'[^a-z0-9/]+'), '-');
    value = value.replaceAll(RegExp(r'-+'), '-');
    value = value.replaceAll(RegExp(r'/+'), '/');
    value = value
        .split('/')
        .map((part) => part.replaceAll(RegExp(r'^-+|-+$'), ''))
        .where((part) => part.isNotEmpty)
        .join('/');
    return value;
  }

  Future<void> _ensureSlugAvailable(String slug) async {
    final snap =
        await _collection.where('slug', isEqualTo: slug).limit(1).get();
    if (snap.docs.isNotEmpty) {
      throw StateError(
        'That 4iDeas share path already exists. Choose another path.',
      );
    }
  }

  String _safeFileName(String input) {
    final trimmed = input.trim().isEmpty ? 'file' : input.trim();
    return trimmed.replaceAll(RegExp(r'[^A-Za-z0-9._ -]'), '_');
  }

  String _contentTypeFor(PlatformFile file) {
    switch ((file.extension ?? '').toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'zip':
        return 'application/zip';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
    }
  }

  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> item) {
    final result = <String, dynamic>{...item};
    for (final key in <String>[
      'createdAt',
      'updatedAt',
      'expiresAt',
      'lastAccessedAt',
    ]) {
      final value = result[key];
      if (value is Timestamp) {
        result[key] = value.toDate().toIso8601String();
      }
    }
    return result;
  }
}
