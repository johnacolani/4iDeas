import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app_router.dart';
import '../design_system/responsive.dart';

class HomeQrCodeSection extends StatefulWidget {
  const HomeQrCodeSection({
    super.key,
    required this.wi,
    required this.isMobile,
    required this.isTablet,
  });

  final double wi;
  final bool isMobile;
  final bool isTablet;

  @override
  State<HomeQrCodeSection> createState() => _HomeQrCodeSectionState();
}

class _HomeQrCodeSectionState extends State<HomeQrCodeSection> {
  static const String _defaultWebsiteUrl = 'https://4ideasapp.com';

  final TextEditingController _textController = TextEditingController();
  String _qrData = _defaultWebsiteUrl;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generateQrCode() {
    final value = _textController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or a URL')),
      );
      return;
    }

    setState(() => _qrData = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool alignStart = Responsive.isDesktop(context);
    final double maxWidth = widget.isMobile ? double.infinity : 1120;
    final double qrSize = widget.isMobile ? 196 : (widget.isTablet ? 216 : 232);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 16 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(widget.isMobile ? 18 : 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withValues(alpha: 0.50),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.32),
                  ),
                ),
                child: widget.isMobile
                    ? _buildStackedContent(context, qrSize, alignStart)
                    : _buildWideContent(context, qrSize, alignStart),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideContent(
    BuildContext context,
    double qrSize,
    bool alignStart,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildCopyAndForm(context, alignStart)),
        const SizedBox(width: 24),
        _buildQrPreview(qrSize),
      ],
    );
  }

  Widget _buildStackedContent(
    BuildContext context,
    double qrSize,
    bool alignStart,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCopyAndForm(context, alignStart),
        const SizedBox(height: 22),
        Center(child: _buildQrPreview(qrSize)),
      ],
    );
  }

  Widget _buildCopyAndForm(BuildContext context, bool alignStart) {
    final TextAlign textAlign = alignStart ? TextAlign.start : TextAlign.center;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment:
          alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Semantics(
          header: true,
          child: SelectableText(
            'Share 4iDeas with a QR code',
            textAlign: textAlign,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: widget.isMobile ? 22 : 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          'Generate a quick QR code for this website, a landing page, or any link you want to share with clients.',
          textAlign: textAlign,
          style: GoogleFonts.roboto(
            color: const Color(0xFFD1D5DB),
            fontSize: widget.isMobile ? 14.5 : 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            label: Transform.translate(
              offset: const Offset(0, -13),
              child: _buildTextFieldLabel(),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: _defaultWebsiteUrl,
            helperText: 'Press Enter or choose Generate QR Code.',
            hintStyle: GoogleFonts.roboto(
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
            helperStyle: GoogleFonts.roboto(
              color: const Color(0xFFD1D5DB),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.link,
              color: Color(0xFF64748B),
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFCBD5E1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF475569),
                width: 1.6,
              ),
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _generateQrCode(),
        ),
        const SizedBox(height: 14),
        _buildActions(context),
      ],
    );
  }

  Widget _buildTextFieldLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        'Text or URL',
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = <Widget>[
      SizedBox(
        width: widget.isMobile ? double.infinity : 240,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _generateQrCode,
          icon: const Icon(Icons.qr_code_2_rounded),
          label: const Text('Generate QR Code'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            side: const BorderSide(
              color: Color(0xFF64748B),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      SizedBox(
        width: widget.isMobile ? double.infinity : 240,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.qrCodeGenerator),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Open QR Page'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.72),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    ];

    if (widget.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          actions.first,
          const SizedBox(height: 12),
          actions.last,
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions,
    );
  }

  Widget _buildQrPreview(double qrSize) {
    return Semantics(
      label: 'QR code for $_qrData',
      image: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: qrSize,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: qrSize + 64),
            child: SelectableText(
              _qrData,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: const Color(0xFFD1D5DB),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
