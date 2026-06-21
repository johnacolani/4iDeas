import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Picks images from the device gallery and uploads them to Firebase Storage,
/// returning their public download URLs. Used by the admin case study editor so
/// images can be added without manually pasting paths/URLs.
class CaseStudyImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Folder in the Storage bucket where case study images are stored.
  static const String _folder = 'case_study_images';

  /// Let the admin pick one or more images and upload each. Returns the
  /// download URLs in pick order. Returns an empty list if the user cancels.
  Future<List<String>> pickAndUploadImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 90);
    if (picked.isEmpty) return const [];

    final urls = <String>[];
    for (var i = 0; i < picked.length; i++) {
      final url = await _uploadXFile(picked[i], index: i);
      urls.add(url);
    }
    return urls;
  }

  Future<String> _uploadXFile(XFile file, {required int index}) async {
    final bytes = await file.readAsBytes();
    final ref = _storage.ref().child('$_folder/${_uniqueName(file, index)}');
    final metadata = SettableMetadata(
      contentType: _contentTypeFor(file),
    );
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }

  /// Timestamp-prefixed name so concurrent uploads in one pick don't collide.
  String _uniqueName(XFile file, int index) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final safe = file.name.isEmpty
        ? 'image_$index'
        : file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return '${stamp}_${index}_$safe';
  }

  String? _contentTypeFor(XFile file) {
    final mime = file.mimeType;
    if (mime != null && mime.isNotEmpty) return mime;
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    return null;
  }
}
