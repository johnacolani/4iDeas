import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/open_source_content_service.dart';

/// Add or edit an open source item. [docId] null = add, non-null = edit.
class AdminOpenSourceEditScreen extends StatefulWidget {
  final String? docId;
  final OpenSourceItem? initialItem;

  const AdminOpenSourceEditScreen({
    super.key,
    this.docId,
    this.initialItem,
  });

  @override
  State<AdminOpenSourceEditScreen> createState() => _AdminOpenSourceEditScreenState();
}

class _AdminOpenSourceEditScreenState extends State<AdminOpenSourceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _urlController = TextEditingController();
  final _iconNameController = TextEditingController();
  bool _saving = false;
  String? _error;

  final OpenSourceContentService _service = OpenSourceContentService();

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    if (item != null) {
      _titleController.text = item.title;
      _subtitleController.text = item.subtitle;
      _urlController.text = item.url;
      _iconNameController.text = item.iconName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _urlController.dispose();
    _iconNameController.dispose();
    super.dispose();
  }

  OpenSourceItem _buildItem() {
    return OpenSourceItem(
      id: widget.docId ?? 'os-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      url: _urlController.text.trim(),
      iconName: _iconNameController.text.trim().isEmpty ? 'code' : _iconNameController.text.trim(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final item = _buildItem();
      if (widget.docId == null) {
        await _service.addItem(item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Open source item added'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await _service.updateItem(widget.docId!, item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Open source item updated'), backgroundColor: Colors.green),
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
    final isEdit = widget.docId != null;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: const Color(0xff020923),
        title: Text(
          isEdit ? 'Edit Open Source Item' : 'Add Open Source Item',
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
                          controller: _titleController,
                          label: 'Title',
                          hint: 'e.g. auto_scroll_image',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _subtitleController,
                          label: 'Subtitle',
                          hint: 'e.g. Pub.dev package',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _urlController,
                          label: 'URL',
                          hint: 'https://...',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _iconNameController,
                          label: 'Icon name (optional)',
                          hint: 'e.g. widgets_outlined, code',
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
                              : Text(
                                  isEdit ? 'Update' : 'Add',
                                  style: GoogleFonts.albertSans(fontWeight: FontWeight.w600),
                                ),
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
