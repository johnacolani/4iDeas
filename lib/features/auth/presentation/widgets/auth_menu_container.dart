import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_router.dart';
import '../../../../core/design_system/theme.dart';

class AuthMenuContainer extends StatelessWidget {
  const AuthMenuContainer({
    super.key,
    required this.activeRoute,
  });

  final String activeRoute;

  @override
  Widget build(BuildContext context) {
    final bool isLoginActive = activeRoute == AppRoutes.login;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AuthNavButton(
                    label: 'Sign in',
                    selected: isLoginActive,
                    onTap: () => context.go(AppRoutes.login),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '/',
                    style: textStyle?.copyWith(color: AppColors.primaryGold),
                  ),
                  const SizedBox(width: 10),
                  _AuthNavButton(
                    label: 'Sign Up',
                    selected: !isLoginActive,
                    onTap: () => context.go(AppRoutes.signUp),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primaryGold,
                    size: 16,
                  ),
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
        ),
      ),
    );
  }
}

class _AuthNavButton extends StatelessWidget {
  const _AuthNavButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected ? AppColors.primaryGold : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? AppColors.primaryGold : Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
