import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../theme/app_theme.dart';
import '../../screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _futureProfile;
  late Future<int> _futureCachedCount;

  @override
  void initState() {
    super.initState();
    _futureProfile = ApiClient.instance.fetchProfile();
    _futureCachedCount = LocalStorageService.instance.getCachedDocumentCount();
  }

  Future<void> _reload() async {
    setState(() {
      _futureProfile = ApiClient.instance.fetchProfile();
      _futureCachedCount = LocalStorageService.instance.getCachedDocumentCount();
    });
    await _futureProfile;
    await _futureCachedCount;
  }

  Future<void> _toggleAndSave({
    bool? autocomplete,
    bool? spellCorrection,
    String? defaultSort,
    bool? useLocalCache,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (autocomplete != null) payload['autocomplete'] = autocomplete;
      if (spellCorrection != null)
        payload['spell_correction'] = spellCorrection;
      if (defaultSort != null) payload['default_sort'] = defaultSort;
      if (useLocalCache != null) payload['use_local_cache'] = useLocalCache;
      await ApiClient.instance.updateProfile(payload);
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  'Failed to load profile',
                  style: TextStyle(color: AppColors.error),
                ),
              );
            }
            final fbUser = AuthService.instance.currentUser;
            final data = snapshot.data!;
            // Prioritize Firebase user data over backend profile
            final name = fbUser?.displayName?.isNotEmpty == true
                ? fbUser!.displayName!
                : (data['name'] as String? ?? 'User');
            final email = fbUser?.email?.isNotEmpty == true
                ? fbUser!.email!
                : (data['email'] as String? ?? '');
            final role = data['role'] as String? ?? 'User';
            final prefs = (data['preferences'] as Map<String, dynamic>?) ?? {};
            final storage = (data['storage'] as Map<String, dynamic>?) ?? {};

            final autocompleteEnabled = prefs['autocomplete'] as bool? ?? true;
            final spellCorrectionEnabled =
                prefs['spell_correction'] as bool? ?? true;
            final defaultSort = prefs['default_sort'] as String? ?? 'balanced';
            final useLocalCache = storage['use_local_cache'] as bool? ?? true;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: theme.textTheme.bodyLarge!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  role,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Search preferences',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: autocompleteEnabled,
                        onChanged: (v) => _toggleAndSave(autocomplete: v),
                        title: const Text(
                            'Enable autocomplete suggestions (Trie)'),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: spellCorrectionEnabled,
                        onChanged: (v) => _toggleAndSave(spellCorrection: v),
                        title: const Text(
                            'Enable spell correction (edit distance)'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Default sort'),
                        subtitle: Text(
                          defaultSort == 'pagerank'
                              ? 'PageRank'
                              : defaultSort == 'tfidf'
                                  ? 'TF‑IDF'
                                  : 'Balanced (TF‑IDF + PageRank)',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text(
                                        'Balanced (TF‑IDF + PageRank)'),
                                    onTap: () =>
                                        Navigator.pop(context, 'balanced'),
                                  ),
                                  ListTile(
                                    title: const Text('TF‑IDF'),
                                    onTap: () =>
                                        Navigator.pop(context, 'tfidf'),
                                  ),
                                  ListTile(
                                    title: const Text('PageRank'),
                                    onTap: () =>
                                        Navigator.pop(context, 'pagerank'),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (selected != null) {
                            await _toggleAndSave(defaultSort: selected);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Performance & storage',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: useLocalCache,
                        onChanged: (v) => _toggleAndSave(useLocalCache: v),
                        title: const Text('Use local cache (SQLite)'),
                        subtitle: const Text(
                            'Speed up search for frequently used docs'),
                      ),
                      const Divider(height: 1),
                      FutureBuilder<int>(
                        future: _futureCachedCount,
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return ListTile(
                            title: const Text('Indexed locally'),
                            subtitle: Text('$count documents cached'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Clear cache?'),
                                        content: const Text(
                                          'This will remove all locally cached documents. '
                                          'They can be re-downloaded from the server.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Clear'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await LocalStorageService.instance
                                          .clearCache();
                                      await _reload();
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Cache cleared'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Clear cache'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () async {
                                    // Request storage permission (for demo)
                                    final granted = await LocalStorageService
                                        .instance
                                        .requestStoragePermission();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(granted
                                            ? 'Storage permission granted'
                                            : 'Storage permission denied'),
                                      ),
                                    );
                                  },
                                  child: const Text('Request permission'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Account',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Change password'),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading:
                            const Icon(Icons.logout, color: AppColors.error),
                        title: const Text(
                          'Sign out',
                          style: TextStyle(color: AppColors.error),
                        ),
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            LoginScreen.routeName,
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
