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
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _hovered ? 1.02 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: radius,
              boxShadow: _hovered || _focused
                  ? <BoxShadow>[AppShadows.soft]
                  : const <BoxShadow>[],
            ),
            child: ElevatedButton(
              onFocusChange: (focused) => setState(() => _focused = focused),
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.bgMain,
                disabledBackgroundColor: Colors.transparent,
                disabledForegroundColor:
                    AppColors.bgMain.withValues(alpha: 0.48),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: BorderSide(
                    color: _focused ? Colors.white : Colors.transparent,
                    width: _focused ? 2 : 0,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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
    );
  }
}
