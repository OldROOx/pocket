import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pocket_button.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class TextToolsScreen extends StatefulWidget {
  const TextToolsScreen({super.key});

  @override
  State<TextToolsScreen> createState() => _TextToolsScreenState();
}

class _TextToolsScreenState extends State<TextToolsScreen> {
  final _input = TextEditingController();
  String _formatted = '';
  String? _jsonError;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  int get _chars => _input.text.length;
  int get _charsNoSpaces => _input.text.replaceAll(RegExp(r'\s'), '').length;
  int get _words => _input.text.trim().isEmpty
      ? 0
      : _input.text.trim().split(RegExp(r'\s+')).length;
  int get _lines =>
      _input.text.isEmpty ? 0 : '\n'.allMatches(_input.text).length + 1;

  void _formatJson() {
    setState(() {
      _jsonError = null;
      _formatted = '';
    });
    try {
      final decoded = jsonDecode(_input.text);
      setState(() =>
          _formatted = const JsonEncoder.withIndent('  ').convert(decoded));
    } catch (e) {
      setState(() => _jsonError = 'JSON inválido: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Texto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _input,
            maxLines: 8,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Escribe o pega tu texto / JSON',
              alignLabelWithHint: true,
            ),
          ),
          const SectionHeader('Estadísticas'),
          Row(
            children: [
              _Stat(label: 'Caracteres', value: _chars, color: AppColors.blue),
              const SizedBox(width: 10),
              _Stat(
                  label: 'Sin espacios',
                  value: _charsNoSpaces,
                  color: AppColors.purple),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Stat(label: 'Palabras', value: _words, color: AppColors.green),
              const SizedBox(width: 10),
              _Stat(label: 'Líneas', value: _lines, color: AppColors.orange),
            ],
          ),
          const SectionHeader('Formateador JSON'),
          PocketButton(
            label: 'Formatear JSON',
            icon: Icons.data_object_rounded,
            color: AppColors.green,
            shadowColor: AppColors.greenDark,
            onPressed: _formatJson,
          ),
          if (_jsonError != null) ...[
            const SizedBox(height: 14),
            PocketCard(
              color: AppColors.red.withOpacity(0.08),
              borderColor: AppColors.red.withOpacity(0.4),
              child: Text(_jsonError!,
                  style: const TextStyle(
                      color: AppColors.red, fontWeight: FontWeight.w700)),
            ),
          ],
          if (_formatted.isNotEmpty) ...[
            const SizedBox(height: 14),
            PocketCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _formatted,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  PocketButton(
                    label: 'Copiar',
                    icon: Icons.copy_rounded,
                    color: AppColors.blue,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _formatted));
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PocketCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value',
                style: TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 24, color: color)),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
