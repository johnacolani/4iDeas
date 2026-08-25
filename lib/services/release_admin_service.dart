import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:four_ideas/data/commerce_data.dart';

enum ReleaseTarget {
  windows(
    label: 'Windows',
    productKey: kFourICadWindowsKey,
    storagePrefix: 'releases/windows',
    extensions: ['exe'],
  ),
  web(
    label: 'Web',
    productKey: kFourICadWebKey,
  ),
  linux(
    label: 'Linux',
    productKey: kFourICadLinuxKey,
    storagePrefix: 'releases/linux',
    extensions: ['appimage', 'deb', 'tar.gz'],
  ),
  ios(
    label: 'iOS',
    productKey: kFourICadIosKey,
    storeUrlLabel: 'Apple App Store URL',
  ),
  android(
    label: 'Android',
    productKey: kFourICadAndroidKey,
    storeUrlLabel: 'Google Play URL',
  ),
  macos(
    label: 'macOS',
    productKey: kFourICadMacosKey,
    storeUrlLabel: 'Mac App Store URL',
  );

  const ReleaseTarget({
    required this.label,
    required this.productKey,
    this.storagePrefix,
    this.extensions = const [],
    this.storeUrlLabel,
  });

  final String label;
  final String productKey;
  final String? storagePrefix;
  final List<String> extensions;
  final String? storeUrlLabel;

  bool get isDownloadable => this == windows || this == linux;
  bool get isStore => storeUrlLabel != null;

  String get filePrompt => this == ReleaseTarget.windows
      ? '4iCAD Setup (.exe)'
      : 'Linux package (.AppImage, .deb, or .tar.gz)';
}

/// A desktop package the admin picked but has not uploaded yet.
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

class PlatformStoreListing {
  const PlatformStoreListing({
    this.storeUrl,
    this.version,
    this.note,
    this.isPublished = false,
  });

  final String? storeUrl;
  final String? version;
  final String? note;
  final bool isPublished;
}

/// Admin operations for protected 4iCAD Windows and Linux releases.
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
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;

  static const String _releases = 'releases';

  /// Legacy Windows prefix retained for callers and existing documentation.
  static const String releasePrefix = 'releases/windows';

  /// Refuse anything larger than this before a byte is uploaded.
  static const int maxInstallerBytes = 500 * 1024 * 1024; // 500 MB

  /// Lets the admin choose a package valid for [target].
  ///
  /// Uses `withData` because Flutter Web has no file path to stream from.
  Future<PickedInstaller?> pickInstaller(ReleaseTarget target) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: target.extensions,
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Could not read the selected file.');
    }
    final lowerName = file.name.toLowerCase();
    if (!target.extensions
        .any((extension) => lowerName.endsWith('.$extension'))) {
      throw StateError('Choose ${target.filePrompt}.');
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
    required ReleaseTarget target,
    required String version,
    required void Function(double progress) onProgress,
  }) async {
    final safeVersion =
        version.trim().replaceAll(RegExp(r'[^0-9A-Za-z._-]'), '-');
    final safeName =
        installer.fileName.replaceAll(RegExp(r'[^0-9A-Za-z._-]'), '-');
    if (!target.isDownloadable || target.storagePrefix == null) {
      throw ArgumentError('Only Windows and Linux accept release files.');
    }
    final path = '${target.storagePrefix!}/$safeVersion/$safeName';

    final contentType = switch (safeName.toLowerCase()) {
      final name when name.endsWith('.exe') =>
        'application/vnd.microsoft.portable-executable',
      final name when name.endsWith('.deb') =>
        'application/vnd.debian.binary-package',
      final name when name.endsWith('.tar.gz') => 'application/gzip',
      _ => 'application/octet-stream',
    };

    final task = _storage.ref().child(path).putData(
          installer.bytes,
          SettableMetadata(
            contentType: contentType,
            cacheControl: 'private, max-age=0, no-store',
            customMetadata: {
              'version': version.trim(),
              'platform': target.name,
              'productKey': target.productKey,
            },
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

  /// Publishes or unpublishes an Apple/Google store listing. The callable is
  /// deliberately separate from release and Stripe operations.
  Future<void> setStoreListing({
    required String productKey,
    required String storeUrl,
    String? version,
    String? note,
  }) async {
    await _functions
        .httpsCallable('setPlatformStoreListing')
        .call<Map<String, dynamic>>({
      'productKey': productKey,
      'storeUrl': storeUrl.trim(),
      'storeVersion': version?.trim(),
      'platformNote': note?.trim(),
    });
  }

  Future<PlatformStoreListing> getStoreListing(String productKey) async {
    final snapshot =
        await _firestore.collection('products').doc(productKey).get();
    final data = snapshot.data();
    return PlatformStoreListing(
      storeUrl: (data?['storeUrl'] as String?)?.trim(),
      version: (data?['storeVersion'] as String?)?.trim(),
      note: (data?['platformNote'] as String?)?.trim(),
      isPublished: data?['platformStatus'] == 'store' &&
          ((data?['storeUrl'] as String?)?.trim().isNotEmpty ?? false),
    );
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
    // Do not request a Map<String, dynamic> result here. On native platforms
    // (including Windows), StandardMessageCodec decodes callable objects as
    // Map<Object?, Object?>. Asking cloud_functions to cast that map to a
    // string-keyed map makes a successful publish look like a client failure.
    final result = await _functions.httpsCallable('publishRelease').call({
      'version': version.trim(),
      'storagePath': storagePath,
      'originalFileName': originalFileName,
      'releaseNotes': releaseNotes.trim(),
      'fileSizeBytes': fileSizeBytes,
      'makeCurrent': makeCurrent,
      'productKey': productKey,
    });
    final data = result.data;
    if (data is! Map) {
      throw StateError('The publish service returned an invalid response.');
    }
    final releaseId = data['releaseId'];
    if (releaseId is! String || releaseId.isEmpty) {
      throw StateError('The publish service did not return a release id.');
    }
    return releaseId;
  }

  /// Designates an existing release as Current. Rollback and roll-forward are
  /// the same operation; no binary is ever deleted.
  Future<void> setCurrentRelease(String releaseId,
      {String productKey = kFourICadWindowsKey}) async {
    // Keep the response untyped for the same native-map compatibility reason
    // as publishRelease. This call does not need to inspect its response body.
    await _functions.httpsCallable('setCurrentRelease').call({
      'releaseId': releaseId,
      'productKey': productKey,
    });
  }

  /// Full release history, newest first. Admin-only by Firestore rules.
  Stream<List<ReleaseRecord>> watchReleases(
      {String productKey = kFourICadWindowsKey}) {
    return _firestore
        .collection(_releases)
        .where('productKey', isEqualTo: productKey)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => ReleaseRecord.fromMap(d.id, d.data())).toList();
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
