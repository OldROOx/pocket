import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_services.dart';
import '../../../shared/models/history_entry.dart';
import '../../../shared/widgets/pocket_button.dart';
import '../../../shared/widgets/pocket_widgets.dart';
import '../../../shared/widgets/ios_warning_banner.dart';

class NfcScreen extends ConsumerStatefulWidget {
  const NfcScreen({super.key});

  @override
  ConsumerState<NfcScreen> createState() => _NfcScreenState();
}

class _NfcScreenState extends ConsumerState<NfcScreen> {
  bool _available = false;
  bool _scanning = false;
  Map<String, String>? _lastRead;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      _available = await NfcManager.instance.isAvailable();
    } catch (_) {
      _available = false;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession().catchError((_) {});
    super.dispose();
  }

  String _bytesToHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');

  Future<void> _startScan() async {
    setState(() => _scanning = true);
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final info = <String, String>{};
          final rawData = tag.data;
          List<int>? identifier;
          final techs = <String>[];

          rawData.forEach((key, value) {
            techs.add(key.toString());
            if (value is Map) {
              final id = value['identifier'];
              if (id is List) {
                identifier = List<int>.from(id);
              } else if (id is Uint8List) {
                identifier = id.toList();
              }
            }
          });

          info['UID'] = identifier != null ? _bytesToHex(identifier!) : 'Desconocido';
          info['Tecnología'] = techs.join(', ');

          try {
            final ndefEntry = rawData['ndef'];
            if (ndefEntry != null && ndefEntry is Map) {
              info['Tipo'] = 'NDEF';
              final cachedMessage = ndefEntry['cachedMessage'];
              if (cachedMessage != null && cachedMessage is Map) {
                final records = cachedMessage['records'];
                if (records is List) {
                  final contents = <String>[];
                  for (final record in records) {
                    if (record is Map) {
                      final payload = record['payload'];
                      List<int>? bytes;
                      if (payload is List) bytes = List<int>.from(payload);
                      if (payload is Uint8List) bytes = payload.toList();
                      if (bytes != null) {
                        try {
                          contents.add(utf8.decode(bytes, allowMalformed: true));
                        } catch (_) {
                          contents.add(_bytesToHex(bytes));
                        }
                      }
                    }
                  }
                  if (contents.isNotEmpty) info['Contenido'] = contents.join('\n');
                }
              }
            } else {
              info['Tipo'] = 'No NDEF';
            }
          } catch (_) {
            info['Tipo'] = 'Lectura básica';
          }

          info['Fecha'] = DateTime.now().toString().substring(0, 19);

          await NfcManager.instance.stopSession();
          if (!mounted) return;
          setState(() {
            _lastRead = info;
            _scanning = false;
          });

          ref.read(historyProvider.notifier).add(HistoryEntry(
            type: 'nfc',
            title: 'Etiqueta NFC ${info['UID']}',
            subtitle: info['Tipo'] ?? '',
            data: info,
          ));
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar la lectura: $e')),
      );
    }
  }

  Future<void> _stopScan() async {
    await NfcManager.instance.stopSession().catchError((_) {});
    setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Center')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const IosWarningBanner(
            blocking: false,
            message: 'Detectamos que usas un iPhone. El NFC solo funciona '
                'en iPhone 7 o más reciente y requiere que la app se haya '
                'compilado con la capability de NFC en Xcode (cuenta de '
                'desarrollador de pago). Si no se cumple, la lectura NO va '
                'a funcionar.',
          ),
          PocketCard(
            color: AppColors.blue.withOpacity(0.08),
            borderColor: AppColors.blue.withOpacity(0.4),
            child: Column(
              children: [
                Icon(
                  _scanning ? Icons.wifi_tethering_rounded : Icons.nfc_rounded,
                  size: 80,
                  color: AppColors.blue,
                )
                    .animate(
                    onPlay: (c) => _scanning ? c.repeat() : c.stop())
                    .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: 600.ms)
                    .then()
                    .scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1, 1),
                    duration: 600.ms),
                const SizedBox(height: 12),
                Text(
                  !_available
                      ? 'NFC no disponible en este dispositivo'
                      : _scanning
                      ? 'Acerca una etiqueta NFC...'
                      : 'Listo para leer etiquetas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PocketButton(
            label: _scanning ? 'Detener' : 'Iniciar lectura',
            icon: _scanning ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: _scanning ? AppColors.red : AppColors.blue,
            onPressed:
            !_available ? null : (_scanning ? _stopScan : _startScan),
          ),
          if (_lastRead != null) ...[
            const SectionHeader('Última lectura'),
            PocketCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in _lastRead!.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                          ),
                          SelectableText(
                            entry.value,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  PocketButton(
                    label: 'Exportar',
                    icon: Icons.ios_share_rounded,
                    color: AppColors.green,
                    onPressed: () {
                      final text = _lastRead!.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join('\n');
                      Share.share(text, subject: 'Lectura NFC - Pocket');
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const PocketCard(
            child: Text(
              'En iOS la lectura usa CoreNFC y requiere iPhone 7 o '
                  'posterior. En Android funciona mientras la pantalla esté activa.',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}