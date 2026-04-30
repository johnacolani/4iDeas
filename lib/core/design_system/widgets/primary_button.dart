import 'package:flutter/material.dart';

import '../theme.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _hovered ? 1.02 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(AppRadius.buttonRadius),
            boxShadow:
                _hovered ? <BoxShadow>[AppShadows.soft] : const <BoxShadow>[],
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
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.bgMain,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.arrow_forward,
                        size: 18, color: AppColors.bgMain),
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
