import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'pocket_widgets.dart';

/// Banner de advertencia que SOLO se muestra cuando la app corre en
/// un iPhone / iPad (iOS). En Android no aparece nada.
///
/// [blocking] = true  -> la función NO funciona en iOS (banner rojo).
/// [blocking] = false -> la función funciona con límites (banner amarillo).
class IosWarningBanner extends StatelessWidget {
  const IosWarningBanner({
    super.key,
    required this.message,
    this.blocking = true,
  });

  final String message;
  final bool blocking;

  @override
  Widget build(BuildContext context) {
    // En web Platform.isIOS truena, así que primero validamos kIsWeb.
    if (kIsWeb || !Platform.isIOS) return const SizedBox.shrink();

    final color = blocking ? AppColors.red : AppColors.yellow;
    final title = blocking
        ? 'No disponible en iPhone'
        : 'Funcionalidad limitada en iPhone';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PocketCard(
        color: color.withOpacity(0.10),
        borderColor: color.withOpacity(0.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              blocking
                  ? Icons.block_rounded
                  : Icons.warning_amber_rounded,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
