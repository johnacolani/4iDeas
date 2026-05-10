import 'dart:ui';

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

const List<_ClientDesignPrinciple> _kClientDesignPrinciples =
    <_ClientDesignPrinciple>[
  _ClientDesignPrinciple(
    icon: Icons.business_center_outlined,
    title: 'Business-First Thinking',
    body:
        'Before I design, I try to understand the client’s business, workflow, users, and goals. This helps me create solutions that are not only visually clean, but also useful for the company and meaningful for the people who use the product.',
  ),
  _ClientDesignPrinciple(
    icon: Icons.person_search_outlined,
    title: 'User-Centered Experience',
    body:
        'Every screen should help users complete their task with less confusion and less effort. I focus on clear navigation, simple flows, readable content, and thoughtful interactions that make the product feel natural and easy to use.',
  ),
  _ClientDesignPrinciple(
    icon: Icons.accessibility_new_outlined,
    title: 'Accessibility by Design',
    body:
        'Accessibility is part of my design process from the beginning. Using WCAG principles, I design interfaces with strong color contrast, clear labels, helpful error messages, visible focus states, keyboard-friendly navigation, proper touch targets, and screen-reader-aware structure.',
  ),
  _ClientDesignPrinciple(
    icon: Icons.grid_view_outlined,
    title: 'Consistent Design Systems',
    body:
        'Strong products need strong systems. I use reusable components, design tokens, spacing rules, typography styles, and consistent UI patterns so the product can grow without becoming hard to manage.',
  ),
  _ClientDesignPrinciple(
    icon: Icons.devices_outlined,
    title: 'Responsive and Cross-Platform Design',
    body:
        'I design for real usage across mobile, tablet, desktop, and web. Each layout should feel natural on the device where it is used, while keeping the same brand, structure, and experience across platforms.',
  ),
  _ClientDesignPrinciple(
    icon: Icons.code_outlined,
    title: 'Design That Developers Can Build',
    body:
        'Because I also build apps with Flutter, I design with implementation in mind. I think about reusable widgets, clean architecture, performance, states, errors, loading flows, and how the design will work as a real product, not only as a static mockup.',
  ),
  _ClientDesignPrinciple(
    icon: Icons.smartphone_outlined,
    title: 'Real-Device Prototypes with Flutter',
    body:
        'I prototype in Figma for fast visual exploration and in Flutter when a flow needs to feel real. Flutter lets me run the prototype on a physical iPhone, Android, tablet, or desktop the same day — so I can test gestures, transitions, keyboards, real network states, accessibility, and one-handed reach on the device that will actually ship the product. Decisions stop being guesses about feel and become observations from real use.',
  ),
  _ClientDesignPrinciple(
    icon: Icons.rocket_launch_outlined,
    title: 'From MVP to Production',
    body:
        'I help clients start with a focused MVP that solves the most important problem first. Then I improve the product step by step with better features, stronger UI, cleaner architecture, and scalable systems for long-term growth.',
  ),
  _ClientDesignPrinciple(
    icon: Icons.favorite_border_outlined,
    title: 'Care, Quality, and Ownership',
    body:
        'I treat every project with care and ownership. Small details shape trust, so I focus on products that look professional, work smoothly, support real users, and create long-term value for the client.',
  ),
];

class _ClientDesignPrinciple {
  final IconData icon;
  final String title;
  final String body;

  const _ClientDesignPrinciple({
    required this.icon,
    required this.title,
    required this.body,
  });
}

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

Widget _frostedGlassContainer({
  required Widget child,
  double borderRadius = 12,
  EdgeInsetsGeometry? padding,
  double? width,
  BoxConstraints? constraints,
  AlignmentGeometry? alignment,
  BoxDecoration? decoration,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        width: width,
        constraints: constraints,
        alignment: alignment,
        padding: padding,
        decoration: decoration ??
            _grayFrostedCardDecoration(borderRadius: borderRadius),
        child: child,
      ),
    ),
  );
}

