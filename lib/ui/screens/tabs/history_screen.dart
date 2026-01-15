import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = ApiClient.instance.fetchHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureHistory = ApiClient.instance.fetchHistory();
    });
    await _futureHistory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Filter history',
                  prefixIcon: Icon(Icons.search_outlined),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _futureHistory,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Failed to load history',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      );
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No search history yet',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final query = item['query'] as String? ?? '';
                        final timestamp = item['timestamp'] as String? ?? '';
                        final results = (item['results'] as num?)?.toInt() ?? 0;
                        return Dismissible(
                          key: ValueKey(item['id'] ?? query),
                          background: Container(
                            color: AppColors.error,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 24),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: AppColors.primary,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.push_pin_outlined,
                                color: Colors.white),
                          ),
                          child: ListTile(
                            title: Text(query),
                            subtitle: Text(
                              '$timestamp · $results results',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            leading: const Icon(Icons.history),
                            trailing: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _refresh,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
