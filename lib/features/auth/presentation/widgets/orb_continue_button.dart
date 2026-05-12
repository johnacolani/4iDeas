import 'package:flutter/material.dart';

import 'sculpted_login_tokens.dart';

/// Circular coral orb with arrow, soft glow, and optional loading state.
class OrbContinueButton extends StatefulWidget {
  const OrbContinueButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<OrbContinueButton> createState() => _OrbContinueButtonState();
}

class _OrbContinueButtonState extends State<OrbContinueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isLoading || widget.onPressed == null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
          onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
          onTapCancel: disabled ? null : () => setState(() => _pressed = false),
          onTap: disabled ? null : () => widget.onPressed?.call(),
          child: AnimatedScale(
            scale: _pressed ? 0.94 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: SculptedLoginTokens.orbButtonSize,
              height: SculptedLoginTokens.orbButtonSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SculptedLoginTokens.coral.withValues(alpha: 0.45),
                      blurRadius: 28,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: SculptedLoginTokens.amber.withValues(alpha: 0.18),
                      blurRadius: 14,
                      spreadRadius: -2,
                    ),
                  ],
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.35),
                    radius: 1.05,
                    colors: [
                      const Color(0xFFFF8A6B),
                      SculptedLoginTokens.coral,
                      const Color(0xFFE84B3C),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withValues(alpha: 0.95),
                          size: 34,
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Continue',
          style: TextStyle(
            color: SculptedLoginTokens.offWhite.withValues(alpha: 0.86),
            fontSize: 14,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
