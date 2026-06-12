import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Botón grande estilo Duolingo: relieve 3D (borde inferior más oscuro)
/// que se "hunde" al presionarlo.
class PocketButton extends StatefulWidget {
  const PocketButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.orange,
    this.shadowColor,
    this.textColor = Colors.white,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color? shadowColor;
  final Color textColor;
  final IconData? icon;
  final bool expanded;

  @override
  State<PocketButton> createState() => _PocketButtonState();
}

class _PocketButtonState extends State<PocketButton> {
  bool _pressed = false;

  Color get _shadow =>
      widget.shadowColor ??
      HSLColor.fromColor(widget.color)
          .withLightness(
              (HSLColor.fromColor(widget.color).lightness - 0.12).clamp(0, 1))
          .toColor();

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    const depth = 4.0;

    final content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: widget.textColor, size: 22),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            color: widget.textColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? depth : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: disabled ? AppColors.borderLight : widget.color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _pressed || disabled
              ? []
              : [
                  BoxShadow(
                    color: _shadow,
                    offset: const Offset(0, depth),
                  ),
                ],
        ),
        child: content,
      ),
    );
  }
}
