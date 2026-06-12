import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_services.dart';
import '../../../shared/models/history_entry.dart';
import '../../../shared/widgets/pocket_button.dart';
import '../../../shared/widgets/pocket_widgets.dart';
import '../../../shared/widgets/ios_warning_banner.dart';

class WifiScreen extends ConsumerStatefulWidget {
  const WifiScreen({super.key});

  @override
  ConsumerState<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends ConsumerState<WifiScreen> {
  List<WiFiAccessPoint> _networks = [];
  bool _scanning = false;
  String? _currentSsid;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    try {
      _currentSsid = (await NetworkInfo().getWifiName())?.replaceAll('"', '');
    } catch (_) {}
    if (mounted) setState(() {});
  }

  int _channelFromFrequency(int freq) {
    if (freq >= 2412 && freq <= 2484) {
      return freq == 2484 ? 14 : (freq - 2407) ~/ 5;
    }
    if (freq >= 5170 && freq <= 5825) return (freq - 5000) ~/ 5;
    if (freq >= 5955) return (freq - 5950) ~/ 5; // 6 GHz
    return 0;
  }

  String _band(int freq) {
    if (freq < 3000) return '2.4 GHz';
    if (freq < 5950) return '5 GHz';
    return '6 GHz';
  }

  Color _levelColor(int level) {
    if (level >= -60) return AppColors.green;
    if (level >= -75) return AppColors.yellow;
    return AppColors.red;
  }

  Future<void> _scan() async {
    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'iOS no permite escanear redes WiFi cercanas. '
              'Solo se muestra la red conectada.')));
      return;
    }

    await Permission.locationWhenInUse.request();
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    if (can != CanStartScan.yes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se puede escanear: $can')));
      return;
    }

    setState(() => _scanning = true);
    await WiFiScan.instance.startScan();
    await Future.delayed(const Duration(seconds: 3));
    final results = await WiFiScan.instance.getScannedResults();
    if (!mounted) return;
    setState(() {
      _networks = results..sort((a, b) => b.level.compareTo(a.level));
      _scanning = false;
    });

    if (_networks.isNotEmpty) {
      ref.read(historyProvider.notifier).add(HistoryEntry(
            type: 'wifi',
            title: 'Escaneo WiFi: ${_networks.length} redes',
            subtitle: _networks
                .take(3)
                .map((n) => n.ssid.isEmpty ? '(oculta)' : n.ssid)
                .join(', '),
            data: {
              for (final n in _networks.take(20))
                (n.ssid.isEmpty ? n.bssid : n.ssid):
                    '${n.level} dBm · canal ${_channelFromFrequency(n.frequency)}'
            },
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WiFi Analyzer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const IosWarningBanner(
            blocking: true,
            message: 'Detectamos que usas un iPhone. El escaneo de redes '
                'WiFi cercanas NO funciona en iOS porque Apple no permite '
                'a ninguna app acceder a esa información. Solo podrás ver '
                'el nombre de la red a la que ya estás conectado.',
          ),
          PocketCard(
            color: AppColors.green.withOpacity(0.08),
            borderColor: AppColors.green.withOpacity(0.4),
            child: Row(
              children: [
                const ToolIcon(
                    icon: Icons.wifi_rounded, color: AppColors.green),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Red actual',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 13)),
                      Text(
                        _currentSsid ?? 'Sin conexión WiFi',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PocketButton(
            label: _scanning ? 'Escaneando...' : 'Escanear redes',
            icon: Icons.radar_rounded,
            color: AppColors.green,
            shadowColor: AppColors.greenDark,
            onPressed: _scanning ? null : _scan,
          ),
          if (_networks.isNotEmpty) ...[
            const SectionHeader('Intensidad de señal'),
            PocketCard(
              child: Column(
                children: _networks.take(8).map((n) {
                  // Normaliza -90..-30 dBm a 0..1
                  final strength =
                      ((n.level + 90) / 60).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                n.ssid.isEmpty ? '(red oculta)' : n.ssid,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text('${n.level} dBm',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _levelColor(n.level))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: strength,
                            minHeight: 10,
                            backgroundColor:
                                Theme.of(context).dividerColor,
                            color: _levelColor(n.level),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SectionHeader('Detalle de redes'),
            ..._networks.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PocketCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ToolIcon(
                          icon: Icons.router_rounded,
                          color: _levelColor(n.level),
                          size: 42,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.ssid.isEmpty ? '(red oculta)' : n.ssid,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${_band(n.frequency)} · canal '
                                '${_channelFromFrequency(n.frequency)} · '
                                '${n.frequency} MHz',
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
                )),
          ],
          const SizedBox(height: 8),
          const PocketCard(
            child: Text(
              'El escaneo de redes cercanas solo está disponible en Android '
              'y requiere permiso de ubicación. iOS únicamente expone la red '
              'a la que estás conectado.',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
