import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AdminImageUploadService {
  AdminImageUploadService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  Future<String?> pickAndUploadImage({
    required String folder,
    required ImageSource source,
  }) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 2400,
    );
    if (image == null) return null;

    final bytes = await image.readAsBytes();
    final contentType = _contentTypeFor(image.name);
    final safeName = _safeFileName(image.name);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child(
          'admin_uploads/$folder/$timestamp-$safeName',
        );

    final metadata = SettableMetadata(
      contentType: contentType,
      cacheControl: 'public,max-age=3600',
    );
    final task = await ref.putData(bytes, metadata);
    return task.ref.getDownloadURL();
  }

  String _safeFileName(String raw) {
    final cleaned = raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
    if (cleaned.isEmpty || !cleaned.contains('.')) {
      return 'image.jpg';
    }
    return cleaned;
  }

  String _contentTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.svg')) return 'image/svg+xml';
    return 'image/jpeg';
  }
}
