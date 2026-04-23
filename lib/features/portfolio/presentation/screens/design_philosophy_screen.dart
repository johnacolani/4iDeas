import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:go_router/go_router.dart';

const List<Color> _kPhilosophyTextGradient = <Color>[
  Color(0xFFFFF4B5),
  Color(0xFFF5B32F),
  Color(0xFFD89A1C),
];

BoxDecoration _grayFrostedCardDecoration({double borderRadius = 12}) {
  return BoxDecoration(
    color: const Color(0xFF6B7280).withValues(alpha: 0.18),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.24),
      width: 1.0,
    ),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.14),
        const Color(0xFF9CA3AF).withValues(alpha: 0.10),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ),
  );
}

TextStyle _philosophyGradientStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w700,
  double height = 1.3,
  double letterSpacing = 0.2,
}) {
  return GoogleFonts.albertSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    foreground: Paint()
      ..shader = const LinearGradient(
        colors: _kPhilosophyTextGradient,
      ).createShader(const Rect.fromLTWH(0, 0, 520, 40)),
  );
}

Widget _principleItem(double bodySize, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: SelectableText(
      '• $text',
      style: GoogleFonts.albertSans(
        color: Colors.white,
        fontSize: bodySize,
        height: 1.45,
      ),
    ),
  );
}

Widget _frameworkItem(
    double bodySize, double he, String name, String description,
    {Widget? descriptionChild}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: _grayFrostedCardDecoration(borderRadius: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          name,
          style: _philosophyGradientStyle(
            fontSize: bodySize + 1,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6),
        if (descriptionChild != null)
          descriptionChild
        else
          SelectableText(
            description,
            style: GoogleFonts.albertSans(
              color: Colors.white,
              fontSize: bodySize,
              height: 1.5,
            ),
          ),
      ],
    ),
  );
}

const double _circleMethodIndent = 32; // 2 tabs

Widget _circleMethodDescription(double bodySize) {
  final baseStyle = GoogleFonts.albertSans(
    color: Colors.white,
    fontSize: bodySize,
    height: 1.5,
  );
  final boldStyle = _philosophyGradientStyle(
    fontSize: bodySize,
    height: 1.5,
    fontWeight: FontWeight.bold,
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
        child: SelectableText.rich(TextSpan(style: baseStyle, children: [
          TextSpan(text: 'Comprehend', style: boldStyle),
          const TextSpan(text: ' (goal, users, constraints)')
        ])),
      ),
      Padding(
        padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
        child: SelectableText.rich(TextSpan(style: baseStyle, children: [
          const TextSpan(text: '→ '),
          TextSpan(text: 'Identify Users', style: boldStyle),
          const TextSpan(text: ' (segment by behavior, demographics, context)')
        ])),
      ),
      Padding(
        padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
        child: SelectableText.rich(TextSpan(style: baseStyle, children: [
          const TextSpan(text: '→ '),
          TextSpan(text: 'Report User Needs', style: boldStyle)
        ])),
      ),
      Padding(
        padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
        child: SelectableText.rich(TextSpan(style: baseStyle, children: [
          const TextSpan(text: '→ '),
          TextSpan(text: 'Cut and Prioritize', style: boldStyle),
          const TextSpan(text: ' (personas)')
        ])),
      ),
      Padding(
        padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
        child: SelectableText.rich(TextSpan(style: baseStyle, children: [
          const TextSpan(text: '→ '),
          TextSpan(text: 'List Solutions', style: boldStyle),
          const TextSpan(text: ' (safe, ambitious, visionary)')
        ])),
      ),
      Padding(
        padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
        child: SelectableText.rich(TextSpan(style: baseStyle, children: [
          const TextSpan(text: '→ '),
          TextSpan(text: 'Evaluate Trade-offs', style: boldStyle)
        ])),
      ),
      Padding(
        padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
        child: SelectableText.rich(TextSpan(style: baseStyle, children: [
          const TextSpan(text: '→ '),
          TextSpan(text: 'Recommend', style: boldStyle),
          const TextSpan(text: '.')
        ])),
      ),
    ],
  );
}

Widget _starDescription(double bodySize) {
  final baseStyle = GoogleFonts.albertSans(
      color: Colors.white, fontSize: bodySize, height: 1.5);
  final boldStyle = _philosophyGradientStyle(
      fontSize: bodySize, fontWeight: FontWeight.bold, height: 1.5);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Situation', style: boldStyle),
            const TextSpan(text: ' (context, problem, constraints)')
          ]))),
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Task', style: boldStyle),
            const TextSpan(text: ' (role, goals, KPIs)')
          ]))),
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Action', style: boldStyle),
            const TextSpan(
                text: ' (research, design, collaboration, iteration)')
          ]))),
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Result', style: boldStyle),
            const TextSpan(text: ' (metrics, impact).')
          ]))),
    ],
  );
}

