import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/case_study_content_service.dart';

/// Add or edit a case study. [docId] null = add, non-null = edit.
class AdminCaseStudyEditScreen extends StatefulWidget {
  final String? docId;
  final PortfolioCaseStudy? initialCaseStudy;

  const AdminCaseStudyEditScreen({
    super.key,
    this.docId,
    this.initialCaseStudy,
  });

  @override
  State<AdminCaseStudyEditScreen> createState() => _AdminCaseStudyEditScreenState();
}

class _AdminCaseStudyEditScreenState extends State<AdminCaseStudyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _overviewController = TextEditingController();
  final _designApproachController = TextEditingController();
  final List<_SectionEditing> _sections = [];
  bool _saving = false;
  String? _error;

  final CaseStudyContentService _service = CaseStudyContentService();

  @override
  void initState() {
    super.initState();
    final cs = widget.initialCaseStudy;
    if (cs != null) {
      _titleController.text = cs.title;
      _subtitleController.text = cs.subtitle;
      _overviewController.text = cs.overview;
      _designApproachController.text = cs.designApproach ?? '';
      for (final s in cs.sections) {
        _sections.add(_SectionEditing(
          title: TextEditingController(text: s.title),
          content: TextEditingController(text: s.content),
          imagePaths: TextEditingController(
            text: (s.images != null && s.images!.isNotEmpty)
                ? s.images!.map((i) => i.path).join('\n')
                : (s.imagePaths?.join('\n') ?? ''),
          ),
        ));
      }
    }
    if (_sections.isEmpty) {
      _sections.add(_SectionEditing(
        title: TextEditingController(),
        content: TextEditingController(),
        imagePaths: TextEditingController(),
      ));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _overviewController.dispose();
    _designApproachController.dispose();
    for (final s in _sections) {
      s.title.dispose();
      s.content.dispose();
      s.imagePaths.dispose();
    }
    super.dispose();
  }

  List<CaseStudySection> _buildSections() {
    return _sections.map((s) {
      final paths = s.imagePaths.text.trim().isEmpty
          ? null
          : s.imagePaths.text.trim().split(RegExp(r'\n')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return CaseStudySection(
        title: s.title.text.trim(),
        content: s.content.text.trim(),
        imagePaths: paths?.isEmpty == true ? null : paths,
        images: null,
      );
    }).toList();
  }

  PortfolioCaseStudy _buildCaseStudy() {
    return PortfolioCaseStudy(
      id: widget.docId ?? 'cs-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      overview: _overviewController.text.trim(),
      designApproach: _designApproachController.text.trim().isEmpty
          ? null
          : _designApproachController.text.trim(),
      sections: _buildSections(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final cs = _buildCaseStudy();
      if (widget.docId == null) {
        await _service.addCaseStudy(cs);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Case study added'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await _service.updateCaseStudy(widget.docId!, cs);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Case study updated'), backgroundColor: Colors.green),
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

  void _addSection() {
    setState(() {
      _sections.add(_SectionEditing(
        title: TextEditingController(),
        content: TextEditingController(),
        imagePaths: TextEditingController(),
      ));
    });
  }

  void _removeSection(int index) {
    if (_sections.length <= 1) return;
    setState(() {
      _sections[index].title.dispose();
      _sections[index].content.dispose();
      _sections[index].imagePaths.dispose();
      _sections.removeAt(index);
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
          isEdit ? 'Edit Case Study' : 'Add Case Study',
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
                    constraints: const BoxConstraints(maxWidth: 700),
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
                          hint: 'e.g. Absolute Stone Design (ASD)',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _subtitleController,
                          label: 'Subtitle',
                          hint: 'e.g. Multi-Role Operations Platform',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _overviewController,
                          label: 'Overview',
                          hint: 'Summary text for the card and detail',
                          maxLines: 5,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        _buildField(
                          controller: _designApproachController,
                          label: 'Design approach (optional)',
                          hint: 'Design principles applied...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sections',
                          style: GoogleFonts.albertSans(
                            color: ColorManager.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._sections.asMap().entries.map((e) {
                          final i = e.key;
                          final s = e.value;
                          return Card(
                            color: Colors.white.withValues(alpha: 0.06),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Section ${i + 1}',
                                          style: GoogleFonts.albertSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (_sections.length > 1)
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                          onPressed: () => _removeSection(i),
                                        ),
                                    ],
                                  ),
                                  _buildField(
                                    controller: s.title,
                                    label: 'Section title',
                                    hint: 'e.g. Problem Statement',
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                  _buildField(
                                    controller: s.content,
                                    label: 'Content',
                                    hint: 'Section body text',
                                    maxLines: 4,
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                  _buildField(
                                    controller: s.imagePaths,
                                    label: 'Image paths (one per line, optional)',
                                    hint: 'assets/images/...',
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        OutlinedButton.icon(
                          onPressed: _addSection,
                          icon: Icon(Icons.add, size: 18, color: ColorManager.orange),
                          label: Text(
                            'Add section',
                            style: GoogleFonts.albertSans(color: ColorManager.orange, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: ColorManager.orange),
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
      padding: const EdgeInsets.only(bottom: 12),
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

class _SectionEditing {
  final TextEditingController title;
  final TextEditingController content;
  final TextEditingController imagePaths;

  _SectionEditing({
    required this.title,
    required this.content,
    required this.imagePaths,
  });
}
