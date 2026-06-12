import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pocket_button.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  // UUID
  String _uuid = const Uuid().v4();

  // Contraseña
  double _length = 16;
  bool _upper = true;
  bool _lower = true;
  bool _numbers = true;
  bool _symbols = true;
  String _password = '';

  void _generatePassword() {
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const lower = 'abcdefghijkmnopqrstuvwxyz';
    const numbers = '23456789';
    const symbols = '!@#\$%&*()-_=+[]{}?';

    final pool = StringBuffer();
    final required = <String>[];
    final rng = Random.secure();

    void include(bool flag, String chars) {
      if (flag) {
        pool.write(chars);
        required.add(chars[rng.nextInt(chars.length)]);
      }
    }

    include(_upper, upper);
    include(_lower, lower);
    include(_numbers, numbers);
    include(_symbols, symbols);

    if (pool.isEmpty) {
      setState(() => _password = '');
      return;
    }

    final chars = pool.toString();
    final len = _length.round();
    final result = List.generate(
        len - required.length, (_) => chars[rng.nextInt(chars.length)])
      ..addAll(required)
      ..shuffle(rng);

    setState(() => _password = result.join());
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copiado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generadores')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ----- UUID -----
          const SectionHeader('UUID v4'),
          PocketCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(_uuid,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PocketButton(
                        label: 'Nuevo',
                        icon: Icons.refresh_rounded,
                        color: AppColors.purple,
                        shadowColor: AppColors.purpleDark,
                        onPressed: () =>
                            setState(() => _uuid = const Uuid().v4()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PocketButton(
                        label: 'Copiar',
                        icon: Icons.copy_rounded,
                        color: AppColors.green,
                        onPressed: () => _copy(_uuid),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ----- Contraseñas -----
          const SectionHeader('Contraseña segura'),
          PocketCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Longitud',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    Text('${_length.round()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.orange,
                            fontSize: 18)),
                  ],
                ),
                Slider(
                  value: _length,
                  min: 8,
                  max: 64,
                  divisions: 56,
                  activeColor: AppColors.orange,
                  onChanged: (v) => setState(() => _length = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mayúsculas (A-Z)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  value: _upper,
                  activeColor: AppColors.green,
                  onChanged: (v) => setState(() => _upper = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Minúsculas (a-z)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  value: _lower,
                  activeColor: AppColors.green,
                  onChanged: (v) => setState(() => _lower = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Números (0-9)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  value: _numbers,
                  activeColor: AppColors.green,
                  onChanged: (v) => setState(() => _numbers = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Símbolos (!@#...)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  value: _symbols,
                  activeColor: AppColors.green,
                  onChanged: (v) => setState(() => _symbols = v),
                ),
                const SizedBox(height: 8),
                PocketButton(
                  label: 'Generar contraseña',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _generatePassword,
                ),
                if (_password.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.orangeSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SelectableText(
                      _password,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PocketButton(
                    label: 'Copiar',
                    icon: Icons.copy_rounded,
                    color: AppColors.green,
                    onPressed: () => _copy(_password),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
