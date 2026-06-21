import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/case_study_content_service.dart';
import 'package:four_ideas/services/case_study_image_upload_service.dart';

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
  State<AdminCaseStudyEditScreen> createState() =>
      _AdminCaseStudyEditScreenState();
}

class _AdminCaseStudyEditScreenState extends State<AdminCaseStudyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _overviewController = TextEditingController();
  final _heroImagePathController = TextEditingController();
  final _designApproachController = TextEditingController();
  final _problemSpaceController = TextEditingController();
  final _myRoleController = TextEditingController();
  final _impactController = TextEditingController();
  final _platformsController = TextEditingController();
  final List<_SectionEditing> _sections = [];
  bool _saving = false;
  String? _error;

  /// Controllers currently running a gallery upload (so their button shows a spinner).
  final Set<TextEditingController> _uploading = {};

  final CaseStudyContentService _service = CaseStudyContentService();
  final CaseStudyImageUploadService _uploadService =
      CaseStudyImageUploadService();

  @override
  void initState() {
    super.initState();
    final cs = widget.initialCaseStudy;
    if (cs != null) {
      _titleController.text = cs.title;
      _subtitleController.text = cs.subtitle;
      _overviewController.text = cs.overview;
      final heroPaths = cs.heroImagePaths;
      if (heroPaths != null && heroPaths.isNotEmpty) {
        // Multi-image hero strip: show one path per line so it can be edited.
        _heroImagePathController.text = heroPaths.join('\n');
      } else {
        _heroImagePathController.text = cs.heroImagePath ?? '';
      }
      _designApproachController.text = cs.designApproach ?? '';
      for (final s in cs.sections) {
        final dedicated = _dedicatedSectionForTitle(s.title);
        if (dedicated == _DedicatedCaseStudySection.problemSpace) {
          _problemSpaceController.text = s.content;
          continue;
        }
        if (dedicated == _DedicatedCaseStudySection.myRole) {
          _myRoleController.text = s.content;
          continue;
        }
        if (dedicated == _DedicatedCaseStudySection.impact) {
          _impactController.text = s.content;
          continue;
        }
        if (dedicated == _DedicatedCaseStudySection.platforms) {
          _platformsController.text = s.content;
          continue;
        }
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
    _heroImagePathController.dispose();
    _designApproachController.dispose();
    _problemSpaceController.dispose();
    _myRoleController.dispose();
    _impactController.dispose();
    _platformsController.dispose();
    for (final s in _sections) {
      s.title.dispose();
      s.content.dispose();
      s.imagePaths.dispose();
    }
    super.dispose();
  }

  List<CaseStudySection> _buildSections() {
    return [
      ..._buildDedicatedSections(),
      ..._sections.map((s) {
        final title = s.title.text.trim();
        final content = s.content.text.trim();
        final imagePathsText = s.imagePaths.text.trim();
        if (title.isEmpty && content.isEmpty && imagePathsText.isEmpty) {
          return null;
        }
        final paths = s.imagePaths.text.trim().isEmpty
            ? null
            : s.imagePaths.text
                .trim()
                .split(RegExp(r'\n'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
        return CaseStudySection(
          title: title,
          content: content,
          imagePaths: paths?.isEmpty == true ? null : paths,
          images: null,
        );
      }).whereType<CaseStudySection>(),
    ];
  }

  List<CaseStudySection> _buildDedicatedSections() {
    CaseStudySection? section(String title, TextEditingController controller) {
      final content = controller.text.trim();
      if (content.isEmpty) return null;
      return CaseStudySection(title: title, content: content);
    }

    return [
      section('Problem space', _problemSpaceController),
      section('My role', _myRoleController),
      section('Impact', _impactController),
      section('Platforms', _platformsController),
    ].whereType<CaseStudySection>().toList();
  }

  _DedicatedCaseStudySection? _dedicatedSectionForTitle(String rawTitle) {
    final title = rawTitle.trim().toLowerCase();
    if (title == 'problem space' ||
        title == 'problem' ||
        title == 'the problem before the app' ||
        title == 'business problem and search intent') {
      return _DedicatedCaseStudySection.problemSpace;
    }
    if (title == 'my role' ||
        title == 'my role and responsibilities' ||
        title == 'business goal and my role' ||
        title == 'users, business goal, and my role') {
      return _DedicatedCaseStudySection.myRole;
    }
    if (title == 'impact' ||
        title == 'outcome & impact' ||
        title == 'outcome and impact' ||
        title == 'outcome and business impact') {
      return _DedicatedCaseStudySection.impact;
    }
    if (title == 'platforms' ||
        title == 'system architecture and delivery stack') {
      return _DedicatedCaseStudySection.platforms;
    }
    return null;
  }

  String? _sectionTitleValidator(_SectionEditing section, String? value) {
    final title = value?.trim() ?? '';
    final hasContent = section.content.text.trim().isNotEmpty;
    final hasImages = section.imagePaths.text.trim().isNotEmpty;
    if (title.isEmpty && (hasContent || hasImages)) return 'Required';
    return null;
  }

  String? _sectionContentValidator(_SectionEditing section, String? value) {
    final content = value?.trim() ?? '';
    final hasTitle = section.title.text.trim().isNotEmpty;
    if (content.isEmpty && hasTitle) return 'Required';
    return null;
  }

  PortfolioCaseStudy _buildCaseStudy() {
    // Hero field accepts one image path/URL per line. A single line renders as
    // the single hero; two or more render as the horizontal hero strip.
    final heroPaths = _heroImagePathController.text
        .split(RegExp(r'\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return PortfolioCaseStudy(
      id: widget.docId ?? 'cs-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      overview: _overviewController.text.trim(),
      designApproach: _designApproachController.text.trim().isEmpty
          ? null
          : _designApproachController.text.trim(),
      heroImagePath: heroPaths.isEmpty ? null : heroPaths.first,
      heroImagePaths: heroPaths.length > 1 ? heroPaths : null,
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
      if (widget.docId != null) {
        await _service.updateCaseStudy(widget.docId!, cs);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Case study updated'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } else if (widget.initialCaseStudy != null) {
        await _service.setCaseStudyWithId(widget.initialCaseStudy!.id, cs);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Case study saved to cloud'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await _service.addCaseStudy(cs);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Case study added'),
                backgroundColor: Colors.green),
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

  /// Pick image(s) from the gallery, upload to Storage, and append the resulting
  /// URLs (one per line) to [controller] without clobbering existing entries.
  Future<void> _pickAndAppendImages(TextEditingController controller) async {
    if (_uploading.contains(controller)) return;
    setState(() => _uploading.add(controller));
    try {
      final urls = await _uploadService.pickAndUploadImages();
      if (!mounted) return;
      if (urls.isNotEmpty) {
        final existing = controller.text.trim();
        controller.text =
            existing.isEmpty ? urls.join('\n') : '$existing\n${urls.join('\n')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${urls.length} image(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading.remove(controller));
    }
  }

  Widget _uploadButton(TextEditingController controller, String label) {
    final busy = _uploading.contains(controller);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: busy ? null : () => _pickAndAppendImages(controller),
          icon: busy
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library_outlined, size: 18),
          label: Text(
            busy ? 'Uploading…' : label,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: ColorManager.orange,
            side: const BorderSide(
              color: ColorManager.orange,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
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
          isEdit ? 'Edit Case Study' : 'Add Case Study',
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
                    constraints: const BoxConstraints(maxWidth: 700),
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
                        _buildField(
                          controller: _titleController,
                          label: 'Title',
                          hint: 'e.g. Absolute Stone Design (ASD)',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        _buildField(
                          controller: _subtitleController,
                          label: 'Subtitle',
                          hint: 'e.g. Multi-Role Operations Platform',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        _buildField(
                          controller: _overviewController,
                          label: 'Overview',
                          hint: 'Summary text for the card and detail',
                          maxLines: 5,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        _buildField(
                          controller: _heroImagePathController,
                          label: 'Featured card hero image(s) (optional)',
                          hint:
                              'One per line. assets/images/... or https://... — add 2+ lines for a hero image strip.',
                          maxLines: 6,
                        ),
                        _uploadButton(
                          _heroImagePathController,
                          'Upload hero image(s) from gallery',
                        ),
                        _buildField(
                          controller: _designApproachController,
                          label: 'Design approach (optional)',
                          hint: 'Design principles applied...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Case study story',
                          style: GoogleFonts.roboto(
                            color: HomeWarmColors.textInk,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildField(
                          controller: _problemSpaceController,
                          label: 'Problem space',
                          hint:
                              'What problem existed before the product, who felt it, and why it mattered.',
                          maxLines: 5,
                        ),
                        _buildField(
                          controller: _myRoleController,
                          label: 'My Role',
                          hint:
                              'Your ownership, responsibilities, decisions, and collaboration scope.',
                          maxLines: 5,
                        ),
                        _buildField(
                          controller: _impactController,
                          label: 'Impact',
                          hint:
                              'What changed after the work shipped: business, user, workflow, or product impact.',
                          maxLines: 5,
                        ),
                        _buildField(
                          controller: _platformsController,
                          label: 'Platforms',
                          hint:
                              'iOS, Android, web, desktop, Firebase, APIs, or any platform/stack context.',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Additional sections',
                          style: GoogleFonts.roboto(
                            color: HomeWarmColors.textInk,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._sections.asMap().entries.map((e) {
                          final i = e.key;
                          final s = e.value;
                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  color: HomeWarmColors.drawerBorder),
                            ),
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
                                          style: GoogleFonts.roboto(
                                            color: HomeWarmColors.textInk,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (_sections.length > 1)
                                        IconButton(
                                          icon: Icon(Icons.delete_outline,
                                              color: Colors.red, size: 22),
                                          onPressed: () => _removeSection(i),
                                        ),
                                    ],
                                  ),
                                  _buildField(
                                    controller: s.title,
                                    label: 'Section title',
                                    hint: 'e.g. Problem Statement',
                                    validator: (v) =>
                                        _sectionTitleValidator(s, v),
                                  ),
                                  _buildField(
                                    controller: s.content,
                                    label: 'Content',
                                    hint: 'Section body text',
                                    maxLines: 4,
                                    validator: (v) =>
                                        _sectionContentValidator(s, v),
                                  ),
                                  _buildField(
                                    controller: s.imagePaths,
                                    label:
                                        'Image paths (one per line; add as many as you need for e.g. Adaptive Platform)',
                                    hint:
                                        'assets/images/asd_app_adaptive/asd-001.jpg',
                                    maxLines: 12,
                                  ),
                                  _uploadButton(
                                    s.imagePaths,
                                    'Upload image(s) from gallery',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        OutlinedButton.icon(
                          onPressed: _addSection,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(
                            'Add Section',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: ColorManager.orange,
                            side: const BorderSide(
                              color: ColorManager.orange,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
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
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  isEdit ? 'Update' : 'Add',
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600),
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
    final borderRadius = BorderRadius.circular(8);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

enum _DedicatedCaseStudySection {
  problemSpace,
  myRole,
  impact,
  platforms,
}
