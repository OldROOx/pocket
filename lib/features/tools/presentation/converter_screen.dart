import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pocket_button.dart';
import '../../../shared/widgets/pocket_widgets.dart';

enum _Format { texto, hex, base64, binario, decimal }

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _input = TextEditingController();
  _Format _from = _Format.texto;
  _Format _to = _Format.hex;
  String _output = '';
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  /// Convierte la entrada a bytes según el formato de origen.
  List<int> _toBytes(String input, _Format format) {
    final clean = input.trim();
    switch (format) {
      case _Format.texto:
        return utf8.encode(clean);
      case _Format.hex:
        final hex = clean.replaceAll(RegExp(r'[\s:,-]'), '');
        if (hex.length.isOdd || !RegExp(r'^[0-9a-fA-F]*$').hasMatch(hex)) {
          throw const FormatException('HEX inválido');
        }
        return [
          for (var i = 0; i < hex.length; i += 2)
            int.parse(hex.substring(i, i + 2), radix: 16)
        ];
      case _Format.base64:
        return base64.decode(base64.normalize(clean));
      case _Format.binario:
        final groups = clean.split(RegExp(r'\s+'));
        return [
          for (final g in groups)
            if (g.isNotEmpty) int.parse(g, radix: 2)
        ];
      case _Format.decimal:
        final groups = clean.split(RegExp(r'[\s,]+'));
        return [
          for (final g in groups)
            if (g.isNotEmpty) int.parse(g)
        ];
    }
  }

  /// Convierte bytes al formato de destino.
  String _fromBytes(List<int> bytes, _Format format) {
    switch (format) {
      case _Format.texto:
        return utf8.decode(bytes, allowMalformed: true);
      case _Format.hex:
        return bytes
            .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
            .join(' ');
      case _Format.base64:
        return base64.encode(bytes);
      case _Format.binario:
        return bytes
            .map((b) => b.toRadixString(2).padLeft(8, '0'))
            .join(' ');
      case _Format.decimal:
        return bytes.join(' ');
    }
  }

  void _convert() {
    setState(() {
      _error = null;
      _output = '';
    });
    if (_input.text.trim().isEmpty) return;
    try {
      final bytes = _toBytes(_input.text, _from);
      setState(() => _output = _fromBytes(bytes, _to));
    } catch (e) {
      setState(() => _error = 'Entrada inválida para el formato '
          '${_from.name.toUpperCase()}');
    }
  }

  Widget _formatSelector(
      String label, _Format value, void Function(_Format) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _Format.values.map((f) {
            final selected = f == value;
            return ChoiceChip(
              label: Text(
                f.name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: selected ? Colors.white : null,
                ),
              ),
              selected: selected,
              selectedColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (_) => onChanged(f),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversores')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _formatSelector('DE...', _from, (f) => setState(() => _from = f)),
          const SizedBox(height: 16),
          _formatSelector('A...', _to, (f) => setState(() => _to = f)),
          const SizedBox(height: 16),
          TextField(
            controller: _input,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Entrada',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          PocketButton(
            label: 'Convertir',
            icon: Icons.swap_horiz_rounded,
            color: AppColors.blue,
            onPressed: _convert,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            PocketCard(
              color: AppColors.red.withOpacity(0.08),
              borderColor: AppColors.red.withOpacity(0.4),
              child: Text(_error!,
                  style: const TextStyle(
                      color: AppColors.red, fontWeight: FontWeight.w800)),
            ),
          ],
          if (_output.isNotEmpty) ...[
            const SectionHeader('Resultado'),
            PocketCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(_output,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  PocketButton(
                    label: 'Copiar',
                    icon: Icons.copy_rounded,
                    color: AppColors.green,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _output));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copiado')));
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
