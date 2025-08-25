import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/forecast_day.dart';
import '../providers/weather_providers.dart';

class ForecastGrid extends ConsumerWidget {
  const ForecastGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(forecastWeatherProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Determine number of columns based on screen width
    int crossAxisCount;
    if (screenWidth >= 1024) {
      crossAxisCount = 4;
    } else if (screenWidth >= 768) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            '4-Day Forecast',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        
        // Forecast content
        forecastAsync.when(
          data: (forecast) => forecast != null
              ? _ForecastContent(
                  forecast: forecast.forecast.forecastday,
                  crossAxisCount: crossAxisCount,
                )
              : _EmptyForecastState(),
          loading: () => _ForecastLoadingSkeleton(
            crossAxisCount: crossAxisCount,
          ),
          error: (error, stack) => _ForecastErrorState(error: error),
        ),
      ],
    );
  }
}

class _ForecastContent extends ConsumerWidget {
  final List<ForecastDay> forecast;
  final int crossAxisCount;
  
  const _ForecastContent({
    required this.forecast,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Forecast grid
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Tăng chiều cao để chứa đủ content
              ),
              itemCount: forecast.length,
              itemBuilder: (context, index) {
                return _ForecastDayCard(forecastDay: forecast[index]);
              },
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Load more button
        if (forecast.length < 10)
          _LoadMoreButton(
            currentDays: forecast.length,
            onLoadMore: () => _loadMoreDays(ref),
          ),
      ],
    );
  }

  void _loadMoreDays(WidgetRef ref) {
    final currentWeather = ref.read(currentWeatherProvider).valueOrNull;
    if (currentWeather == null) return;
    
    final additionalDays = 3; // Load 3 more days
    final query = '${currentWeather.location.lat},${currentWeather.location.lon}';
    
    ref.read(forecastWeatherProvider.notifier).loadMoreForecastDays(
      query, 
      additionalDays,
    );
  }
}

class _ForecastDayCard extends StatelessWidget {
  final ForecastDay forecastDay;
  
  const _ForecastDayCard({required this.forecastDay});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardGray,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date
            Text(
              forecastDay.date,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Weather icon
            if (forecastDay.day.condition.iconUrl.isNotEmpty)
              Image.network(
                forecastDay.day.condition.iconUrl,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(
                      Icons.wb_sunny_outlined,
                      size: 40,
                      color: AppColors.white,
                    ),
              )
            else
              const Icon(
                Icons.wb_sunny_outlined,
                size: 40,
                color: AppColors.white,
              ),
            
            const SizedBox(height: 8),
            
            // Weather details
            _WeatherDetail(
              label: 'Temp',
              value: forecastDay.day.temperatureDisplay,
            ),
            const SizedBox(height: 4),
            _WeatherDetail(
              label: 'Wind',
              value: forecastDay.day.windDisplay,
            ),
            const SizedBox(height: 4),
            _WeatherDetail(
              label: 'Humidity',
              value: forecastDay.day.humidityDisplay,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final String label;
  final String value;
  
  const _WeatherDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final int currentDays;
  final VoidCallback onLoadMore;
  
  const _LoadMoreButton({
    required this.currentDays,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onLoadMore,
        icon: const Icon(Icons.expand_more),
        label: Text('Load more (showing $currentDays days)'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _EmptyForecastState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No forecast data available',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for a city to see the forecast',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastLoadingSkeleton extends StatelessWidget {
  final int crossAxisCount;
  
  const _ForecastLoadingSkeleton({required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // Tăng chiều cao để chứa đủ content
          ),
          itemCount: 4, // Show 4 skeleton cards
          itemBuilder: (context, index) {
        return Card(
          color: AppColors.cardGray,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Date skeleton
                Container(
                  height: 16,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Icon skeleton
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Details skeleton
                ...List.generate(3, (detailIndex) => Padding(
                  padding: EdgeInsets.only(bottom: detailIndex < 2 ? 6.0 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 12,
                        width: 30,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 12,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          );
        },
      );
    },
    );
  }
}

class _ForecastErrorState extends StatelessWidget {
  final Object error;
  
  const _ForecastErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load forecast',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
