import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/screens/web_screen.dart';
import 'package:go_router/go_router.dart';

import '../helper/app_background.dart';
import '../core/design_system/theme.dart';

import 'mobile_screen.dart';

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
            child: isMobile ? const MobileScreen() : const WebScreen(),
          ),
          SafeArea(
            child: _ModernTopAppBar(isMobile: isMobile),
          ),
        ],
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
                  children: [
                    const SizedBox(width: 20),
                    Image.asset('assets/images/logo.png',
                        width: isMobile ? 28 : 34, height: isMobile ? 28 : 34),
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
                          const TextSpan(text: 'DEAS'),
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
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutes.contact),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primaryGold, width: 1.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    child: Text(
                      "Let's Talk",
                      style: navStyle?.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.go(AppRoutes.contact),
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: AppColors.primaryGold),
                    tooltip: "Let's Talk",
                  ),
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
    ('Blog', AppRoutes.insights),
  ];

  int _indexForPath(String path) {
    if (path == AppRoutes.home) return 0;
    if (path == AppRoutes.services) return 1;
    if (path.startsWith(AppRoutes.portfolio)) return 2;
    if (path == AppRoutes.designPhilosophy) return 3;
    if (path == AppRoutes.about) return 4;
    if (path.startsWith(AppRoutes.insights)) return 5;
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Sign Up', style: textStyle),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on,
                color: AppColors.primaryGold, size: 15),
            const SizedBox(width: 4),
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
    );
  }
}
