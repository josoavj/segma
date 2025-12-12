import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/services/log_service.dart';

final logsProvider = FutureProvider<List<LogEntry>>((ref) async {
  return logService.getAllLogs();
});

final logFilterProvider = StateProvider<String>((ref) => '');
final logLevelFilterProvider = StateProvider<String?>((ref) => null);

class LogsPage extends ConsumerWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsProvider);
    final searchFilter = ref.watch(logFilterProvider);
    final levelFilter = ref.watch(logLevelFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header avec gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextField(
                  onChanged: (value) {
                    ref.read(logFilterProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher dans les logs...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                // Filter buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tous'),
                        selected: levelFilter == null,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(logLevelFilterProvider.notifier).state =
                                null;
                          }
                        },
                        backgroundColor: Colors.blue[600]!.withValues(
                          alpha: 0.3,
                        ),
                        selectedColor: Colors.blue[600]!,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('INFO'),
                        selected: levelFilter == 'INFO',
                        onSelected: (selected) {
                          ref.read(logLevelFilterProvider.notifier).state =
                              selected ? 'INFO' : null;
                        },
                        backgroundColor: Colors.lightBlue.withValues(
                          alpha: 0.3,
                        ),
                        selectedColor: Colors.lightBlue[700]!,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('WARNING'),
                        selected: levelFilter == 'WARNING',
                        onSelected: (selected) {
                          ref.read(logLevelFilterProvider.notifier).state =
                              selected ? 'WARNING' : null;
                        },
                        backgroundColor: Colors.orange.withValues(alpha: 0.3),
                        selectedColor: Colors.orange[700]!,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('ERROR'),
                        selected: levelFilter == 'ERROR',
                        onSelected: (selected) {
                          ref.read(logLevelFilterProvider.notifier).state =
                              selected ? 'ERROR' : null;
                        },
                        backgroundColor: Colors.red.withValues(alpha: 0.3),
                        selectedColor: Colors.red[700]!,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                // Filter logs
                final filteredLogs = logs.where((log) {
                  final matchesSearch = log.message.toLowerCase().contains(
                    searchFilter.toLowerCase(),
                  );
                  final matchesLevel =
                      levelFilter == null || log.level == levelFilter;
                  return matchesSearch && matchesLevel;
                }).toList();

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun log disponible',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[filteredLogs.length - 1 - index];
                    return _LogEntryWidget(logEntry: log);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur: $error',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.red[400]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogEntryWidget extends StatelessWidget {
  final LogEntry logEntry;

  const _LogEntryWidget({required this.logEntry});

  Color _getLevelColor() {
    switch (logEntry.level) {
      case 'DEBUG':
        return Colors.grey;
      case 'INFO':
        return Colors.blue;
      case 'WARNING':
        return Colors.orange;
      case 'ERROR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon() {
    switch (logEntry.level) {
      case 'DEBUG':
        return Icons.bug_report;
      case 'INFO':
        return Icons.info;
      case 'WARNING':
        return Icons.warning;
      case 'ERROR':
        return Icons.error;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getLevelColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getLevelIcon(), color: _getLevelColor(), size: 20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getLevelColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                logEntry.level,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _getLevelColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              logEntry.timestamp,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Text(
          logEntry.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  logEntry.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                ),
                if (logEntry.stackTrace != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Stack Trace:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      logEntry.stackTrace!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
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
