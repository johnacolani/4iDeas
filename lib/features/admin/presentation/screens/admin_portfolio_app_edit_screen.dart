import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/portfolio_content_service.dart';

/// Add or edit a portfolio app. [docId] null = add, non-null = edit.
class AdminPortfolioAppEditScreen extends StatefulWidget {
  final String? docId;
  final PortfolioApp? initialApp;

  const AdminPortfolioAppEditScreen({
    super.key,
    this.docId,
    this.initialApp,
  });

  @override
  State<AdminPortfolioAppEditScreen> createState() => _AdminPortfolioAppEditScreenState();
}

class _AdminPortfolioAppEditScreenState extends State<AdminPortfolioAppEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePathController = TextEditingController();
  final _appStoreUrlController = TextEditingController();
  final _playStoreUrlController = TextEditingController();
  final _webUrlController = TextEditingController();
  final _macosUrlController = TextEditingController();
  final _windowsUrlController = TextEditingController();
  bool _useComingSoonPlaceholder = false;
  bool _saving = false;
  String? _error;

  final PortfolioContentService _service = PortfolioContentService();

  @override
  void initState() {
    super.initState();
    final app = widget.initialApp;
    if (app != null) {
      _nameController.text = app.name;
      _descriptionController.text = app.description;
      _imagePathController.text = app.imagePath ?? '';
      _appStoreUrlController.text = app.appStoreUrl ?? '';
      _playStoreUrlController.text = app.playStoreUrl ?? '';
      _webUrlController.text = app.webUrl ?? '';
      _macosUrlController.text = app.macosUrl ?? '';
      _windowsUrlController.text = app.windowsUrl ?? '';
      _useComingSoonPlaceholder = app.useComingSoonPlaceholder;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imagePathController.dispose();
    _appStoreUrlController.dispose();
    _playStoreUrlController.dispose();
    _webUrlController.dispose();
    _macosUrlController.dispose();
    _windowsUrlController.dispose();
    super.dispose();
  }

  /// Logical id for [PortfolioApp.id] / merge keys — never the Firestore document id.
  String _logicalPortfolioAppId() {
    final fromInitial = widget.initialApp?.id.trim();
    if (fromInitial != null && fromInitial.isNotEmpty) return fromInitial;
    return _nameController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
  }

  PortfolioApp _buildApp() {
    final idRaw = _logicalPortfolioAppId();
    final id = idRaw.isEmpty ? 'app-${DateTime.now().millisecondsSinceEpoch}' : idRaw;
    return PortfolioApp(
      id: id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath: _imagePathController.text.trim().isEmpty ? null : _imagePathController.text.trim(),
      useComingSoonPlaceholder: _useComingSoonPlaceholder,
      showComingSoonOverlay: widget.initialApp?.showComingSoonOverlay ?? false,
      appStoreUrl: _appStoreUrlController.text.trim().isEmpty ? null : _appStoreUrlController.text.trim(),
      playStoreUrl: _playStoreUrlController.text.trim().isEmpty ? null : _playStoreUrlController.text.trim(),
      webUrl: _webUrlController.text.trim().isEmpty ? null : _webUrlController.text.trim(),
      macosUrl: _macosUrlController.text.trim().isEmpty ? null : _macosUrlController.text.trim(),
      windowsUrl: _windowsUrlController.text.trim().isEmpty ? null : _windowsUrlController.text.trim(),
      caseStudyId: widget.initialApp?.caseStudyId,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final app = _buildApp();
      if (widget.docId == null) {
        await _service.addApp(app);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('App added'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await _service.updateApp(widget.docId!, app);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('App updated'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
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
    final bodySize = isMobile ? 15.0 : 16.0;
    final isEdit = widget.docId != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: Colors.amber),
        title: Text(
          isEdit ? 'Edit Portfolio App' : 'Add Portfolio App',
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
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
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
                              color: const Color(0xFFDC2626).withValues(alpha: 0.35),
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
                      _buildField(
                        controller: _nameController,
                        label: 'App name',
                        hint: 'e.g. 4iDeas - Portfolio Website',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Short description for portfolio card',
                        maxLines: 3,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      _buildField(
                        controller: _imagePathController,
                        label: 'Image path (optional)',
                        hint: 'e.g. assets/images/app_store/my-web-site-01.png',
                      ),
                      _buildField(
                        controller: _webUrlController,
                        label: 'Web URL (optional)',
                        hint: 'https://...',
                      ),
                      _buildField(
                        controller: _macosUrlController,
                        label: 'macOS URL (optional)',
                        hint: 'Mac App Store, .dmg, GitHub Release, or hosted download',
                      ),
                      _buildField(
                        controller: _windowsUrlController,
                        label: 'Windows URL (optional)',
                        hint: 'Microsoft Store, .exe/.msix, or hosted download',
                      ),
                      _buildField(
                        controller: _appStoreUrlController,
                        label: 'App Store URL (optional)',
                        hint: 'https://apps.apple.com/...',
                      ),
                      _buildField(
                        controller: _playStoreUrlController,
                        label: 'Google Play URL (optional)',
                        hint: 'https://play.google.com/...',
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _useComingSoonPlaceholder,
                        onChanged: (v) => setState(() => _useComingSoonPlaceholder = v ?? false),
                        checkColor: Colors.white,
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return ColorManager.orange;
                          }
                          return Colors.transparent;
                        }),
                        side: BorderSide(
                          color: HomeWarmColors.drawerBorder,
                          width: 1.5,
                        ),
                        title: Text(
                          'Use "Coming Soon" placeholder (no image)',
                          style: GoogleFonts.roboto(
                            color: HomeWarmColors.textInk,
                            fontSize: bodySize,
                          ),
                        ),
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
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEdit ? 'Update' : 'Add', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
                      ),
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
        style: GoogleFonts.roboto(
          color: HomeWarmColors.textInk,
          fontSize: 15,
          height: 1.35,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
          errorStyle: GoogleFonts.roboto(
            color: const Color(0xFFB91C1C),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
