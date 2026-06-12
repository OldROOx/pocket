import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/tools_catalog.dart';
import '../../../services/app_services.dart';
import '../../../shared/widgets/pocket_widgets.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Herramientas')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: tools.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final tool = tools[i];
          final isFav = favorites.contains(tool.id);
          return PocketCard(
            onTap: () => context.push(tool.route),
            child: Row(
              children: [
                ToolIcon(icon: tool.icon, color: tool.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tool.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(
                        tool.description,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFav ? AppColors.yellow : null,
                    size: 28,
                  ),
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(tool.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
