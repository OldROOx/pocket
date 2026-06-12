import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

class ToolInfo {
  const ToolInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
}

/// Catálogo central de herramientas de Pocket.
const tools = <ToolInfo>[
  ToolInfo(
    id: 'nfc',
    name: 'NFC Center',
    description: 'Lee etiquetas NFC y revisa su contenido',
    icon: Icons.nfc_rounded,
    color: AppColors.blue,
    route: '/nfc',
  ),
  ToolInfo(
    id: 'bluetooth',
    name: 'Bluetooth Center',
    description: 'Escanea dispositivos BLE cercanos',
    icon: Icons.bluetooth_rounded,
    color: AppColors.purple,
    route: '/bluetooth',
  ),
  ToolInfo(
    id: 'wifi',
    name: 'WiFi Analyzer',
    description: 'Analiza redes, canales e intensidad',
    icon: Icons.wifi_rounded,
    color: AppColors.green,
    route: '/wifi',
  ),
  ToolInfo(
    id: 'qr',
    name: 'QR Toolkit',
    description: 'Escanea y genera códigos QR',
    icon: Icons.qr_code_rounded,
    color: AppColors.orange,
    route: '/qr',
  ),
  ToolInfo(
    id: 'device',
    name: 'Device Center',
    description: 'Hardware, sensores y batería',
    icon: Icons.phone_android_rounded,
    color: AppColors.red,
    route: '/device',
  ),
  ToolInfo(
    id: 'automation',
    name: 'Automation Hub',
    description: 'Crea automatizaciones con disparadores',
    icon: Icons.bolt_rounded,
    color: AppColors.yellow,
    route: '/automation',
  ),
  ToolInfo(
    id: 'converters',
    name: 'Conversores',
    description: 'HEX, ASCII, Base64, binario y decimal',
    icon: Icons.swap_horiz_rounded,
    color: AppColors.blue,
    route: '/tools/converter',
  ),
  ToolInfo(
    id: 'generators',
    name: 'Generadores',
    description: 'UUID y contraseñas seguras',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.purple,
    route: '/tools/generator',
  ),
  ToolInfo(
    id: 'text',
    name: 'Texto',
    description: 'Contador y formateador JSON',
    icon: Icons.text_fields_rounded,
    color: AppColors.green,
    route: '/tools/text',
  ),
];

ToolInfo? toolById(String id) {
  for (final t in tools) {
    if (t.id == id) return t;
  }
  return null;
}
