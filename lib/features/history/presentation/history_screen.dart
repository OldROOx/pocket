import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/tools_catalog.dart';
import '../../../services/app_services.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _query = '';
  String? _filterType;

  static const _filters = {
    null: 'Todo',
    'nfc': 'NFC',
    'bluetooth': 'Bluetooth',
    'wifi': 'WiFi',
    'qr': 'QR',
    'automation': 'Automatización',
  };

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(historyProvider);
    final entries = all.where((e) {
      final matchesType = _filterType == null || e.type == _filterType;
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.subtitle.toLowerCase().contains(q);
      return matchesType && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Exportar',
            onPressed: entries.isEmpty
                ? null
                : () {
                    final text = entries
                        .map((e) =>
                            '[${DateFormat('yyyy-MM-dd HH:mm').format(e.date)}] '
                            '${e.type.toUpperCase()} · ${e.title}\n${e.subtitle}')
                        .join('\n\n');
                    Share.share(text, subject: 'Historial - Pocket');
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Borrar todo',
            onPressed: all.isEmpty
                ? null
                : () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        title: const Text('¿Borrar historial?'),
                        content: const Text(
                            'Se eliminarán todas las entradas. Esta acción '
                            'no se puede deshacer.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(historyProvider.notifier).clear();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Borrar',
                                style: TextStyle(color: AppColors.red)),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Buscar en el historial...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: _filters.entries.map((f) {
                final selected = f.key == _filterType;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.value,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : null,
                        )),
                    selected: selected,
                    selectedColor: AppColors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (_) =>
                        setState(() => _filterType = f.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text('Sin resultados',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final entry = entries[i];
                      final tool = toolById(entry.type);
                      return Dismissible(
                        key: ValueKey(
                            '${entry.date.toIso8601String()}-$i'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: Colors.white),
                        ),
                        onDismissed: (_) {
                          final index = ref
                              .read(historyProvider)
                              .indexOf(entry);
                          if (index >= 0) {
                            ref
                                .read(historyProvider.notifier)
                                .removeAt(index);
                          }
                        },
                        child: PocketCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () => _showDetail(entry.title, entry.data),
                          child: Row(
                            children: [
                              ToolIcon(
                                icon: tool?.icon ?? Icons.history_rounded,
                                color: tool?.color ?? AppColors.blue,
                                size: 44,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800)),
                                    Text(
                                      entry.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color),
                                    ),
                                    Text(
                                      DateFormat('dd MMM yyyy · HH:mm')
                                          .format(entry.date),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetail(String title, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(title, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            for (final e in data.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1)),
                    SelectableText('${e.value}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
