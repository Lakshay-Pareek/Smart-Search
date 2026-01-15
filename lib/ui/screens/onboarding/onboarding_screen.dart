import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToAuth() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                children: const [
                  _OnboardingPage(
                    title: 'Smart Document Search Engine',
                    subtitle:
                        'Instantly find the right document across millions of files with intelligent ranking.',
                    bulletChips: [
                      'Autocomplete',
                      'Spell correction',
                      'Semantic ranking',
                    ],
                  ),
                  _OnboardingPage(
                    title: 'Powered by advanced algorithms',
                    subtitle:
                        'Trie autocomplete, suffix array pattern matching, and top‑K ranking with min‑heap priority queues.',
                    bulletChips: [
                      'TF‑IDF & PageRank',
                      'KMP exact matching',
                      'Edit distance suggestions',
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _pageIndex == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _pageIndex == index
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_pageIndex == 1) {
                        _goToAuth();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(_pageIndex == 1 ? 'Get started' : 'Next'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _goToAuth,
                    child: const Text('I already have an account'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> bulletChips;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.bulletChips,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.search_rounded,
                size: 96,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.displayLarge,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bulletChips
                .map(
                  (label) => Chip(
                    label: Text(label),
                    backgroundColor: AppColors.primaryLight,
                    labelStyle: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
