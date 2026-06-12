import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_services.dart';
import '../../../shared/models/history_entry.dart';
import '../../../shared/widgets/pocket_button.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QR Toolkit'),
          bottom: const TabBar(tabs: [
            Tab(text: 'ESCANEAR', icon: Icon(Icons.qr_code_scanner_rounded)),
            Tab(text: 'GENERAR', icon: Icon(Icons.qr_code_2_rounded)),
          ]),
        ),
        body: const TabBarView(
          children: [_ScannerTab(), _GeneratorTab()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ESCÁNER
// ---------------------------------------------------------------------------

class _ScannerTab extends ConsumerStatefulWidget {
  const _ScannerTab();

  @override
  ConsumerState<_ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends ConsumerState<_ScannerTab> {
  final _controller = MobileScannerController();
  String? _lastValue;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value == _lastValue) return;
    setState(() => _lastValue = value);
    HapticFeedback.mediumImpact();
    ref.read(historyProvider.notifier).add(HistoryEntry(
          type: 'qr',
          title: 'QR escaneado',
          subtitle: value,
          data: {'valor': value},
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
            ),
          ),
        ),
        if (_lastValue != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: PocketCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RESULTADO',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  SelectableText(_lastValue!,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PocketButton(
                          label: 'Copiar',
                          icon: Icons.copy_rounded,
                          color: AppColors.blue,
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _lastValue!));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copiado')));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PocketButton(
                          label: 'Compartir',
                          icon: Icons.ios_share_rounded,
                          color: AppColors.green,
                          onPressed: () => Share.share(_lastValue!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// GENERADOR
// ---------------------------------------------------------------------------

enum _QrType { texto, url, contacto, wifi, evento }

class _GeneratorTab extends StatefulWidget {
  const _GeneratorTab();

  @override
  State<_GeneratorTab> createState() => _GeneratorTabState();
}

class _GeneratorTabState extends State<_GeneratorTab> {
  _QrType _type = _QrType.texto;
  final _fields = <String, TextEditingController>{};
  String? _qrData;

  TextEditingController _field(String key) =>
      _fields.putIfAbsent(key, () => TextEditingController());

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<(String, String)> get _currentFields => switch (_type) {
        _QrType.texto => [('texto', 'Texto')],
        _QrType.url => [('url', 'URL (https://...)')],
        _QrType.contacto => [
            ('nombre', 'Nombre'),
            ('telefono', 'Teléfono'),
            ('email', 'Email'),
          ],
        _QrType.wifi => [
            ('ssid', 'Nombre de la red (SSID)'),
            ('password', 'Contraseña'),
          ],
        _QrType.evento => [
            ('titulo', 'Título del evento'),
            ('lugar', 'Lugar'),
            ('fecha', 'Fecha (YYYYMMDD)'),
          ],
      };

  void _generate() {
    String esc(String s) => s
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,');

    final data = switch (_type) {
      _QrType.texto => _field('texto').text,
      _QrType.url => _field('url').text,
      _QrType.contacto => 'BEGIN:VCARD\nVERSION:3.0\n'
          'FN:${_field('nombre').text}\n'
          'TEL:${_field('telefono').text}\n'
          'EMAIL:${_field('email').text}\nEND:VCARD',
      _QrType.wifi =>
        'WIFI:T:WPA;S:${esc(_field('ssid').text)};P:${esc(_field('password').text)};;',
      _QrType.evento => 'BEGIN:VEVENT\n'
          'SUMMARY:${_field('titulo').text}\n'
          'LOCATION:${_field('lugar').text}\n'
          'DTSTART:${_field('fecha').text}\nEND:VEVENT',
    };

    if (data.trim().isEmpty) return;
    setState(() => _qrData = data);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _QrType.values.map((t) {
            final selected = t == _type;
            return ChoiceChip(
              label: Text(
                t.name[0].toUpperCase() + t.name.substring(1),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : null,
                ),
              ),
              selected: selected,
              selectedColor: AppColors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onSelected: (_) => setState(() {
                _type = t;
                _qrData = null;
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        for (final (key, label) in _currentFields)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _field(key),
              decoration: InputDecoration(labelText: label),
            ),
          ),
        PocketButton(
          label: 'Generar QR',
          icon: Icons.qr_code_2_rounded,
          onPressed: _generate,
        ),
        if (_qrData != null) ...[
          const SizedBox(height: 24),
          PocketCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: _qrData!,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                PocketButton(
                  label: 'Compartir contenido',
                  icon: Icons.ios_share_rounded,
                  color: AppColors.green,
                  onPressed: () => Share.share(_qrData!),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
