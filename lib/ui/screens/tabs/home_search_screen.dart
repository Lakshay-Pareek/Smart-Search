import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../services/local_storage_service.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/search_widgets.dart';
import '../search/document_detail_screen.dart';
import '../search/advanced_search_screen.dart';

class HomeSearchScreen extends StatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _hasSearched = true;
      _loading = true;
    });
    try {
      final results = await ApiClient.instance.search(query, topK: 10);
      if (!mounted) return;

      // Cache results locally for offline access
      for (final doc in results) {
        await LocalStorageService.instance.cacheDocument(doc);
      }

      // Save search to local history
      await LocalStorageService.instance.saveSearchHistory(
        query,
        results.length,
      );

      setState(() {
        _results = results;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const _AdvancedFiltersSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Search'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AdvancedSearchScreen.routeName);
            },
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Advanced search',
          ),
          const SizedBox(width: 4),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.person_outline,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              HeroSearchBar(
                controller: _searchController,
                onSearch: _performSearch,
                onOpenFilters: _openFilters,
              ),
              const SizedBox(height: 12),
              Text(
                'Suggestions',
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SuggestionChip(label: "Recent: 'Q4 financial report'"),
                  _SuggestionChip(label: "Recent: 'KMP algorithm notes'"),
                  _SuggestionChip(label: "Try: 'contracts signed in 2023'"),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    FilterChipOption(
                      label: 'All',
                      selected: true,
                      onTap: _noop,
                    ),
                    SizedBox(width: 8),
                    FilterChipOption(
                      label: 'PDF',
                      selected: false,
                      onTap: _noop,
                    ),
                    SizedBox(width: 8),
                    FilterChipOption(
                      label: 'Docs',
                      selected: false,
                      onTap: _noop,
                    ),
                    SizedBox(width: 8),
                    FilterChipOption(
                      label: 'Highly relevant (TF‑IDF)',
                      selected: false,
                      onTap: _noop,
                    ),
                    SizedBox(width: 8),
                    FilterChipOption(
                      label: 'Recent',
                      selected: false,
                      onTap: _noop,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: !_hasSearched
                    ? _EmptySearchState(onSearch: _performSearch)
                    : _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _results.isEmpty
                            ? const Center(
                                child: Text(
                                  'No documents found for this query.',
                                  style:
                                      TextStyle(color: AppColors.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _results.length,
                                itemBuilder: (context, index) {
                                  final item = _results[index];
                                  final title =
                                      item['title'] as String? ?? 'Untitled';
                                  final snippet =
                                      item['snippet'] as String? ?? '';
                                  final source =
                                      item['source'] as String? ?? '';
                                  final updatedAt =
                                      item['updated_at'] as String? ?? '';
                                  final score = (item['score'] as num?)
                                          ?.toStringAsFixed(2) ??
                                      '';
                                  final meta =
                                      '$source · $updatedAt · Score $score';
                                  final tags = <String>[];
                                  if (item['document_type'] != null) {
                                    tags.add((item['document_type'] as String));
                                  }
                                  return DocumentListItem(
                                    title: title,
                                    snippet: snippet,
                                    meta: meta,
                                    tags: tags,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        DocumentDetailScreen.routeName,
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _noop() {}

class _SuggestionChip extends StatelessWidget {
  final String label;

  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final VoidCallback onSearch;

  const _EmptySearchState({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              color: AppColors.primary,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Search smarter, not harder',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start typing a query to search across all your documents\nwith autocomplete, spell correction, and ranking.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onSearch,
            child: const Text('See sample results'),
          ),
        ],
      ),
    );
  }
}

class _AdvancedFiltersSheet extends StatelessWidget {
  const _AdvancedFiltersSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'Filters',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date from',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date to',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Tags / categories',
                prefixIcon: Icon(Icons.sell_outlined),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Sort by',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'relevance',
                  child: Text('Relevance (TF‑IDF)'),
                ),
                DropdownMenuItem(
                  value: 'pagerank',
                  child: Text('PageRank'),
                ),
                DropdownMenuItem(
                  value: 'date',
                  child: Text('Date'),
                ),
                DropdownMenuItem(
                  value: 'title',
                  child: Text('Title'),
                ),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
