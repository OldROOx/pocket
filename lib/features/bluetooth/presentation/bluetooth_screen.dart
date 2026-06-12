import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_services.dart';
import '../../../shared/models/history_entry.dart';
import '../../../shared/widgets/pocket_button.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class BluetoothScreen extends ConsumerStatefulWidget {
  const BluetoothScreen({super.key});

  @override
  ConsumerState<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends ConsumerState<BluetoothScreen> {
  StreamSubscription<List<ScanResult>>? _sub;
  List<ScanResult> _results = [];
  bool _scanning = false;

  @override
  void dispose() {
    _sub?.cancel();
    FlutterBluePlus.stopScan().catchError((_) {});
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  Future<void> _scan() async {
    if (!await _requestPermissions()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Se requieren permisos de Bluetooth y ubicación')));
      return;
    }

    setState(() {
      _results = [];
      _scanning = true;
    });

    _sub?.cancel();
    _sub = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        _results = List.of(results)
          ..sort((a, b) => b.rssi.compareTo(a.rssi));
      });
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      await FlutterBluePlus.isScanning.where((s) => s == false).first;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al escanear: $e')));
      }
    }

    if (!mounted) return;
    setState(() => _scanning = false);

    if (_results.isNotEmpty) {
      ref.read(historyProvider.notifier).add(HistoryEntry(
            type: 'bluetooth',
            title: 'Escaneo BLE: ${_results.length} dispositivos',
            subtitle:
                _results.take(3).map(_displayName).join(', '),
            data: {
              for (final r in _results.take(20))
                r.device.remoteId.str: '${_displayName(r)} (${r.rssi} dBm)'
            },
          ));
    }
  }

  String _displayName(ScanResult r) {
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    if (r.advertisementData.advName.isNotEmpty) {
      return r.advertisementData.advName;
    }
    return 'Dispositivo sin nombre';
  }

  Color _rssiColor(int rssi) {
    if (rssi >= -60) return AppColors.green;
    if (rssi >= -80) return AppColors.yellow;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Center')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: PocketButton(
              label: _scanning ? 'Escaneando...' : 'Escanear dispositivos',
              icon: Icons.radar_rounded,
              color: AppColors.purple,
              shadowColor: AppColors.purpleDark,
              onPressed: _scanning ? null : _scan,
            ),
          ),
          if (_scanning) const LinearProgressIndicator(color: AppColors.purple),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      _scanning
                          ? 'Buscando dispositivos cercanos...'
                          : 'Presiona escanear para buscar\ndispositivos BLE cercanos',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final r = _results[i];
                      return PocketCard(
                        onTap: () => _showDetails(r),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ToolIcon(
                              icon: Icons.bluetooth_rounded,
                              color: _rssiColor(r.rssi),
                              size: 44,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayName(r),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    r.device.remoteId.str,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${r.rssi} dBm',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _rssiColor(r.rssi),
                                  ),
                                ),
                                Icon(Icons.signal_cellular_alt_rounded,
                                    size: 16, color: _rssiColor(r.rssi)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetails(ScanResult r) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final ad = r.advertisementData;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_displayName(r),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _row('ID', r.device.remoteId.str),
              _row('RSSI', '${r.rssi} dBm'),
              _row('Conectable', ad.connectable ? 'Sí' : 'No'),
              _row('TX Power', ad.txPowerLevel?.toString() ?? 'N/D'),
              _row(
                'Servicios',
                ad.serviceUuids.isEmpty
                    ? 'Ninguno anunciado'
                    : ad.serviceUuids.map((u) => u.str).join('\n'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            Expanded(child: SelectableText(value)),
          ],
        ),
      );
}
