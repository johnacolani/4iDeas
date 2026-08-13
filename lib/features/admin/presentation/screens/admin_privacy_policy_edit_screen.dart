import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/privacy_policy_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/privacy_policy_content_service.dart';

/// Add or edit a privacy policy. [docId] null = add, non-null = edit.
///
/// The admin can either paste Markdown into the content box or upload a `.md`
/// file, which fills the content field (and, when adding, seeds the app name).
class AdminPrivacyPolicyEditScreen extends StatefulWidget {
  final String? docId;
  final PrivacyPolicy? initialPolicy;

  const AdminPrivacyPolicyEditScreen({
    super.key,
    this.docId,
    this.initialPolicy,
  });

  @override
  State<AdminPrivacyPolicyEditScreen> createState() =>
      _AdminPrivacyPolicyEditScreenState();
}

class _AdminPrivacyPolicyEditScreenState
    extends State<AdminPrivacyPolicyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _slugController = TextEditingController();
  final _effectiveDateController = TextEditingController();
  final _lastUpdatedController = TextEditingController();
  final _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _saving = false;
  String? _error;
  String? _uploadedFileName;

  final PrivacyPolicyContentService _service = PrivacyPolicyContentService();

  @override
  void initState() {
    super.initState();
    final p = widget.initialPolicy;
    if (p != null) {
      _appNameController.text = p.appName;
      _slugController.text = p.slug;
      _effectiveDateController.text = p.effectiveDate;
      _lastUpdatedController.text = p.lastUpdated;
      _contentController.text = p.content;
    }
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _slugController.dispose();
    _effectiveDateController.dispose();
    _lastUpdatedController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickMarkdownFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['md', 'markdown', 'txt'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() => _error = 'Could not read the selected file.');
        return;
      }
      final text = utf8.decode(bytes, allowMalformed: true);
      setState(() {
        _contentController.text = text;
        _uploadedFileName = file.name;
        // Seed the app name from the filename when adding and none typed yet.
        if (widget.docId == null && _appNameController.text.trim().isEmpty) {
          final base = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
          _appNameController.text = base;
        }
        _error = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${file.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'File upload failed: $e');
    }
  }

  PrivacyPolicy _buildPolicy() {
    var slug = _slugController.text.trim();
    if (slug.isEmpty) {
      slug = PrivacyPolicy.slugify(_appNameController.text);
    } else {
      slug = PrivacyPolicy.slugify(slug);
    }
    return PrivacyPolicy(
      slug: slug,
      appName: _appNameController.text.trim(),
      effectiveDate: _effectiveDateController.text.trim(),
      lastUpdated: _lastUpdatedController.text.trim(),
      content: _contentController.text,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final policy = _buildPolicy();
    if (policy.slug.isEmpty) {
      setState(() => _error = 'App name must contain letters or numbers.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.docId == null) {
        await _service.addPolicy(policy);
      } else {
        await _service.updatePolicy(widget.docId!, policy);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.docId == null ? 'Policy added' : 'Policy updated'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isEdit = widget.docId != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: Colors.amber),
        title: Text(
          isEdit ? 'Edit Privacy Policy' : 'Add Privacy Policy',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFDC2626)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF991B1B),
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _pickMarkdownFile,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorManager.orange,
                            side:
                                const BorderSide(color: ColorManager.orange),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.upload_file),
                          label: Text(
                            _uploadedFileName == null
                                ? 'Upload Markdown (.md) file'
                                : 'Uploaded: $_uploadedFileName',
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload a .md file, or paste/edit Markdown in the box below.',
                          style: GoogleFonts.roboto(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          controller: _appNameController,
                          label: 'App name',
                          hint: 'e.g. 4iCAD',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        _buildField(
                          controller: _slugController,
                          label: 'URL slug (optional)',
                          hint: 'Leave blank to derive from app name, e.g. 4icad',
                        ),
                        _buildField(
                          controller: _effectiveDateController,
                          label: 'Effective date (optional)',
                          hint: 'e.g. August 2, 2026',
                        ),
                        _buildField(
                          controller: _lastUpdatedController,
                          label: 'Last updated (optional)',
                          hint: 'e.g. August 2, 2026',
                        ),
                        _buildField(
                          controller: _contentController,
                          label: 'Policy content (Markdown)',
                          hint: '# Privacy Policy ...',
                          maxLines: 20,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(isEdit ? 'Update' : 'Add',
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final borderRadius = BorderRadius.circular(8);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        cursorColor: ColorManager.orange,
        style: GoogleFonts.robotoMono(
          color: HomeWarmColors.textInk,
          fontSize: 14,
          height: 1.4,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          alignLabelWithHint: maxLines > 1,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HomeWarmColors.drawerBorder),
            borderRadius: borderRadius,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: ColorManager.orange, width: 2),
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
          errorStyle: GoogleFonts.roboto(
            color: const Color(0xFFB91C1C),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
