import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/screens/web_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/app_background.dart';
import '../core/design_system/theme.dart';

const String _kHomePhoneDigits = '8047749008';

Future<void> _launchHomePhone() async {
  final uri = Uri(scheme: 'tel', path: _kHomePhoneDigits);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void _showLetsTalkDialog(BuildContext context) {
  showDialog<String>(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (dialogContext) {
      return AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderColor),
          ),
          title: const Text(
            "Let's Talk",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tap the number to call, or open the contact page to send a message.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: AppColors.borderColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => Navigator.of(dialogContext).pop('call'),
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.phone, color: AppColors.primaryGold, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '(804) 774-9008',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('dismissed'),
              child: Text('Close', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('contact'),
              child: const Text('Contact page', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w600)),
            ),
          ],
        );
    },
  ).then((result) {
    if (result == 'call') {
      _launchHomePhone();
    } else if (result == 'contact' && context.mounted) {
      context.go(AppRoutes.contact);
    }
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AppBackground(),
          Positioned.fill(
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ModernTopAppBar(isMobile: isMobile),
                      if (isMobile) ...[
                        const SizedBox(height: 8),
                        const _AccountMetaBlock(),
                      ],
                      const SizedBox(height: 12),
                      _HomeLetsTalkBar(isMobile: isMobile),
                    ],
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    // Same home content on phone, tablet, and desktop (see [WebScreen]).
                    child: const WebScreen(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLetsTalkBar extends StatelessWidget {
  const _HomeLetsTalkBar({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final navStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        );
    return Padding(
      padding: EdgeInsets.only(
        left: isMobile ? 14 : 24,
        right: 64,
        bottom: 8,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton(
          onPressed: () => _showLetsTalkDialog(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: AppColors.primaryGold,
              width: 1.1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: Text(
            "Let's Talk",
            style: navStyle?.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernTopAppBar extends StatelessWidget {
  const _ModernTopAppBar({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final navStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        );
    return Padding(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: isMobile ? 124 : 136,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 20),
                    Image.asset('assets/images/logo.png',
                        width: isMobile ? 56 : 68, height: isMobile ? 56 : 68),
                    const SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: isMobile ? 24 : 34,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                        children: [
                          TextSpan(
                            text: '4i',
                            style: TextStyle(
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color(0xFFF5B32F),
                                    Color(0xFFD89A1C),
                                  ],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 56, 24),
                                ),
                            ),
                          ),
                          const TextSpan(text: 'Deas'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isMobile) ...[
                  const Spacer(),
                  Expanded(
                    child: _TopNavTabs(
                      currentPath: currentPath,
                      style: navStyle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const _AccountMetaBlock(),
                ] else ...[
                  const Spacer(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNavTabs extends StatelessWidget {
  const _TopNavTabs({
    required this.currentPath,
    required this.style,
  });

  final String currentPath;
  final TextStyle? style;

  static const List<(String label, String route)> _items = [
    ('Home', AppRoutes.home),
    ('Services', AppRoutes.services),
    ('Work', AppRoutes.portfolio),
    ('Process', AppRoutes.designPhilosophy),
    ('About', AppRoutes.about),
    ('Contact Us', AppRoutes.contact),
    ('Blog', AppRoutes.insights),
  ];

  int _indexForPath(String path) {
    if (path == AppRoutes.home) return 0;
    if (path == AppRoutes.services) return 1;
    if (path.startsWith(AppRoutes.portfolio)) return 2;
    if (path == AppRoutes.designPhilosophy) return 3;
    if (path == AppRoutes.about) return 4;
    if (path == AppRoutes.contact) return 5;
    if (path.startsWith(AppRoutes.insights)) return 6;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _indexForPath(currentPath);
    return DefaultTabController(
      key: ValueKey<String>(currentPath),
      initialIndex: selected,
      length: _items.length,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          indicatorColor: AppColors.primaryGold,
          indicatorWeight: 2.4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelStyle: style,
          unselectedLabelStyle: style,
          onTap: (index) => context.go(_items[index].$2),
          tabs: _items.map((item) => Tab(text: item.$1)).toList(),
        ),
      ),
    );
  }
}

class _AccountMetaBlock extends StatelessWidget {
  const _AccountMetaBlock();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Sign in', style: textStyle),
            ),
            Text(
              ' / ',
              style: textStyle?.copyWith(color: AppColors.primaryGold),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.signUp),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Sign Up', style: textStyle),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on,
                color: AppColors.primaryGold, size: 15),
            const SizedBox(width: 6),
            Text(
              'Based in: Richmond, VA',
              style: textStyle?.copyWith(
                color: const Color(0xFFD1D5DB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
}
