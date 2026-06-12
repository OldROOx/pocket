import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_services.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeader('Apariencia'),
          PocketCard(
            child: Column(
              children: [
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  label: 'Claro',
                  selected: mode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .set(ThemeMode.light),
                ),
                const Divider(),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: 'Oscuro',
                  selected: mode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .set(ThemeMode.dark),
                ),
                const Divider(),
                _ThemeOption(
                  icon: Icons.brightness_auto_rounded,
                  label: 'Automático (sistema)',
                  selected: mode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .set(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SectionHeader('Ayuda'),
          PocketCard(
            onTap: () => context.push('/guide'),
            child: Row(
              children: [
                const ToolIcon(
                    icon: Icons.menu_book_rounded, color: AppColors.blue),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guía de Pocket',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(
                        'Qué hace cada herramienta, cómo se usa y '
                        'compatibilidad con iPhone.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Theme.of(context).hintColor),
              ],
            ),
          ),
          const SectionHeader('Acerca de'),
          PocketCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    ToolIcon(
                        icon: Icons.bolt_rounded, color: AppColors.orange),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pocket',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('Versión 1.0.0',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  'Caja de herramientas tecnológica que reúne las '
                  'capacidades legítimas de tu smartphone: NFC, Bluetooth, '
                  'WiFi, QR, sensores y automatizaciones.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon,
          color: selected ? AppColors.orange : null, size: 28),
      title: Text(label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.orange : null,
          )),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.orange)
          : null,
      onTap: onTap,
    );
  }
}
