import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Tarjeta redondeada estándar de la app.
class PocketCard extends StatelessWidget {
  const PocketCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? theme.dividerColor,
          width: 2,
        ),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: card,
      ),
    );
  }
}

/// Chip de estado (activo/inactivo) para el dashboard.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.active, this.onLabel = 'ON', this.offLabel = 'OFF'});

  final bool active;
  final String onLabel;
  final String offLabel;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.green : AppColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        active ? onLabel : offLabel,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Encabezado de sección.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Icono circular grande con color, usado en tarjetas de herramientas.
class ToolIcon extends StatelessWidget {
  const ToolIcon({super.key, required this.icon, required this.color, this.size = 52});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.55),
    );
  }
}
