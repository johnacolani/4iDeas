import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:four_ideas/config/lead_capture_config.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/home_warm_colors.dart';

/// Lightweight project inquiry for the contact page—Formspree POST, no account required.
class ProjectInquiryForm extends StatefulWidget {
  const ProjectInquiryForm({super.key});

  @override
  State<ProjectInquiryForm> createState() => _ProjectInquiryFormState();
}

class _ProjectInquiryFormState extends State<ProjectInquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _description = TextEditingController();

  String? _projectType;
  String? _budgetRange;
  String? _timeline;
  bool _submitting = false;

  static const Color _fieldTextColor = HomeWarmColors.headlinePrimary;
  static const Color _fieldMutedColor = HomeWarmColors.bodyEmphasis;

  static const _projectTypes = [
    'New MVP or product',
    'Design + Flutter build',
    'Improve an existing Flutter app',
    'Firebase / backend & integrations',
    'AI-assisted product features',
    'Other / not sure yet',
  ];

  static const _budgetRanges = [
    r'Under $10k',
    r'$10k – $25k',
    r'$25k – $50k',
    r'$50k – $100k',
    r'$100k+',
    'Prefer to discuss',
  ];

  static const _timelines = [
    'ASAP / under 1 month',
    '1–3 months',
    '3–6 months',
    '6+ months',
    'Flexible',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _company.dispose();
    _description.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.roboto(
        color: _fieldMutedColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.roboto(
        color: _fieldMutedColor.withValues(alpha: 0.58),
        fontSize: 15,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: HomeWarmColors.dividerLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: HomeWarmColors.sectionAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    );
  }

  TextStyle get _fieldTextStyle => GoogleFonts.roboto(
        color: _fieldTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );

  TextStyle get _menuItemTextStyle => GoogleFonts.roboto(
        color: _fieldTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  Widget _dropdownItem(String value) {
    return Text(
      value,
      overflow: TextOverflow.ellipsis,
      style: _menuItemTextStyle,
    );
  }

  void _clearFormFields() {
    _formKey.currentState?.reset();
    _name.clear();
    _email.clear();
    _company.clear();
    _description.clear();
    setState(() {
      _projectType = null;
      _budgetRange = null;
      _timeline = null;
    });
  }

  void _showProjectSentSnackBar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF166534),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Project inquiry sent to 4iDeas. We will review it and get back to you soon.',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_projectType == null || _budgetRange == null || _timeline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select project type, budget, and timeline.',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final uri = Uri.parse(LeadCaptureConfig.projectInquiryFormspreeEndpoint);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'company': _company.text.trim().isEmpty ? '—' : _company.text.trim(),
          'project_type': _projectType,
          'budget_range': _budgetRange,
          'timeline': _timeline,
          'message': _description.text.trim(),
          '_subject': '4iDeas: project inquiry',
          'form_source': 'project_inquiry_contact_page',
        }),
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        FocusScope.of(context).unfocus();
        _clearFormFields();
        _showProjectSentSnackBar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Something went wrong. Please email info@4ideasapp.com directly.',
              style: GoogleFonts.roboto(),
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Network error. Try again or email info@4ideasapp.com.',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeWarmColors.dividerLine),
        boxShadow: [
          BoxShadow(
            color: HomeWarmColors.headlinePrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Project inquiry',
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 20 : 22,
                fontWeight: FontWeight.w800,
                color: HomeWarmColors.headlinePrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Takes about two minutes. All fields help me respond with something useful—not a generic reply.',
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 14 : 15,
                fontWeight: FontWeight.w500,
                color: HomeWarmColors.bodyEmphasis,
                height: 1.45,
              ),
            ),
            SizedBox(height: isMobile ? 18 : 22),
            TextFormField(
              controller: _name,
              style: _fieldTextStyle,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration('Name', hint: 'Jane Doe'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter your name'
                  : null,
            ),
            SizedBox(height: isMobile ? 12 : 14),
            TextFormField(
              controller: _email,
              style: _fieldTextStyle,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration('Email', hint: 'you@company.com'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: isMobile ? 12 : 14),
            TextFormField(
              controller: _company,
              style: _fieldTextStyle,
              textInputAction: TextInputAction.next,
              decoration:
                  _fieldDecoration('Company or startup name (optional)'),
            ),
            SizedBox(height: isMobile ? 12 : 14),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _projectType,
              decoration: _fieldDecoration('Project type'),
              style: _fieldTextStyle,
              dropdownColor: Colors.white,
              iconEnabledColor: HomeWarmColors.sectionAccent,
              iconDisabledColor: _fieldMutedColor,
              items: _projectTypes
                  .map((e) =>
                      DropdownMenuItem(value: e, child: _dropdownItem(e)))
                  .toList(),
              onChanged: (v) => setState(() => _projectType = v),
              hint: Text(
                'Select...',
                style: GoogleFonts.roboto(
                  color: _fieldMutedColor.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 14),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _budgetRange,
              decoration: _fieldDecoration('Budget range'),
              style: _fieldTextStyle,
              dropdownColor: Colors.white,
              iconEnabledColor: HomeWarmColors.sectionAccent,
              iconDisabledColor: _fieldMutedColor,
              items: _budgetRanges
                  .map((e) =>
                      DropdownMenuItem(value: e, child: _dropdownItem(e)))
                  .toList(),
              onChanged: (v) => setState(() => _budgetRange = v),
              hint: Text(
                'Select...',
                style: GoogleFonts.roboto(
                  color: _fieldMutedColor.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 14),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _timeline,
              decoration: _fieldDecoration('Timeline'),
              style: _fieldTextStyle,
              dropdownColor: Colors.white,
              iconEnabledColor: HomeWarmColors.sectionAccent,
              iconDisabledColor: _fieldMutedColor,
              items: _timelines
                  .map((e) =>
                      DropdownMenuItem(value: e, child: _dropdownItem(e)))
                  .toList(),
              onChanged: (v) => setState(() => _timeline = v),
              hint: Text(
                'Select...',
                style: GoogleFonts.roboto(
                  color: _fieldMutedColor.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 14),
            TextFormField(
              controller: _description,
              style: _fieldTextStyle,
              minLines: 4,
              maxLines: 8,
              decoration: _fieldDecoration(
                'What do you want to build?',
                hint: 'A few sentences on your app idea and desired outcome.',
              ),
              validator: (v) => (v == null || v.trim().length < 20)
                  ? 'Add at least a short description (20+ characters)'
                  : null,
            ),
            SizedBox(height: isMobile ? 20 : 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: HomeWarmColors.sectionAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 15 : 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    )
                  : Text(
                      'Start a Project',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              'By sending this, you agree I may reply using your email. No spam, no lists—just project conversation.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 12.5,
                color: ColorManager.textMuted,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
