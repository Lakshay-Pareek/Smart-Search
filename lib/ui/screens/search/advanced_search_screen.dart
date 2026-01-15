import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdvancedSearchScreen extends StatelessWidget {
  static const String routeName = '/advanced-search';

  const AdvancedSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced search'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Query builder',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Search query',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TogglePill(label: 'Exact phrase (KMP)'),
                  _TogglePill(label: 'Contains pattern (suffix array)'),
                  _TogglePill(label: 'Fuzzy match (edit distance)'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ranking preferences',
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => const _RankingInfoSheet(),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Balanced')),
                  ButtonSegment(value: 1, label: Text('TF‑IDF focus')),
                  ButtonSegment(value: 2, label: Text('PageRank focus')),
                ],
                selected: const {0},
                onSelectionChanged: (_) {},
              ),
              const SizedBox(height: 24),
              Text(
                'Range queries (B+ tree)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Filter on numeric fields such as file size, year, or version.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Year from',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Year to',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'File size from (MB)',
                        prefixIcon: Icon(Icons.data_usage_outlined),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'File size to (MB)',
                        prefixIcon: Icon(Icons.data_thresholding_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Run advanced search'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;

  const _TogglePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: true,
      onSelected: (_) {},
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: AppColors.primaryLight,
    );
  }
}

class _RankingInfoSheet extends StatelessWidget {
  const _RankingInfoSheet();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 38,
              child: Divider(thickness: 3),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Ranking strategies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• TF‑IDF: Highlights documents with rare but important terms.\n'
            '• PageRank: Prioritizes documents that are well‑connected in the reference graph.\n'
            '• Balanced: Uses a blend of TF‑IDF and PageRank for general search.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
