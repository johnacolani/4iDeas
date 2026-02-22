import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
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
    super.dispose();
  }

  PortfolioApp _buildApp() {
    final id = widget.docId ?? _nameController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
    return PortfolioApp(
      id: id.isEmpty ? 'app-${DateTime.now().millisecondsSinceEpoch}' : id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath: _imagePathController.text.trim().isEmpty ? null : _imagePathController.text.trim(),
      useComingSoonPlaceholder: _useComingSoonPlaceholder,
      appStoreUrl: _appStoreUrlController.text.trim().isEmpty ? null : _appStoreUrlController.text.trim(),
      playStoreUrl: _playStoreUrlController.text.trim().isEmpty ? null : _playStoreUrlController.text.trim(),
      webUrl: _webUrlController.text.trim().isEmpty ? null : _webUrlController.text.trim(),
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: const Color(0xff020923),
        title: Text(
          isEdit ? 'Edit Portfolio App' : 'Add Portfolio App',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
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
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
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
                        controller: _appStoreUrlController,
                        label: 'App Store URL (optional)',
                        hint: 'https://apps.apple.com/...',
                      ),
                      _buildField(
                        controller: _playStoreUrlController,
                        label: 'Play Store URL (optional)',
                        hint: 'https://play.google.com/...',
                      ),
                      _buildField(
                        controller: _webUrlController,
                        label: 'Web URL (optional)',
                        hint: 'https://...',
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _useComingSoonPlaceholder,
                        onChanged: (v) => setState(() => _useComingSoonPlaceholder = v ?? false),
                        title: Text(
                          'Use "Coming Soon" placeholder (no image)',
                          style: GoogleFonts.albertSans(color: Colors.white, fontSize: bodySize),
                        ),
                        activeColor: ColorManager.orange,
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
                            : Text(isEdit ? 'Update' : 'Add', style: GoogleFonts.albertSans(fontWeight: FontWeight.w600)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.albertSans(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.albertSans(color: Colors.white70),
          hintStyle: GoogleFonts.albertSans(color: Colors.white38),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorManager.orange),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
