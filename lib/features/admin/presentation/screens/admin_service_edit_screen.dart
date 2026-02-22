import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/services_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/services_content_service.dart';

/// Add or edit a service. [docId] null = add, non-null = edit.
class AdminServiceEditScreen extends StatefulWidget {
  final String? docId;
  final ServiceItem? initialItem;

  const AdminServiceEditScreen({
    super.key,
    this.docId,
    this.initialItem,
  });

  @override
  State<AdminServiceEditScreen> createState() => _AdminServiceEditScreenState();
}

class _AdminServiceEditScreenState extends State<AdminServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconNameController = TextEditingController();
  final List<TextEditingController> _detailControllers = [];
  bool _saving = false;
  String? _error;

  final ServicesContentService _service = ServicesContentService();

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    if (item != null) {
      _titleController.text = item.title;
      _subtitleController.text = item.subtitle;
      _descriptionController.text = item.description;
      _iconNameController.text = item.iconName;
      for (final d in item.details) {
        _detailControllers.add(TextEditingController(text: d));
      }
    }
    if (_detailControllers.isEmpty) {
      _detailControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _iconNameController.dispose();
    for (final c in _detailControllers) {
      c.dispose();
    }
    super.dispose();
  }

  ServiceItem _buildItem() {
    final details = _detailControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return ServiceItem(
      id: widget.docId ?? 'svc-${DateTime.now().millisecondsSinceEpoch}',
      iconName: _iconNameController.text.trim().isEmpty ? 'design_services' : _iconNameController.text.trim(),
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      description: _descriptionController.text.trim(),
      details: details,
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
        await _service.addService(item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service added'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await _service.updateService(widget.docId!, item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service updated'), backgroundColor: Colors.green),
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

  void _addDetail() {
    setState(() => _detailControllers.add(TextEditingController()));
  }

  void _removeDetail(int index) {
    if (_detailControllers.length <= 1) return;
    setState(() {
      _detailControllers[index].dispose();
      _detailControllers.removeAt(index);
    });
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
          isEdit ? 'Edit Service' : 'Add Service',
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
                          hint: 'e.g. UX Design',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _subtitleController,
                          label: 'Subtitle',
                          hint: 'e.g. User Experience Design',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Service description',
                          maxLines: 4,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _iconNameController,
                          label: 'Icon name (optional)',
                          hint: 'e.g. design_services, palette, extension',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Details (bullet points)',
                          style: GoogleFonts.albertSans(
                            color: ColorManager.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._detailControllers.asMap().entries.map((e) {
                          final i = e.key;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: e.value,
                                    style: GoogleFonts.albertSans(color: Colors.white, fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: 'Detail ${i + 1}',
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
                                ),
                                if (_detailControllers.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 24),
                                    onPressed: () => _removeDetail(i),
                                  ),
                              ],
                            ),
                          );
                        }),
                        OutlinedButton.icon(
                          onPressed: _addDetail,
                          icon: Icon(Icons.add, size: 18, color: ColorManager.orange),
                          label: Text(
                            'Add detail',
                            style: GoogleFonts.albertSans(color: ColorManager.orange, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: ColorManager.orange)),
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
