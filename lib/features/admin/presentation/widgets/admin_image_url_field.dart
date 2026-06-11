import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/core/widgets/adaptive_asset_image.dart';
import 'package:four_ideas/services/admin_image_upload_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AdminImageUrlField extends StatefulWidget {
  const AdminImageUrlField({
    super.key,
    required this.controller,
    required this.label,
    required this.uploadFolder,
    this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String uploadFolder;
  final String? hint;
  final int maxLines;

  @override
  State<AdminImageUrlField> createState() => _AdminImageUrlFieldState();
}

class _AdminImageUrlFieldState extends State<AdminImageUrlField> {
  final AdminImageUploadService _uploadService = AdminImageUploadService();
  bool _uploading = false;
  String? _uploadError;

  bool get _canUseCamera {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    setState(() {
      _uploading = true;
      _uploadError = null;
    });
    try {
      final url = await _uploadService.pickAndUploadImage(
        folder: widget.uploadFolder,
        source: source,
      );
      if (!mounted) return;
      if (url != null) {
        widget.controller.text = url;
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadError = e.toString());
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  bool _isNetworkImagePath(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text.trim();
    final hasImage = value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.controller,
            maxLines: widget.maxLines,
            cursorColor: ColorManager.orange,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.roboto(
              color: HomeWarmColors.textInk,
              fontSize: 15,
              height: 1.35,
            ),
            decoration: _inputDecoration(
              label: widget.label,
              hint: widget.hint,
              suffixIcon: hasImage
                  ? IconButton(
                      tooltip: 'Clear image',
                      onPressed: _uploading
                          ? null
                          : () {
                              widget.controller.clear();
                              setState(() {});
                            },
                      icon: Icon(Icons.close, color: HomeWarmColors.eyebrowMuted),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          _buildPickerActions(),
          if (_uploadError != null) ...[
            const SizedBox(height: 8),
            Text(
              _uploadError!,
              style: GoogleFonts.roboto(
                color: const Color(0xFFB91C1C),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          if (hasImage) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: HomeWarmColors.drawerBorder),
                  ),
                  child: _isNetworkImagePath(value)
                      ? Image.network(
                          value,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _brokenPreview(),
                        )
                      : AdaptiveAssetImage(
                          value,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _brokenPreview(),
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPickerActions() {
    if (_uploading) {
      return Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            'Uploading image...',
            style: GoogleFonts.roboto(
              color: HomeWarmColors.bodyEmphasis,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final buttons = <Widget>[
      OutlinedButton.icon(
        onPressed: () => _pickAndUpload(ImageSource.gallery),
        icon: Icon(Icons.photo_library_outlined, size: 18),
        label: const Text('Gallery'),
        style: _pickerButtonStyle(),
      ),
    ];

    if (_canUseCamera) {
      buttons.insert(
        0,
        OutlinedButton.icon(
          onPressed: () => _pickAndUpload(ImageSource.camera),
          icon: Icon(Icons.photo_camera_outlined, size: 18),
          label: const Text('Camera'),
          style: _pickerButtonStyle(),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: buttons,
    );
  }

  ButtonStyle _pickerButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: ColorManager.orange,
      side: BorderSide(color: ColorManager.orange.withValues(alpha: 0.7)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w700),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    final borderRadius = BorderRadius.circular(8);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      labelStyle: GoogleFonts.roboto(
        color: HomeWarmColors.bodyEmphasis.withValues(alpha: 0.85),
        fontSize: 14,
      ),
      floatingLabelStyle: GoogleFonts.roboto(
        color: HomeWarmColors.textInk,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      hintStyle: GoogleFonts.roboto(
        color: HomeWarmColors.eyebrowMuted,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: HomeWarmColors.drawerBorder),
        borderRadius: borderRadius,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.orange, width: 2),
        borderRadius: borderRadius,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
        borderRadius: borderRadius,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        borderRadius: borderRadius,
      ),
    );
  }

  Widget _brokenPreview() {
    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: HomeWarmColors.eyebrowMuted,
        size: 36,
      ),
    );
  }
}

class AdminImageListPicker extends StatefulWidget {
  const AdminImageListPicker({
    super.key,
    required this.controller,
    required this.label,
    required this.uploadFolder,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final String uploadFolder;
  final String? helperText;

  @override
  State<AdminImageListPicker> createState() => _AdminImageListPickerState();
}

class _AdminImageListPickerState extends State<AdminImageListPicker> {
  final AdminImageUploadService _uploadService = AdminImageUploadService();
  bool _uploading = false;
  String? _uploadError;

  bool get _canUseCamera {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  List<String> get _images => widget.controller.text
      .split(RegExp(r'\n'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _pickAndUpload(ImageSource source) async {
    setState(() {
      _uploading = true;
      _uploadError = null;
    });
    try {
      final url = await _uploadService.pickAndUploadImage(
        folder: widget.uploadFolder,
        source: source,
      );
      if (!mounted) return;
      if (url != null) {
        final next = [..._images, url];
        widget.controller.text = next.join('\n');
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadError = e.toString());
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _removeAt(int index) {
    final next = [..._images]..removeAt(index);
    widget.controller.text = next.join('\n');
    setState(() {});
  }

  bool _isNetworkImagePath(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final images = _images;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: HomeWarmColors.drawerBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.roboto(
                  color: HomeWarmColors.textInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.helperText != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.helperText!,
                  style: GoogleFonts.roboto(
                    color: HomeWarmColors.bodyEmphasis.withValues(alpha: 0.75),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _buildPickerActions(),
              if (_uploadError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _uploadError!,
                  style: GoogleFonts.roboto(
                    color: const Color(0xFFB91C1C),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
              if (images.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var i = 0; i < images.length; i++)
                      _ImagePreviewTile(
                        imagePath: images[i],
                        isNetwork: _isNetworkImagePath(images[i]),
                        onRemove: () => _removeAt(i),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerActions() {
    if (_uploading) {
      return Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            'Uploading image...',
            style: GoogleFonts.roboto(
              color: HomeWarmColors.bodyEmphasis,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final buttons = <Widget>[
      OutlinedButton.icon(
        onPressed: () => _pickAndUpload(ImageSource.gallery),
        icon: const Icon(Icons.photo_library_outlined, size: 18),
        label: const Text('Gallery'),
        style: _pickerButtonStyle(),
      ),
    ];

    if (_canUseCamera) {
      buttons.insert(
        0,
        OutlinedButton.icon(
          onPressed: () => _pickAndUpload(ImageSource.camera),
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          label: const Text('Camera'),
          style: _pickerButtonStyle(),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: buttons,
    );
  }

  ButtonStyle _pickerButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: ColorManager.orange,
      side: BorderSide(color: ColorManager.orange.withValues(alpha: 0.7)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w700),
    );
  }
}

class _ImagePreviewTile extends StatelessWidget {
  const _ImagePreviewTile({
    required this.imagePath,
    required this.isNetwork,
    required this.onRemove,
  });

  final String imagePath;
  final bool isNetwork;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: HomeWarmColors.drawerBorder),
                    ),
                    child: isNetwork
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _brokenPreview(),
                          )
                        : AdaptiveAssetImage(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _brokenPreview(),
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filled(
                  tooltip: 'Remove image',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.62),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(28, 28),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brokenPreview() {
    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: HomeWarmColors.eyebrowMuted,
        size: 28,
      ),
    );
  }
}
