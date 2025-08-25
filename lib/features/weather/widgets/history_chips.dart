import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/weather_providers.dart';

class HistoryChips extends ConsumerWidget {
  const HistoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(searchHistoryProvider);
    
    return historyAsync.when(
      data: (history) => history.isNotEmpty
          ? _HistoryContent(history: history)
          : const SizedBox.shrink(),
      loading: () => _HistoryLoadingSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HistoryContent extends ConsumerWidget {
  final List history;
  
  const _HistoryContent({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with clear button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showClearHistoryDialog(context, ref),
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // History chips
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: history.map((search) {
            return _HistoryChip(
              search: search,
              onTap: () => _onHistoryTap(ref, search.city),
              onRemove: () => _onRemoveHistory(ref, search.city),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  void _onHistoryTap(WidgetRef ref, String city) {
    // Clear any existing error
    ref.read(errorMessageProvider.notifier).state = null;
    
    // Perform search
    ref.read(currentWeatherProvider.notifier).getCurrentWeather(city);
    ref.read(forecastWeatherProvider.notifier).getForecastWeather(
      city,
      days: ref.read(forecastDaysProvider),
    );
  }

  void _onRemoveHistory(WidgetRef ref, String city) {
    ref.read(searchHistoryProvider.notifier).removeSearchFromHistory(city);
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text(
          'Are you sure you want to clear all search history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(searchHistoryProvider.notifier).clearHistory();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  final dynamic search;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  
  const _HistoryChip({
    required this.search,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(
        search.displayName,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: onTap,
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.white
          : AppColors.cardGray.withOpacity(0.3),
      side: BorderSide(
        color: AppColors.primaryBlue.withOpacity(0.3),
        width: 1,
      ),
      labelStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.black
            : AppColors.white,
      ),
      deleteIconColor: AppColors.textSecondary,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _HistoryLoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 16,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Chips skeleton
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: List.generate(3, (index) {
            return Container(
              height: 32,
              width: 80 + (index * 20), // Vary widths
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }
}