Widget _userTypesDescription(double bodySize) {
  final baseStyle = GoogleFonts.albertSans(
      color: Colors.white, fontSize: bodySize, height: 1.5);
  final boldStyle = _philosophyGradientStyle(
      fontSize: bodySize, fontWeight: FontWeight.bold, height: 1.5);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Typical users', style: boldStyle),
            const TextSpan(text: ' (intuitive nav, clear labels)')
          ]))),
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Frequent users', style: boldStyle),
            const TextSpan(text: ' (shortcuts, advanced features)')
          ]))),
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'First-time users', style: boldStyle),
            const TextSpan(text: ' (onboarding, progressive disclosure).')
          ]))),
    ],
  );
}

Widget _wcagDescription(double bodySize) {
  final baseStyle = GoogleFonts.albertSans(
      color: Colors.white, fontSize: bodySize, height: 1.5);
  final boldStyle = _philosophyGradientStyle(
      fontSize: bodySize, fontWeight: FontWeight.bold, height: 1.5);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Perceivable', style: boldStyle),
            const TextSpan(text: ' (contrast, typography, alternatives)')
          ]))),
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Operable', style: boldStyle),
            const TextSpan(text: ' (keyboard, focus, touch targets)')
          ]))),
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Understandable', style: boldStyle),
            const TextSpan(text: ' (consistent nav, error messages)')
          ]))),
      Padding(
          padding: const EdgeInsets.only(left: _circleMethodIndent, bottom: 4),
          child: SelectableText.rich(TextSpan(style: baseStyle, children: [
            TextSpan(text: 'Robust', style: boldStyle),
            const TextSpan(text: ' (semantic structure, cross-platform).')
          ]))),
    ],
  );
}