BoxDecoration _wcagGoldenFrostedDecoration({double borderRadius = 14}) {
  return BoxDecoration(
    color: const Color(0xFF1F2937).withValues(alpha: 0.24),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: ColorManager.accentGold.withValues(alpha: 0.34),
      width: 1.0,
    ),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorManager.accentGold.withValues(alpha: 0.16),
        Colors.white.withValues(alpha: 0.08),
        const Color(0xFF111827).withValues(alpha: 0.18),
        Colors.transparent,
      ],
      stops: const [0.0, 0.34, 0.72, 1.0],
    ),
  );
}

BoxDecoration _wcagGoldenInnerDecoration({double borderRadius = 12}) {
  return BoxDecoration(
    color: Colors.black.withValues(alpha: 0.18),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: ColorManager.accentGold.withValues(alpha: 0.24),
    ),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorManager.accentGold.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.05),
        Colors.black.withValues(alpha: 0.10),
      ],
    ),
  );
}

TextStyle _philosophyGradientStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w700,
  double height = 1.3,
  double letterSpacing = 0.2,
}) {
  return GoogleFonts.roboto(
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
      style: GoogleFonts.roboto(
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
  return _frostedGlassContainer(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    borderRadius: 12,
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
            style: GoogleFonts.roboto(
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
  final baseStyle = GoogleFonts.roboto(
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
  final baseStyle =
      GoogleFonts.roboto(color: Colors.white, fontSize: bodySize, height: 1.5);
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
  final baseStyle =
      GoogleFonts.roboto(color: Colors.white, fontSize: bodySize, height: 1.5);
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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _wcagText(
        bodySize,
        'WCAG means Web Content Accessibility Guidelines. It is a global standard from the W3C Web Accessibility Initiative for making websites, apps, SaaS dashboards, design systems, and Flutter products work better for people with visual, hearing, motor, cognitive, speech, and learning disabilities.',
        weight: FontWeight.w600,
      ),
      const SizedBox(height: 12),
      _wcagText(
        bodySize,
        'For real product work, my practical target is WCAG 2.2 Level AA. WCAG 2.2 became a W3C Recommendation on October 5, 2023. WCAG 3.0 is still in progress, so I use 2.2 AA today while watching future changes.',
      ),
      const SizedBox(height: 16),
      _wcagSection(
        bodySize: bodySize,
        title: 'The Main Idea: POUR',
        children: [
          _wcagCardGrid(
            bodySize: bodySize,
            cards: const [
              (
                Icons.visibility_outlined,
                'Perceivable',
                'Users must be able to see, hear, or understand the content. This means alt text, strong contrast, captions, resizable text, and no color-only meaning.'
              ),
              (
                Icons.keyboard_alt_outlined,
                'Operable',
                'Users must be able to use the interface. Controls should work with keyboard, mouse, touch, and assistive technology, with visible focus and no keyboard traps.'
              ),
              (
                Icons.psychology_alt_outlined,
                'Understandable',
                'Users must understand the content and actions. Labels, navigation, forms, instructions, and errors should be clear, consistent, and human.'
              ),
              (
                Icons.integration_instructions_outlined,
                'Robust',
                'The product should work with assistive technologies. In Flutter, this means semantic structure, proper labels, focus order, and accessible tap areas.'
              ),
            ],
          ),
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'WCAG Levels and Versions',
        bullets: const [
          'Level A removes the biggest blockers, such as making buttons usable by keyboard.',
          'Level AA is the professional target for most business, government, and enterprise work. Normal text usually needs at least 4.5:1 contrast; large text and UI components need at least 3:1.',
          'Level AAA is the highest level. It is excellent, but not always practical for every screen or product constraint.',
          'WCAG 2.0 is still referenced by many laws. WCAG 2.1 added more mobile, low-vision, and cognitive support. WCAG 2.2 added new success criteria and removed the old Parsing requirement.',
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'Rules I Check First',
        bullets: const [
          'Color contrast: text, icons, buttons, disabled states, and error states must be readable.',
          'Alt text: meaningful images need labels; decorative images should be ignored by screen readers.',
          'Keyboard access: Tab, Shift + Tab, Enter, Space, Escape, and arrow keys should work where expected.',
          'Visible focus: users must see where they are when navigating by keyboard.',
          'Forms and errors: fields need visible labels, clear required states, and helpful error messages near the field.',
          'Structure: headings and reading order should make sense, especially on Flutter Web where semantics need extra care.',
          'Touch targets: important controls should be large enough, around 44 by 44 pixels when possible.',
          'Captions and transcripts: video and audio content need accessible alternatives.',
          'No color-only meaning: use color plus text, icons, or labels for statuses like Approved, Rejected, Pending, Error, or Success.',
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'Simple Product Examples',
        children: [
          _wcagExample(
            bodySize,
            bad: 'Red field means error.',
            better:
                'Show a red border, an error icon, and text like “Email is required.”',
          ),
          _wcagExample(
            bodySize,
            bad: 'A dropdown only works with mouse hover.',
            better:
                'The dropdown works with mouse, keyboard, screen reader, and touch.',
          ),
          _wcagExample(
            bodySize,
            bad: 'Invalid input.',
            better:
                'Password must be at least 8 characters, or enter a valid email like name@example.com.',
          ),
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'How WCAG Shapes a Design System',
        bullets: const [
          'Accessible color tokens and contrast-tested text styles.',
          'Button, icon button, and link focus states.',
          'Accessible form field components and error patterns.',
          'Minimum touch target sizes and spacing rules.',
          'Keyboard navigation and modal behavior rules.',
          'Screen reader labels, empty states, loading states, and reduced motion support.',
          'Design tokens that define not only brand color, but also readable text, focus rings, disabled states, and non-color error indicators.',
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'How I Apply WCAG in Flutter',
        bullets: const [
          'Prefer built-in widgets such as ElevatedButton, TextButton, OutlinedButton, IconButton, TextFormField, CheckboxListTile, and ListTile.',
          'Use Semantics when a custom widget needs a better screen reader label.',
          'Use Tooltip for icon-only controls and never leave icon buttons unnamed.',
          'Use ExcludeSemantics for decorative icons or images to avoid duplicate announcements.',
          'Use MergeSemantics when an icon and text should be read as one meaning, such as “Payment failed.”',
          'Respect text scaling by avoiding fixed-height containers that cut off larger text.',
          'Use Focus, FocusTraversalGroup, visible focus states, and proper button widgets for Flutter Web and desktop keyboard support.',
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'Screen Checklist',
        bullets: const [
          'Every button has clear text or a screen reader label.',
          'Text and UI contrast are readable.',
          'The user can navigate with keyboard and see focus.',
          'Forms have visible labels, clear required fields, and useful errors.',
          'Layout still works with larger text.',
          'Images have alt text when meaningful, and decorative images are ignored.',
          'Modals can be closed and do not trap keyboard users.',
          'Instructions are simple and buttons use clear words, such as “View project details” instead of “Click here.”',
          'Motion is not excessive, loading states are clear, and reduced motion is considered.',
          'The screen is tested on mobile, web, keyboard, and screen reader.',
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'Testing Tools and Manual Testing',
        bullets: const [
          'Web tools: Chrome Lighthouse, axe DevTools, WAVE, Stark, Accessibility Insights, and Color Contrast Analyzer.',
          'Screen readers: VoiceOver on macOS and iPhone, TalkBack on Android, NVDA on Windows, and JAWS for enterprise testing.',
          'Flutter tools: Accessibility Inspector, Semantics Debugger, manual VoiceOver/TalkBack testing, and keyboard testing on Flutter Web/Desktop.',
          'Automated tools only catch part of the problem. Manual testing is still required.',
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'Common Mistakes I Avoid',
        bullets: const [
          'Low-contrast gray text.',
          'Icon-only buttons with no label.',
          'Removing focus outlines.',
          'Custom clickable containers that are not keyboard accessible.',
          'Placeholder text used instead of labels.',
          'Errors shown only with red color.',
          'Modals that trap keyboard users.',
          'Not testing text scaling, screen readers, or keyboard navigation.',
          'Beautiful UI that cannot be used without a mouse.',
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'My Practical Accessibility Statement',
        children: [
          _wcagText(
            bodySize,
            'I use WCAG as a practical quality standard, not just a checklist. In design, I check contrast, touch target size, readable typography, focus states, form errors, and clear navigation. In Flutter, I use built-in accessible widgets when possible, add Semantics for custom components, test text scaling, and verify the experience with keyboard and screen readers.',
            weight: FontWeight.w600,
          ),
        ],
      ),
      _wcagSection(
        bodySize: bodySize,
        title: 'Learning Path and Practice',
        bullets: const [
          'Learn POUR: Perceivable, Operable, Understandable, Robust.',
          'Learn A, AA, and AAA, then focus on WCAG 2.2 AA for real projects.',
          'Practice the common rules first: contrast, keyboard, focus, alt text, forms, headings, and captions.',
          'Apply accessibility to design systems through tokens, components, and patterns.',
          'Apply accessibility to Flutter through Semantics, Tooltip, focus, text scaling, and screen reader testing.',
          'Take one real screen and check buttons, contrast, keyboard navigation, focus, labels, errors, text scaling, icon labels, color-only meaning, and screen reader flow.',
        ],
      ),
    ],
  );
}

Widget _wcagSection({
  required double bodySize,
  required String title,
  List<String> bullets = const [],
  List<Widget> children = const [],
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: _frostedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      decoration: _wcagGoldenFrostedDecoration(borderRadius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            title,
            style: _philosophyGradientStyle(
              fontSize: bodySize + 1,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          if (bullets.isNotEmpty || children.isNotEmpty)
            const SizedBox(height: 8),
          if (bullets.isNotEmpty)
            ...bullets.map((text) => _wcagBullet(bodySize, text)),
          ...children,
        ],
      ),
    ),
  );
}

Widget _wcagText(
  double bodySize,
  String text, {
  FontWeight weight = FontWeight.w500,
}) {
  return SelectableText(
    text,
    style: GoogleFonts.roboto(
      color: Colors.white,
      fontSize: bodySize,
      height: 1.55,
      fontWeight: weight,
    ),
  );
}

Widget _wcagBullet(double bodySize, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: ColorManager.accentGold,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(child: _wcagText(bodySize, text)),
      ],
    ),
  );
}

Widget _wcagCardGrid({
  required double bodySize,
  required List<(IconData, String, String)> cards,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 540 ? 2 : 1;
      const gap = 10.0;
      final width = columns == 1
          ? constraints.maxWidth
          : (constraints.maxWidth - gap) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: cards
            .map(
              (card) => SizedBox(
                width: width,
                child: _wcagInfoCard(
                  bodySize: bodySize,
                  icon: card.$1,
                  title: card.$2,
                  body: card.$3,
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

Widget _wcagInfoCard({
  required double bodySize,
  required IconData icon,
  required String title,
  required String body,
}) {
  return MergeSemantics(
    child: _frostedGlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      decoration: _wcagGoldenInnerDecoration(borderRadius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  icon,
                  color: ColorManager.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SelectableText(
                  title,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: bodySize,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _wcagText(bodySize - 0.5, body),
        ],
      ),
    ),
  );
}

Widget _wcagExample(
  double bodySize, {
  required String bad,
  required String better,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: _frostedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      decoration: _wcagGoldenInnerDecoration(borderRadius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _wcagText(bodySize, 'Bad: $bad'),
          const SizedBox(height: 4),
          SelectableText(
            'Better: $better',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: bodySize,
              height: 1.55,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
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
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: bodySize,
            height: 1.55,
          ),
          children: [
            TextSpan(
              text: '$number. ',
              style: GoogleFonts.roboto(
                color: ColorManager.accentGoldDark,
                fontSize: bodySize,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: stageName,
              style: GoogleFonts.roboto(
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
                style: GoogleFonts.roboto(
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
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 16 : 18,
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
                            _ClientFocusedPrinciplesSection(
                              bodySize: bodySize,
                              he: he,
                              isMobile: isMobile,
                            ),
                            SizedBox(height: he * 0.025),
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
                                    style: GoogleFonts.roboto(
                                      color: ColorManager.accentGoldDark,
                                      fontSize: bodySize,
                                      height: 1.55,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SelectableText(
                                    'It begins with understanding people.',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'In digital products:',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SelectableText(
                                    'visual clutter is a cognitive sharp edge;',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SelectableText(
                                    'poor hierarchy creates fatigue;',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SelectableText(
                                    'ignoring privacy can harm users.',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText.rich(
                                    TextSpan(
                                      style: GoogleFonts.roboto(
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
                                          style: GoogleFonts.roboto(
                                            color: ColorManager.orange,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ', not '),
                                        TextSpan(
                                          text: 'overwhelm them',
                                          style: GoogleFonts.roboto(
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
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: bodySize,
                                        height: 1.55,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              'Empathy is not a step in the process',
                                          style: GoogleFonts.roboto(
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
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'Users open up only when they feel respected.',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  SelectableText.rich(
                                    TextSpan(
                                      style: GoogleFonts.roboto(
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
                                          style: GoogleFonts.roboto(
                                            color: ColorManager.orange,
                                            fontSize: bodySize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'observation',
                                          style: GoogleFonts.roboto(
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
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'Without empathy, design becomes decoration.',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: bodySize,
                                      height: 1.55,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'AI can analyze patterns, but it cannot feel frustration, fear, or trust. That responsibility remains human.',
                                    style: GoogleFonts.roboto(
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
                                    style: GoogleFonts.roboto(
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
    return _frostedGlassContainer(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      borderRadius: 16,
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
              style: GoogleFonts.roboto(
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

class _ClientFocusedPrinciplesSection extends StatelessWidget {
  final double bodySize;
  final double he;
  final bool isMobile;

  const _ClientFocusedPrinciplesSection({
    required this.bodySize,
    required this.he,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return _frostedGlassContainer(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            'Client-Focused Product Principles',
            style: _philosophyGradientStyle(
              fontSize: bodySize + 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: he * 0.012),
          SelectableText(
            'Great product design is not only about making beautiful screens. It is about understanding the business goal, the users, and the real problem behind the product. My design process focuses on creating digital experiences that are clear, useful, accessible, and ready to grow.',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: bodySize,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: he * 0.016),
          _frostedGlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            borderRadius: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.black.withValues(alpha: 0.18),
              border: Border.all(
                color: ColorManager.accentGold.withValues(alpha: 0.32),
              ),
            ),
            child: SelectableText(
              'When a client trusts me with an idea, I treat it like a real business product, not just a design task. I design every product with care, clarity, accessibility, and long-term growth in mind.',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: bodySize,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: he * 0.018),
          _ClientPrinciplesGrid(
            bodySize: bodySize,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }
}

class _ClientPrinciplesGrid extends StatelessWidget {
  final double bodySize;
  final bool isMobile;

  const _ClientPrinciplesGrid({
    required this.bodySize,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gap = isMobile ? 12 : 14;
        final int columns = constraints.maxWidth >= 640 ? 2 : 1;
        final double cardWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _kClientDesignPrinciples
              .map(
                (principle) => SizedBox(
                  width: cardWidth,
                  child: _ClientPrincipleCard(
                    principle: principle,
                    bodySize: bodySize,
                    isMobile: isMobile,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ClientPrincipleCard extends StatelessWidget {
  final _ClientDesignPrinciple principle;
  final double bodySize;
  final bool isMobile;

  const _ClientPrincipleCard({
    required this.principle,
    required this.bodySize,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: _frostedGlassContainer(
        constraints: BoxConstraints(minHeight: isMobile ? 0 : 258),
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        borderRadius: 14,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: _frostedGlassContainer(
                    width: 38,
                    constraints: const BoxConstraints(
                      minWidth: 38,
                      minHeight: 38,
                    ),
                    alignment: Alignment.center,
                    borderRadius: 999,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorManager.accentGold.withValues(alpha: 0.12),
                      border: Border.all(
                        color: ColorManager.accentGold.withValues(alpha: 0.34),
                      ),
                    ),
                    child: Icon(
                      principle.icon,
                      color: ColorManager.accentGold,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(
                    principle.title,
                    style: _philosophyGradientStyle(
                      fontSize: bodySize + 1,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              principle.body,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: bodySize - 0.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
