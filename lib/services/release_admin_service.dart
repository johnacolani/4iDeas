import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:four_ideas/data/commerce_data.dart';

/// A Windows installer the admin picked but has not uploaded yet.
class PickedInstaller {
  const PickedInstaller({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;

  int get sizeBytes => bytes.length;

  String get formattedSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = sizeBytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(value >= 100 || unit == 0 ? 0 : 1)} ${units[unit]}';
  }
}

/// Admin operations for 4iCAD Windows releases.
///
/// Uploads go to a private Storage prefix that clients cannot read; the
/// download URL is never fetched here. Publishing and rollback are delegated to
/// Cloud Functions so validation and the single-Current invariant are enforced
/// server-side rather than in the browser.
class ReleaseAdminService {
  ReleaseAdminService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  static const String _releases = 'releases';

  /// Private Storage prefix. Mirrors `RELEASE_PREFIX` in the backend.
  static const String releasePrefix = 'releases/windows';

  /// Refuse anything larger than this before a byte is uploaded.
  static const int maxInstallerBytes = 500 * 1024 * 1024; // 500 MB

  /// Lets the admin choose a `.exe`. Returns null if they cancel.
  ///
  /// Uses `withData` because Flutter Web has no file path to stream from.
  Future<PickedInstaller?> pickInstaller() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['exe'],
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Could not read the selected file.');
    }
    if (!file.name.toLowerCase().endsWith('.exe')) {
      throw StateError('Choose a Windows .exe installer.');
    }
    if (bytes.isEmpty) {
      throw StateError('That file is empty.');
    }
    if (bytes.length > maxInstallerBytes) {
      throw StateError('That installer is larger than the 500 MB limit.');
    }
    return PickedInstaller(fileName: file.name, bytes: bytes);
  }

  /// Uploads the installer to the private release prefix, reporting progress
  /// from 0.0 to 1.0. Returns the storage object path — never a download URL.
  Future<String> uploadInstaller({
    required PickedInstaller installer,
    required String version,
    required void Function(double progress) onProgress,
  }) async {
    final safeVersion = version.trim().replaceAll(RegExp(r'[^0-9A-Za-z._-]'), '-');
    final safeName = installer.fileName.replaceAll(RegExp(r'[^0-9A-Za-z._-]'), '-');
    final path = '$releasePrefix/$safeVersion/$safeName';

    final task = _storage.ref().child(path).putData(
          installer.bytes,
          SettableMetadata(
            contentType: 'application/vnd.microsoft.portable-executable',
            cacheControl: 'private, max-age=0, no-store',
            customMetadata: {'version': version.trim()},
          ),
        );

    task.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });

    await task;
    onProgress(1.0);
    return path;
  }

  /// Registers an uploaded installer as a release. The backend validates the
  /// version format, confirms the object exists and enforces uniqueness.
  Future<String> publishRelease({
    required String version,
    required String storagePath,
    required String originalFileName,
    required String releaseNotes,
    required int fileSizeBytes,
    bool makeCurrent = true,
    String productKey = kFourICadWindowsKey,
  }) async {
    final result = await _functions
        .httpsCallable('publishRelease')
        .call<Map<String, dynamic>>({
      'version': version.trim(),
      'storagePath': storagePath,
      'originalFileName': originalFileName,
      'releaseNotes': releaseNotes.trim(),
      'fileSizeBytes': fileSizeBytes,
      'makeCurrent': makeCurrent,
      'productKey': productKey,
    });
    return result.data['releaseId'] as String;
  }

  /// Designates an existing release as Current. Rollback and roll-forward are
  /// the same operation; no binary is ever deleted.
  Future<void> setCurrentRelease(String releaseId,
      {String productKey = kFourICadWindowsKey}) async {
    await _functions.httpsCallable('setCurrentRelease').call<Map<String, dynamic>>({
      'releaseId': releaseId,
      'productKey': productKey,
    });
  }

  /// Full release history, newest first. Admin-only by Firestore rules.
  Stream<List<ReleaseRecord>> watchReleases({String productKey = kFourICadWindowsKey}) {
    return _firestore
        .collection(_releases)
        .where('productKey', isEqualTo: productKey)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ReleaseRecord.fromMap(d.id, d.data())).toList();
      list.sort((a, b) {
        final ad = a.publishedAt, bd = b.publishedAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return list;
    });
  }
}
