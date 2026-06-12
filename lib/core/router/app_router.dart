import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/nfc/presentation/nfc_screen.dart';
import '../../features/bluetooth/presentation/bluetooth_screen.dart';
import '../../features/wifi/presentation/wifi_screen.dart';
import '../../features/qr/presentation/qr_screen.dart';
import '../../features/device/presentation/device_screen.dart';
import '../../features/automation/presentation/automation_screen.dart';
import '../../features/tools/presentation/tools_screen.dart';
import '../../features/tools/presentation/converter_screen.dart';
import '../../features/tools/presentation/generator_screen.dart';
import '../../features/tools/presentation/text_tools_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/guide/presentation/guide_screen.dart';
import '../theme/app_colors.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/tools',
            builder: (_, __) => const ToolsScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/history',
            builder: (_, __) => const HistoryScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ]),
      ],
    ),
    GoRoute(path: '/nfc', builder: (_, __) => const NfcScreen()),
    GoRoute(path: '/bluetooth', builder: (_, __) => const BluetoothScreen()),
    GoRoute(path: '/wifi', builder: (_, __) => const WifiScreen()),
    GoRoute(path: '/qr', builder: (_, __) => const QrScreen()),
    GoRoute(path: '/device', builder: (_, __) => const DeviceScreen()),
    GoRoute(path: '/automation', builder: (_, __) => const AutomationScreen()),
    GoRoute(path: '/tools/converter', builder: (_, __) => const ConverterScreen()),
    GoRoute(path: '/tools/generator', builder: (_, __) => const GeneratorScreen()),
    GoRoute(path: '/tools/text', builder: (_, __) => const TextToolsScreen()),
    GoRoute(path: '/guide', builder: (_, __) => const GuideScreen()),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 2),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedIndex: shell.currentIndex,
          indicatorColor: AppColors.orange.withOpacity(0.15),
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.handyman_rounded),
              label: 'Herramientas',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              label: 'Historial',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
