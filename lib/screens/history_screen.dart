import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'package:intl/intl.dart';
import 'investigation_results_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final history = appState.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
               appState.clearHistory();
            },
          )
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No history yet.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final isError = item['isError'] == true;
                final date = item['timestamp'] as DateTime;
                final formattedDate = DateFormat('MMM d, h:mm a').format(date);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
                      child: Icon(
                        isError ? Icons.error_outline : Icons.check,
                        color: isError ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(item['query'] ?? 'Unknown Query', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${item['agent']} • $formattedDate'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvestigationResultsScreen(results: item['results']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
