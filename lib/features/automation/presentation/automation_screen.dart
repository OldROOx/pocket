import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_services.dart';
import '../../../shared/models/history_entry.dart';
import '../../../shared/widgets/pocket_button.dart';
import '../../../shared/widgets/pocket_widgets.dart';
import '../domain/automation_rule.dart';

// ---------------------------------------------------------------------------
// Estado de reglas
// ---------------------------------------------------------------------------

class AutomationNotifier extends StateNotifier<List<AutomationRule>> {
  AutomationNotifier() : super(_load());

  static Box get _box => Hive.box('automations');

  static List<AutomationRule> _load() {
    final raw = _box.get('rules', defaultValue: <dynamic>[]) as List;
    return raw.map((e) => AutomationRule.fromMap(e as Map)).toList();
  }

  Future<void> _save(List<AutomationRule> rules) async {
    await _box.put('rules', rules.map((r) => r.toMap()).toList());
    state = rules;
  }

  Future<void> add(AutomationRule rule) async =>
      _save([...state, rule]);

  Future<void> remove(String id) async =>
      _save(state.where((r) => r.id != id).toList());

  Future<void> toggle(String id) async => _save([
        for (final r in state)
          if (r.id == id) r.copyWith(enabled: !r.enabled) else r
      ]);
}

final automationProvider =
    StateNotifierProvider<AutomationNotifier, List<AutomationRule>>(
        (ref) => AutomationNotifier());

/// Ejecuta la acción de una regla. Devuelve true si se ejecutó.
Future<bool> executeRuleAction(
    BuildContext context, WidgetRef ref, AutomationRule rule) async {
  ref.read(historyProvider.notifier).add(HistoryEntry(
        type: 'automation',
        title: 'Automatización: ${rule.name}',
        subtitle: '${rule.triggerType} → ${rule.actionType}',
        data: rule.toMap().map((k, v) => MapEntry(k, v.toString())),
      ));

  switch (rule.actionType) {
    case 'url':
      final uri = Uri.tryParse(rule.actionValue);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    case 'mensaje':
    default:
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(rule.actionValue)));
      }
      return true;
  }
}

// ---------------------------------------------------------------------------
// Pantalla
// ---------------------------------------------------------------------------

class AutomationScreen extends ConsumerWidget {
  const AutomationScreen({super.key});

  static const triggerLabels = {
    'nfc': ('Etiqueta NFC', Icons.nfc_rounded, AppColors.blue),
    'qr': ('Código QR', Icons.qr_code_rounded, AppColors.orange),
    'hora': ('Hora del día', Icons.schedule_rounded, AppColors.purple),
  };

  static const actionLabels = {
    'url': 'Abrir URL / App',
    'mensaje': 'Mostrar mensaje',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(automationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Automation Hub')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.textDark,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('NUEVA',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: rules.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bolt_rounded,
                        size: 72, color: AppColors.yellow),
                    SizedBox(height: 12),
                    Text(
                      'Crea tu primera automatización.\n'
                      'Ejemplo: al leer una etiqueta NFC, abrir una app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: rules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final rule = rules[i];
                final (label, icon, color) =
                    triggerLabels[rule.triggerType] ??
                        ('Disparador', Icons.bolt_rounded, AppColors.yellow);
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
                            Text(rule.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            Text(
                              '$label → '
                              '${actionLabels[rule.actionType] ?? rule.actionType}',
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
                      IconButton(
                        icon: const Icon(Icons.play_circle_rounded,
                            color: AppColors.green, size: 30),
                        tooltip: 'Probar',
                        onPressed: () =>
                            executeRuleAction(context, ref, rule),
                      ),
                      Switch(
                        value: rule.enabled,
                        activeColor: AppColors.green,
                        onChanged: (_) => ref
                            .read(automationProvider.notifier)
                            .toggle(rule.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.red),
                        onPressed: () => ref
                            .read(automationProvider.notifier)
                            .remove(rule.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _RuleEditor(
        onSave: (rule) => ref.read(automationProvider.notifier).add(rule),
      ),
    );
  }
}

class _RuleEditor extends StatefulWidget {
  const _RuleEditor({required this.onSave});

  final void Function(AutomationRule) onSave;

  @override
  State<_RuleEditor> createState() => _RuleEditorState();
}

class _RuleEditorState extends State<_RuleEditor> {
  final _name = TextEditingController();
  final _triggerValue = TextEditingController();
  final _actionValue = TextEditingController();
  String _triggerType = 'nfc';
  String _actionType = 'url';

  @override
  void dispose() {
    _name.dispose();
    _triggerValue.dispose();
    _actionValue.dispose();
    super.dispose();
  }

  String get _triggerHint => switch (_triggerType) {
        'nfc' => 'UID de la etiqueta (ej. 04:A2:1B:...)',
        'qr' => 'Contenido exacto del QR',
        _ => 'Hora (ej. 08:30)',
      };

  String get _actionHint => switch (_actionType) {
        'url' => 'URL o deep link (ej. https://..., spotify://)',
        _ => 'Texto del mensaje',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nueva automatización',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            const Text('CUANDO...',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'nfc', label: Text('NFC')),
                ButtonSegment(value: 'qr', label: Text('QR')),
                ButtonSegment(value: 'hora', label: Text('Hora')),
              ],
              selected: {_triggerType},
              onSelectionChanged: (s) =>
                  setState(() => _triggerType = s.first),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _triggerValue,
              decoration: InputDecoration(labelText: _triggerHint),
            ),
            const SizedBox(height: 16),
            const Text('ENTONCES...',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'url', label: Text('Abrir URL')),
                ButtonSegment(value: 'mensaje', label: Text('Mensaje')),
              ],
              selected: {_actionType},
              onSelectionChanged: (s) =>
                  setState(() => _actionType = s.first),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _actionValue,
              decoration: InputDecoration(labelText: _actionHint),
            ),
            const SizedBox(height: 20),
            PocketButton(
              label: 'Guardar',
              icon: Icons.check_rounded,
              color: AppColors.green,
              onPressed: () {
                if (_name.text.trim().isEmpty ||
                    _actionValue.text.trim().isEmpty) {
                  return;
                }
                widget.onSave(AutomationRule(
                  id: const Uuid().v4(),
                  name: _name.text.trim(),
                  triggerType: _triggerType,
                  triggerValue: _triggerValue.text.trim(),
                  actionType: _actionType,
                  actionValue: _actionValue.text.trim(),
                ));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
