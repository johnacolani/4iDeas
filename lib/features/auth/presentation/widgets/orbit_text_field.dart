import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sculpted_login_tokens.dart';

/// Stadium / pill: true semicircular caps on left and right (diameter = height).
Path _orbitFieldPath(Size size) {
  final w = size.width;
  final h = size.height;
  final r = h / 2;

  if (w < 2 * r) {
    return Path()..addOval(Rect.fromLTWH(0, 0, w, h));
  }

  final path = Path();
  path.moveTo(r, 0);
  path.lineTo(w - r, 0);
  path.arcTo(
    Rect.fromCircle(center: Offset(w - r, h / 2), radius: r),
    -math.pi / 2,
    math.pi,
    false,
  );
  path.lineTo(r, h);
  path.arcTo(
    Rect.fromCircle(center: Offset(r, h / 2), radius: r),
    math.pi / 2,
    -math.pi,
    false,
  );
  path.close();
  return path;
}

class _OrbitFieldShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _orbitFieldPath(size);

  @override
  bool shouldReclip(covariant _OrbitFieldShapeClipper oldClipper) => false;
}

/// Stroke-only glow **outside** the clipped field; blur is tallied here so it isn’t cut off.
class _OrbitFieldOuterGlowPainter extends CustomPainter {
  _OrbitFieldOuterGlowPainter({
    required this.borderWidth,
    this.glowColor,
  });

  final double borderWidth;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = glowColor;
    if (glow == null) return;

    final path = _orbitFieldPath(size);

    canvas.drawPath(
      path,
      Paint()
        ..color = glow.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + 22
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = glow.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + 16
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = glow.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = glow.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitFieldOuterGlowPainter oldDelegate) {
    return oldDelegate.borderWidth != borderWidth ||
        oldDelegate.glowColor != glowColor;
  }
}

class _OrbitFieldFillAndBorderPainter extends CustomPainter {
  _OrbitFieldFillAndBorderPainter({
    required this.borderColor,
    required this.fillColor,
    required this.borderWidth,
  });

  final Color borderColor;
  final Color fillColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _orbitFieldPath(size);

    canvas.drawPath(path, Paint()..color = fillColor);

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitFieldFillAndBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

/// Glass stadium field: leading icon centered in the left semicircle; optional trailing outside the pill.
class OrbitTextField extends StatefulWidget {
  const OrbitTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.leadingIcon,
    this.keyboardType,
    this.obscureText = false,
    this.autovalidateMode,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData leadingIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final Widget? trailing;

  @override
  State<OrbitTextField> createState() => _OrbitTextFieldState();
}

class _OrbitTextFieldState extends State<OrbitTextField> {
  late final FocusNode _focusNode =
      widget.focusNode ?? FocusNode(debugLabel: 'OrbitTextField');
  late final bool _ownsFocusNode = widget.focusNode == null;
  Timer? _focusGlowDelayTimer;
  bool _showFocusGlow = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    _focusGlowDelayTimer?.cancel();
    if (_focusNode.hasFocus) {
      setState(() => _showFocusGlow = false);
      _focusGlowDelayTimer = Timer(const Duration(milliseconds: 140), () {
        if (mounted && _focusNode.hasFocus) {
          setState(() => _showFocusGlow = true);
        }
      });
    } else {
      setState(() => _showFocusGlow = false);
    }
  }

  @override
  void dispose() {
    _focusGlowDelayTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller.text,
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      builder: (field) {
        final hasError = field.hasError;
        final focused = _focusNode.hasFocus;

        final borderColor = hasError
            ? SculptedLoginTokens.coral
            : focused
                ? SculptedLoginTokens.loginFieldBorderFocused
                : SculptedLoginTokens.loginFieldBorderIdle
                    .withValues(alpha: 0.52);

        final borderWidth = focused || hasError ? 1.35 : 1.0;

        final fillColor = focused
            ? SculptedLoginTokens.loginGlassWarmLight.withValues(
                alpha: SculptedLoginTokens.loginGlassOpacity,
              )
            : SculptedLoginTokens.loginGlassWarmDeep.withValues(
                alpha: SculptedLoginTokens.loginGlassOpacity,
              );

        final borderGlowColor = hasError
            ? SculptedLoginTokens.coral
            : focused && _showFocusGlow
                ? SculptedLoginTokens.cyanFocus
                : null;

        const fieldH = SculptedLoginTokens.orbitFieldHeight;
        const leadingIconSize = 24.0;
        final capRadius = fieldH / 2;
        final textPaddingLeft = capRadius + leadingIconSize / 2 + 24;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: SculptedLoginTokens.offWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: fieldH,
                      child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(fieldH / 2),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _OrbitFieldOuterGlowPainter(
                                  borderWidth: borderWidth,
                                  glowColor: borderGlowColor,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: ClipPath(
                              clipper: _OrbitFieldShapeClipper(),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CustomPaint(
                                    painter: _OrbitFieldFillAndBorderPainter(
                                      borderColor: borderColor,
                                      fillColor: fillColor,
                                      borderWidth: borderWidth,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            inputDecorationTheme:
                                                Theme.of(context)
                                                    .inputDecorationTheme
                                                    .copyWith(
                                              filled: false,
                                              fillColor: Colors.transparent,
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              disabledBorder:
                                                  InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              focusedErrorBorder:
                                                  InputBorder.none,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: widget.controller,
                                            focusNode: _focusNode,
                                            obscureText: widget.obscureText,
                                            keyboardType: widget.keyboardType,
                                            textInputAction:
                                                widget.textInputAction,
                                            onSubmitted:
                                                widget.onFieldSubmitted,
                                            onChanged: field.didChange,
                                            style: const TextStyle(
                                              color:
                                                  SculptedLoginTokens.offWhite,
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            cursorColor:
                                                SculptedLoginTokens.cyanFocus,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              filled: false,
                                              fillColor: Colors.transparent,
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              focusedErrorBorder:
                                                  InputBorder.none,
                                              hintText: widget.hint,
                                              hintStyle: TextStyle(
                                                color: SculptedLoginTokens
                                                    .offWhite
                                                    .withValues(alpha: 0.38),
                                                fontSize: 15,
                                              ),
                                              contentPadding: EdgeInsets.only(
                                                left: textPaddingLeft,
                                                right: widget.trailing != null
                                                    ? 6
                                                    : 16,
                                                top: 16,
                                                bottom: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (widget.trailing != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          child: Center(
                                            child: widget.trailing!,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: capRadius - leadingIconSize / 2,
                            top: 0,
                            height: fieldH,
                            width: leadingIconSize,
                            child: IgnorePointer(
                              child: IconTheme(
                                data: IconThemeData(
                                  color: focused
                                      ? SculptedLoginTokens.cyanFocus
                                      : SculptedLoginTokens.offWhite,
                                  size: leadingIconSize,
                                  opacity: 1,
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.leadingIcon,
                                    size: leadingIconSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
            if (field.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: SculptedLoginTokens.coral,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
