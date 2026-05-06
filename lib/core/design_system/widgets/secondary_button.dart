import 'package:flutter/material.dart';

import '../theme.dart';

class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.buttonRadius);
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered || _focused
                ? AppColors.bgCard.withValues(alpha: 0.55)
                : Colors.transparent,
            borderRadius: radius,
          ),
          child: OutlinedButton(
            onFocusChange: (focused) => setState(() => _focused = focused),
            onPressed: widget.onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              side: BorderSide(
                color: _focused
                    ? AppColors.primaryGold
                    : Colors.white.withValues(alpha: 0.42),
                width: _focused ? 2 : 1,
              ),
              shape: RoundedRectangleBorder(borderRadius: radius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.arrow_forward,
                    size: 18, color: AppColors.textPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
