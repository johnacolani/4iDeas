import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/privacy_policy_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/privacy_policy_content_service.dart';

/// Public read view for a single app's privacy policy, rendered from Markdown.
///
/// Identified by the policy's unique [slug] (e.g. `4icad`) for a clean URL.
/// When navigated from the list, [initialPolicy] is passed via `extra` so the
/// exact policy renders instantly; on a deep link it is fetched by slug.
class PrivacyPolicyDetailScreen extends StatefulWidget {
  final String slug;
  final PrivacyPolicy? initialPolicy;

  const PrivacyPolicyDetailScreen({
    super.key,
    required this.slug,
    this.initialPolicy,
  });

  @override
  State<PrivacyPolicyDetailScreen> createState() =>
      _PrivacyPolicyDetailScreenState();
}

class _PrivacyPolicyDetailScreenState
    extends State<PrivacyPolicyDetailScreen> {
  final PrivacyPolicyContentService _service = PrivacyPolicyContentService();
  final ScrollController _scrollController = ScrollController();
  PrivacyPolicy? _policy;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialPolicy != null) {
      _policy = widget.initialPolicy;
      _loading = false;
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final policy = await _service.getBySlug(widget.slug);
    if (mounted) {
      setState(() {
        _policy = policy;
        _loading = false;
      });
    }
  }

  Future<void> _onLinkTap(String? href) async {
    if (href == null) return;
    final uri = Uri.tryParse(href);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final policy = _policy;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: Colors.amber),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          tooltip: 'Back',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.privacyPolicies),
        ),
        title: Text(
          policy != null ? '${policy.appName} — Privacy' : 'Privacy Policy',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 17 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: ColorManager.orange))
                : policy == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'This privacy policy is not available.',
                            style: GoogleFonts.roboto(
                                color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 24,
                            vertical: isMobile ? 16 : 24,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 760),
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 18 : 32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: MarkdownBody(
                                  data: policy.content,
                                  selectable: true,
                                  onTapLink: (text, href, title) =>
                                      _onLinkTap(href),
                                  styleSheet: _styleSheet(context, isMobile),
                                ),
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

  MarkdownStyleSheet _styleSheet(BuildContext context, bool isMobile) {
    const ink = Color(0xFF1A1A2E);
    final body = isMobile ? 15.0 : 16.0;
    return MarkdownStyleSheet(
      h1: GoogleFonts.roboto(
          fontSize: isMobile ? 24 : 30,
          fontWeight: FontWeight.bold,
          color: ink,
          height: 1.3),
      h2: GoogleFonts.roboto(
          fontSize: isMobile ? 19 : 22,
          fontWeight: FontWeight.w700,
          color: ink,
          height: 1.35),
      h3: GoogleFonts.roboto(
          fontSize: isMobile ? 16 : 18,
          fontWeight: FontWeight.w600,
          color: ink,
          height: 1.35),
      p: GoogleFonts.roboto(fontSize: body, color: ink, height: 1.55),
      listBullet:
          GoogleFonts.roboto(fontSize: body, color: ink, height: 1.55),
      a: GoogleFonts.roboto(
          fontSize: body,
          color: ColorManager.orange,
          decoration: TextDecoration.underline),
      strong: GoogleFonts.roboto(fontWeight: FontWeight.w700, color: ink),
      em: GoogleFonts.roboto(fontStyle: FontStyle.italic, color: ink),
      blockquote: GoogleFonts.roboto(
          fontSize: body, color: ink.withValues(alpha: 0.85), height: 1.5),
      blockquoteDecoration: BoxDecoration(
        color: ColorManager.orange.withValues(alpha: 0.08),
        border: Border(
            left: BorderSide(color: ColorManager.orange, width: 3)),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ink.withValues(alpha: 0.15), width: 1),
        ),
      ),
      h1Padding: const EdgeInsets.only(top: 8, bottom: 8),
      h2Padding: const EdgeInsets.only(top: 20, bottom: 6),
      h3Padding: const EdgeInsets.only(top: 14, bottom: 4),
      pPadding: const EdgeInsets.only(bottom: 6),
    );
  }
}
