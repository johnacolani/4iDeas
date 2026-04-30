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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.bgCard.withValues(alpha: 0.55)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(widget.label,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.arrow_forward,
                      size: 18, color: AppColors.textPrimary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
