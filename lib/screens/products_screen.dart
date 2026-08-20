import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';

const _githubUrl = 'https://github.com/johnacolani/4iInstaller';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        leading: FrostedAppBar.backLeading(context, tooltip: 'Back to home'),
        title: const Text('Products',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071426), Color(0xFF111827), Color(0xFF09111F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                EdgeInsets.fromLTRB(mobile ? 20 : 48, 72, mobile ? 20 : 48, 64),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRODUCTS BY 4iDEAS', style: _eyebrow),
                    const SizedBox(height: 14),
                    Text('Software built for real work.',
                        style: _title(mobile ? 38 : 56)),
                    const SizedBox(height: 18),
                    Text(
                      'Software built to solve real-world design, engineering, and development problems.',
                      style: _body(mobile ? 17 : 20),
                    ),
                    const SizedBox(height: 46),
                    LayoutBuilder(builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 820;
                      final cards = [
                        _ProductCard(
                          icon: Icons.architecture_outlined,
                          title: '4iCAD',
                          description:
                              'Professional cross-platform CAD designed for practical drafting and engineering workflows.',
                          primaryLabel: 'Learn More',
                          onPrimary: () => context.go(AppRoutes.fourICad),
                        ),
                        _ProductCard(
                          icon: Icons.install_desktop_outlined,
                          title: '4iInstaller',
                          description:
                              'A free reusable Windows installer builder for Flutter desktop applications.',
                          supporting:
                              'Install the tool once, then build Windows setup executables from any Flutter project.',
                          primaryLabel: 'Learn More',
                          onPrimary: () => context.go(AppRoutes.fourIInstaller),
                          secondaryLabel: 'View on GitHub',
                          onSecondary: () => launchUrl(Uri.parse(_githubUrl),
                              mode: LaunchMode.externalApplication),
                        ),
                      ];
                      return stacked
                          ? Column(children: [
                              cards[0],
                              const SizedBox(height: 20),
                              cards[1]
                            ])
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                  Expanded(child: cards[0]),
                                  const SizedBox(width: 20),
                                  Expanded(child: cards[1])
                                ]);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard(
      {required this.icon,
      required this.title,
      required this.description,
      required this.primaryLabel,
      required this.onPrimary,
      this.supporting,
      this.secondaryLabel,
      this.onSecondary});
  final IconData icon;
  final String title, description, primaryLabel;
  final String? supporting, secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: ColorManager.accentGold.withValues(alpha: .28)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: ColorManager.accentGold, size: 34),
          const SizedBox(height: 22),
          Text(title, style: _title(28)),
          const SizedBox(height: 12),
          Text(description, style: _body(16)),
          if (supporting != null) ...[
            const SizedBox(height: 12),
            Text(supporting!, style: _body(14))
          ],
          const SizedBox(height: 26),
          Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
            if (secondaryLabel != null)
              OutlinedButton(
                  onPressed: onSecondary, child: Text(secondaryLabel!)),
          ]),
        ]),
      );
}

final _eyebrow = GoogleFonts.roboto(
    color: ColorManager.accentGold,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5);
TextStyle _title(double size) => GoogleFonts.roboto(
    color: Colors.white,
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 1.08);
TextStyle _body(double size) => GoogleFonts.roboto(
    color: Colors.white.withValues(alpha: .72), fontSize: size, height: 1.55);