List<String> _descriptionToBullets(String description) {
  String text = description.trim();
  if (text.startsWith('—')) text = text.substring(1).trim();
  if (text.isEmpty) return [];
  if (text.contains('?')) {
    final parts = text
        .split(RegExp(r'\?\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.map((s) => s.endsWith('?') ? s : '$s?').toList();
  }
  if (text.contains(';')) {
    return text
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return [text];
}

Widget _processStep(
    double bodySize, String number, String stageName, String description) {
  final bullets = _descriptionToBullets(description);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SelectableText.rich(
        TextSpan(
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: bodySize,
            height: 1.55,
          ),
          children: [
            TextSpan(
              text: '$number. ',
              style: GoogleFonts.albertSans(
                color: ColorManager.accentGoldDark,
                fontSize: bodySize,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: stageName,
              style: GoogleFonts.albertSans(
                color: ColorManager.orange,
                fontSize: bodySize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      if (bullets.isNotEmpty) ...[
        SizedBox(height: 4),
        ...bullets.map((b) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: SelectableText(
                '• $b',
                style: GoogleFonts.albertSans(
                  color: Colors.white,
                  fontSize: bodySize - 1,
                  height: 1.45,
                ),
              ),
            )),
      ],
    ],
  );
}

/// Global design philosophy and product design principles.
class DesignPhilosophyScreen extends StatelessWidget {
  const DesignPhilosophyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    final double sectionTitleSize = isMobile ? 18 : (isTablet ? 20 : 22);
    final double bodySize = isMobile ? 15 : (isTablet ? 16 : 17);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.portfolio);
            }
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: SelectableText(
          'Design Philosophy & Principles',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F96A3).withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: Scrollbar(
              thumbVisibility: true,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
                        vertical: isMobile ? 20 : 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : 800,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              'Integrated Product Design',
                              style: _philosophyGradientStyle(
                                fontSize: sectionTitleSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: he * 0.015),
                            SelectableText(
                              'Understanding humans deeply and solving real problems with care, clarity, and intention.',
                              style: _philosophyGradientStyle(
                                fontSize: bodySize,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: he * 0.04),
                            _PhilosophyBlock(
                              title: 'Design Philosophy — North Star',
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                              customChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    'Design does not begin with screens or tools',
                                    style: GoogleFonts.albertSans(
                                      color: ColorManager.accentGoldDark,
                                      fontSize: bodySize,
                                      height: 1.55,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SelectableText(
                                    'It begins with understanding people.',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'In digital products:',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SelectableText(
                                    'visual clutter is a cognitive sharp edge;',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SelectableText(
                                    'poor hierarchy creates fatigue;',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SelectableText(
                                    'ignoring privacy can harm users.',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText.rich(
                                    TextSpan(
                                      style: GoogleFonts.albertSans(
                                        color: Colors.white,
                                        fontSize: bodySize,
                                        height: 1.55,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text:
                                                'A designer\'s role is to protect '),
                                        TextSpan(
                                          text: 'users',
                                          style: GoogleFonts.albertSans(
                                            color: ColorManager.orange,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ', not '),
                                        TextSpan(
                                          text: 'overwhelm them',
                                          style: GoogleFonts.albertSans(
                                            color: ColorManager.orange,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: '.'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: he * 0.025),
                            _PhilosophyBlock(
                              title: 'Empathy as Foundation',
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                              customChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText.rich(
                                    TextSpan(
                                      style: GoogleFonts.albertSans(
                                        color: Colors.white,
                                        fontSize: bodySize,
                                        height: 1.55,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              'Empathy is not a step in the process',
                                          style: GoogleFonts.albertSans(
                                            color: ColorManager.accentGoldDark,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ' — '),
                                      ],
                                    ),
                                  ),
                                  SelectableText(
                                    'it is the foundation of every decision.',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'Users open up only when they feel respected.',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SelectableText.rich(
                                    TextSpan(
                                      style: GoogleFonts.albertSans(
                                        color: Colors.white,
                                        fontSize: bodySize,
                                        height: 1.55,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text:
                                                'I avoid long surveys; I prefer '),
                                        TextSpan(
                                          text: 'conversations',
                                          style: GoogleFonts.albertSans(
                                            color: ColorManager.orange,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'observation',
                                          style: GoogleFonts.albertSans(
                                            color: ColorManager.orange,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ';'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SelectableText(
                                    'I listen more than I ask.',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'Without empathy, design becomes decoration.',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'AI can analyze patterns, but it cannot feel frustration, fear, or trust. That responsibility remains human.',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: he * 0.025),
                            _PhilosophyBlock(
                              title: 'End-to-End Process',
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                              customChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    'Structured thinking in eight stages:',
                                    style: GoogleFonts.albertSans(
                                      color: ColorManager.accentGoldDark,
                                      fontSize: bodySize,
                                      height: 1.55,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  if (isMobile)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _processStep(
                                            bodySize,
                                            '1',
                                            'Comprehend & Discover',
                                            ' — What problem? Who is affected? In what context?'),
                                        SizedBox(height: 10),
                                        _processStep(
                                            bodySize,
                                            '2',
                                            'Define Users & Needs',
                                            ' — Primary and secondary roles; motivations and frustrations.'),
                                        SizedBox(height: 10),
                                        _processStep(
                                            bodySize,
                                            '3',
                                            'Prioritize & Frame',
                                            ' — Break complexity into parts; prioritize by impact and feasibility.'),
                                        SizedBox(height: 10),
                                        _processStep(
                                            bodySize,
                                            '4',
                                            'Ideation & Brainstorming',
                                            ' — Safe and bold ideas; constraints as creative boundaries.'),
                                        SizedBox(height: 10),
                                        _processStep(
                                            bodySize,
                                            '5',
                                            'Low-Fidelity Exploration',
                                            ' — Sketch concepts, flows, interactions.'),
                                        SizedBox(height: 10),
                                        _processStep(
                                            bodySize,
                                            '6',
                                            'Wireframes & High-Fidelity',
                                            ' — Structure, accessibility, intentional visual choices.'),
                                        SizedBox(height: 10),
                                        _processStep(
                                            bodySize,
                                            '7',
                                            'Prototyping & Testing',
                                            ' — Validate flows; observe emotional response.'),
                                        SizedBox(height: 10),
                                        _processStep(
                                            bodySize,
                                            '8',
                                            'Evaluation & Iteration',
                                            ' — User behavior, feedback, friction; iteration keeps products alive.'),
                                      ],
                                    )
                                  else
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _processStep(
                                                  bodySize,
                                                  '1',
                                                  'Comprehend & Discover',
                                                  ' — What problem? Who is affected? In what context?'),
                                              SizedBox(height: 10),
                                              _processStep(
                                                  bodySize,
                                                  '2',
                                                  'Define Users & Needs',
                                                  ' — Primary and secondary roles; motivations and frustrations.'),
                                              SizedBox(height: 10),
                                              _processStep(
                                                  bodySize,
                                                  '3',
                                                  'Prioritize & Frame',
                                                  ' — Break complexity into parts; prioritize by impact and feasibility.'),
                                              SizedBox(height: 10),
                                              _processStep(
                                                  bodySize,
                                                  '4',
                                                  'Ideation & Brainstorming',
                                                  ' — Safe and bold ideas; constraints as creative boundaries.'),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 24),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _processStep(
                                                  bodySize,
                                                  '5',
                                                  'Low-Fidelity Exploration',
                                                  ' — Sketch concepts, flows, interactions.'),
                                              SizedBox(height: 10),
                                              _processStep(
                                                  bodySize,
                                                  '6',
                                                  'Wireframes & High-Fidelity',
                                                  ' — Structure, accessibility, intentional visual choices.'),
                                              SizedBox(height: 10),
                                              _processStep(
                                                  bodySize,
                                                  '7',
                                                  'Prototyping & Testing',
                                                  ' — Validate flows; observe emotional response.'),
                                              SizedBox(height: 10),
                                              _processStep(
                                                  bodySize,
                                                  '8',
                                                  'Evaluation & Iteration',
                                                  ' — User behavior, feedback, friction; iteration keeps products alive.'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: he * 0.025),
                            _PhilosophyBlock(
                              title: 'Principles I Live By',
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                              customChild: LayoutBuilder(
                                builder: (context, constraints) {
                                  final twoColumns =
                                      constraints.maxWidth >= 400;
                                  final items = [
                                    'Problem-first thinking',
                                    'Deep empathy',
                                    'Safety and privacy by design',
                                    'Context-aware experiences',
                                    'Progressive personalization',
                                    'Collaboration over ego',
                                    'Iteration over perfection',
                                    'Ethics over trends',
                                  ];
                                  if (!twoColumns) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: items
                                          .map((s) =>
                                              _principleItem(bodySize, s))
                                          .toList(),
                                    );
                                  }
                                  const int half = 4;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: items
                                              .take(half)
                                              .map((s) =>
                                                  _principleItem(bodySize, s))
                                              .toList(),
                                        ),
                                      ),
                                      SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: items
                                              .skip(half)
                                              .map((s) =>
                                                  _principleItem(bodySize, s))
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: he * 0.025),
                            _PhilosophyBlock(
                              title: 'Frameworks Used in Practice',
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                              customChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _frameworkItem(
                                      bodySize, he, 'CIRCLE METHOD', '',
                                      descriptionChild:
                                          _circleMethodDescription(bodySize)),
                                  SizedBox(height: he * 0.02),
                                  _frameworkItem(bodySize, he, 'STAR', '',
                                      descriptionChild:
                                          _starDescription(bodySize)),
                                  SizedBox(height: he * 0.02),
                                  _frameworkItem(bodySize, he, 'User Types', '',
                                      descriptionChild:
                                          _userTypesDescription(bodySize)),
                                  SizedBox(height: he * 0.02),
                                  _frameworkItem(bodySize, he,
                                      'WCAG (Target Level AA)', '',
                                      descriptionChild:
                                          _wcagDescription(bodySize)),
                                ],
                              ),
                            ),
                            SizedBox(height: he * 0.025),
                            _PhilosophyBlock(
                              title: 'Closing Perspective',
                              content:
                                  'Design is not about following frameworks blindly. It is about creating experiences people can feel, trust, and live with — whether physical or digital, small or used by millions. That responsibility drives my work as a product designer.',
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                            ),
                            SizedBox(height: he * 0.06),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  5,
                                  (i) => Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 6 : 10),
                                        child: Icon(
                                          Icons.star_rounded,
                                          color: ColorManager.accentGold
                                              .withValues(
                                                  alpha: 0.75 - i * 0.08),
                                          size: isMobile ? 28 : 36,
                                        ),
                                      )),
                            ),
                            SizedBox(height: he * 0.06),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhilosophyBlock extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? customChild;
  final double bodySize;
  final double he;
  final bool isMobile;

  const _PhilosophyBlock({
    required this.title,
    this.content,
    this.customChild,
    required this.bodySize,
    required this.he,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: _grayFrostedCardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            title,
            style: _philosophyGradientStyle(
              fontSize: bodySize + 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: he * 0.012),
          if (customChild != null)
            customChild!
          else
            SelectableText(
              content!,
              style: GoogleFonts.albertSans(
                color: Colors.white,
                fontSize: bodySize,
                height: 1.55,
              ),
            ),
        ],
      ),
    );
  }
}
