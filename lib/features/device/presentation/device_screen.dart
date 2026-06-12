import 'dart:async';
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  Map<String, String> _system = {};
  Map<String, String> _hardware = {};
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;

  AccelerometerEvent? _accel;
  GyroscopeEvent? _gyro;
  MagnetometerEvent? _mag;
  final _subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    _load();
    _listenSensors();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        _system = {
          'Modelo': info.model,
          'Fabricante': info.manufacturer,
          'Marca': info.brand,
          'Android': '${info.version.release} (SDK ${info.version.sdkInt})',
          'Dispositivo': info.device,
        };
        _hardware = {
          'CPU (ABIs)': info.supportedAbis.join(', '),
          'Hardware': info.hardware,
          'Placa': info.board,
        };
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        _system = {
          'Modelo': info.utsname.machine,
          'Nombre': info.name,
          'iOS': info.systemVersion,
        };
        _hardware = {'Sistema': info.systemName};
      }
    } catch (_) {}

    try {
      final battery = Battery();
      _batteryLevel = await battery.batteryLevel;
      _batteryState = await battery.batteryState;
      _subs.add(battery.onBatteryStateChanged.listen((s) {
        if (mounted) setState(() => _batteryState = s);
      }));
    } catch (_) {}

    if (mounted) setState(() {});
  }

  void _listenSensors() {
    try {
      _subs.add(accelerometerEventStream(
              samplingPeriod: const Duration(milliseconds: 200))
          .listen((e) {
        if (mounted) setState(() => _accel = e);
      }));
      _subs.add(gyroscopeEventStream(
              samplingPeriod: const Duration(milliseconds: 200))
          .listen((e) {
        if (mounted) setState(() => _gyro = e);
      }));
      _subs.add(magnetometerEventStream(
              samplingPeriod: const Duration(milliseconds: 200))
          .listen((e) {
        if (mounted) setState(() => _mag = e);
      }));
    } catch (_) {}
  }

  String _fmt(double? v) => v?.toStringAsFixed(2) ?? '—';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Center')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Batería
          PocketCard(
            color: AppColors.orange.withOpacity(0.08),
            borderColor: AppColors.orange.withOpacity(0.4),
            child: Row(
              children: [
                ToolIcon(
                  icon: _batteryState == BatteryState.charging
                      ? Icons.battery_charging_full_rounded
                      : Icons.battery_full_rounded,
                  color: AppColors.orange,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Batería: $_batteryLevel%',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(
                        switch (_batteryState) {
                          BatteryState.charging => 'Cargando',
                          BatteryState.discharging => 'Descargando',
                          BatteryState.full => 'Carga completa',
                          BatteryState.connectedNotCharging =>
                            'Conectado, sin cargar',
                          _ => 'Estado desconocido',
                        },
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader('Sistema'),
          _InfoCard(entries: _system),
          const SectionHeader('Hardware'),
          _InfoCard(entries: _hardware),
          const SectionHeader('Sensores en vivo'),
          _SensorCard(
            name: 'Acelerómetro',
            icon: Icons.speed_rounded,
            color: AppColors.blue,
            x: _fmt(_accel?.x),
            y: _fmt(_accel?.y),
            z: _fmt(_accel?.z),
            unit: 'm/s²',
          ),
          const SizedBox(height: 10),
          _SensorCard(
            name: 'Giroscopio',
            icon: Icons.threesixty_rounded,
            color: AppColors.purple,
            x: _fmt(_gyro?.x),
            y: _fmt(_gyro?.y),
            z: _fmt(_gyro?.z),
            unit: 'rad/s',
          ),
          const SizedBox(height: 10),
          _SensorCard(
            name: 'Magnetómetro',
            icon: Icons.explore_rounded,
            color: AppColors.green,
            x: _fmt(_mag?.x),
            y: _fmt(_mag?.y),
            z: _fmt(_mag?.z),
            unit: 'µT',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.entries});

  final Map<String, String> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const PocketCard(child: Text('Cargando información...'));
    }
    return PocketCard(
      child: Column(
        children: entries.entries
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(e.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                      Expanded(
                          child: Text(e.value,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.x,
    required this.y,
    required this.z,
    required this.unit,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String x, y, z, unit;

  @override
  Widget build(BuildContext context) {
    Widget axis(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: color)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
        );

    return PocketCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ToolIcon(icon: icon, color: color, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(unit,
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(children: [axis('X', x), axis('Y', y), axis('Z', z)]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
