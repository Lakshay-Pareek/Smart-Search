import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../theme/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _segmentIndex = 0;
  bool _gridView = false;
  late Future<List<Map<String, dynamic>>> _futureDocuments;

  @override
  void initState() {
    super.initState();
    _futureDocuments = ApiClient.instance.fetchDocuments();
  }

  Future<void> _reload() async {
    setState(() {
      _futureDocuments = ApiClient.instance.fetchDocuments();
    });
    await _futureDocuments;
  }

  Future<void> _showAddDocumentDialog() async {
    final titleController = TextEditingController();
    final sourceController = TextEditingController();
    final pathController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add document'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sourceController,
                  decoration: const InputDecoration(labelText: 'Source'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pathController,
                  decoration: const InputDecoration(labelText: 'Path'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content (optional, for search)',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      try {
        await ApiClient.instance.createDocument({
          'title': titleController.text.trim(),
          'content': contentController.text,
          'source': sourceController.text.trim().isEmpty
              ? null
              : sourceController.text.trim(),
          'path': pathController.text.trim().isEmpty
              ? null
              : pathController.text.trim(),
        });
        await _reload();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add document: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: Icon(_gridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _gridView = !_gridView;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('All'),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Starred'),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('Recently opened'),
                  ),
                ],
                selected: {_segmentIndex},
                onSelectionChanged: (value) {
                  setState(() {
                    _segmentIndex = value.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _futureDocuments,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Failed to load documents',
                          style: TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    final documents = snapshot.data ?? [];
                    if (documents.isEmpty) {
                      return const Center(
                        child: Text(
                          'No documents yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    if (_gridView) {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          return _LibraryCard(doc: doc);
                        },
                      );
                    }
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        return _LibraryListTile(doc: doc);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDocumentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add document'),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final Map<String, dynamic> doc;

  const _LibraryCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (doc['title'] as String?) ?? 'Untitled',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              (doc['path'] as String?) ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (doc['source'] as String?) ?? '',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryListTile extends StatelessWidget {
  final Map<String, dynamic> doc;

  const _LibraryListTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.insert_drive_file_outlined,
          color: AppColors.primary),
      title: Text((doc['title'] as String?) ?? 'Untitled'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (doc['path'] as String?) ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            (doc['source'] as String?) ?? '',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.star_border),
        onPressed: () {},
      ),
      onTap: () {},
    );
  }
}
