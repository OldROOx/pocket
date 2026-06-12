import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/tools_catalog.dart';
import '../../../services/app_services.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _nfcAvailable = false;
  bool _bluetoothOn = false;
  String? _wifiName;
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      _nfcAvailable = await NfcManager.instance.isAvailable();
    } catch (_) {}
    try {
      _bluetoothOn =
          await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
    } catch (_) {}
    try {
      _wifiName = await NetworkInfo().getWifiName();
    } catch (_) {}
    try {
      final battery = Battery();
      _batteryLevel = await battery.batteryLevel;
      _batteryState = await battery.batteryState;
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider).take(5).toList();
    final favoriteTools =
        favorites.map(toolById).whereType<ToolInfo>().toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStatus,
        color: AppColors.orange,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const SizedBox(height: 8),
            _Header(),
            const SizedBox(height: 20),
            // --- Acceso a la guía ---
            PocketCard(
              onTap: () => context.push('/guide'),
              color: AppColors.blue.withOpacity(0.08),
              borderColor: AppColors.blue.withOpacity(0.4),
              child: Row(
                children: [
                  const ToolIcon(
                      icon: Icons.menu_book_rounded, color: AppColors.blue),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¿Nuevo en Pocket?',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15)),
                        Text(
                          'Mira qué hace cada herramienta y cómo usarla.',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Theme.of(context).hintColor),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // --- Estado del dispositivo ---
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    icon: Icons.nfc_rounded,
                    label: 'NFC',
                    color: AppColors.blue,
                    active: _nfcAvailable,
                    detail: _nfcAvailable ? 'Disponible' : 'No disponible',
                    onTap: () => context.push('/nfc'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    icon: Icons.bluetooth_rounded,
                    label: 'Bluetooth',
                    color: AppColors.purple,
                    active: _bluetoothOn,
                    detail: _bluetoothOn ? 'Encendido' : 'Apagado',
                    onTap: () => context.push('/bluetooth'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    icon: Icons.wifi_rounded,
                    label: 'WiFi',
                    color: AppColors.green,
                    active: _wifiName != null,
                    detail: _wifiName?.replaceAll('"', '') ?? 'Sin conexión',
                    onTap: () => context.push('/wifi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    icon: _batteryState == BatteryState.charging
                        ? Icons.battery_charging_full_rounded
                        : Icons.battery_full_rounded,
                    label: 'Batería',
                    color: AppColors.orange,
                    active: _batteryLevel > 20,
                    detail: '$_batteryLevel%',
                    onTap: () => context.push('/device'),
                  ),
                ),
              ],
            ),
            // --- Favoritos ---
            if (favoriteTools.isNotEmpty) ...[
              const SectionHeader('Favoritos'),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: favoriteTools.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final tool = favoriteTools[i];
                    return SizedBox(
                      width: 130,
                      child: PocketCard(
                        onTap: () => context.push(tool.route),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ToolIcon(icon: tool.icon, color: tool.color, size: 42),
                            const Spacer(),
                            Text(
                              tool.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            // --- Acceso rápido a herramientas ---
            const SectionHeader('Herramientas'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: tools.take(6).map((tool) {
                return PocketCard(
                  onTap: () => context.push(tool.route),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ToolIcon(icon: tool.icon, color: tool.color, size: 44),
                      const Spacer(),
                      Text(
                        tool.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                    delay: (60 * tools.indexOf(tool)).ms, duration: 300.ms);
              }).toList(),
            ),
            // --- Actividad reciente ---
            const SectionHeader('Actividad reciente'),
            if (history.isEmpty)
              const PocketCard(
                child: Text(
                  'Aún no hay actividad. Usa una herramienta para empezar.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            else
              Column(
                children: history.map((entry) {
                  final tool = toolById(entry.type);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PocketCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ToolIcon(
                            icon: tool?.icon ?? Icons.history_rounded,
                            color: tool?.color ?? AppColors.blue,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                Text(
                                  DateFormat('dd MMM · HH:mm')
                                      .format(entry.date),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA733), AppColors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.orangeDeep, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Pocket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tu caja de herramientas tecnológica',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 56),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PocketCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ToolIcon(icon: icon, color: color, size: 38),
              StatusChip(active: active),
            ],
          ),
          const SizedBox(height: 10),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
