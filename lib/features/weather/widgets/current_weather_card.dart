import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/weather_response.dart';
import '../providers/weather_providers.dart';

class CurrentWeatherCard extends ConsumerWidget {
  const CurrentWeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeatherAsync = ref.watch(currentWeatherProvider);

    return Card(
      color: AppColors.primaryBlue,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 200,
        ),
        child: currentWeatherAsync.when(
          data: (weather) =>
              weather != null ? _WeatherContent(weather: weather) : _EmptyState(),
          loading: () => _LoadingSkeleton(),
          error: (error, stack) => _ErrorState(error: error),
        ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final CurrentWeatherResponse weather;

  const _WeatherContent({required this.weather});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final currentDate = dateFormat.format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${weather.location.displayName} ($currentDate)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main weather info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather icon and description
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather icon
                    if (weather.current.condition.iconUrl.isNotEmpty)
                      Image.network(
                        weather.current.condition.iconUrl,
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.wb_sunny_outlined,
                          size: 80,
                          color: AppColors.white,
                        ),
                      )
                    else
                      const Icon(
                        Icons.wb_sunny_outlined,
                        size: 80,
                        color: AppColors.white,
                      ),

                    const SizedBox(height: 8),

                    // Weather description
                    Text(
                      weather.current.condition.text,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Weather details
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WeatherDetailRow(
                      label: 'Temperature',
                      value: weather.current.temperatureDisplay,
                    ),
                    const SizedBox(height: 12),
                    _WeatherDetailRow(
                      label: 'Wind',
                      value: weather.current.windDisplay,
                    ),
                    const SizedBox(height: 12),
                    _WeatherDetailRow(
                      label: 'Humidity',
                      value: weather.current.humidityDisplay,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _WeatherDetailRow({
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 64,
            color: AppColors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for a city to see current weather',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a city name or use your current location',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location skeleton
          Container(
            height: 24,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon skeleton
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(width: 24),

              // Details skeleton
              Expanded(
                child: Column(
                  children: List.generate(
                      3,
                      (index) => Padding(
                            padding:
                                EdgeInsets.only(bottom: index < 2 ? 12.0 : 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 16,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  height: 16,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    String errorMessage = 'Failed to load weather data';

    if (error.toString().contains('not found')) {
      errorMessage = 'City not found. Please check the spelling and try again.';
    } else if (error.toString().contains('network') ||
        error.toString().contains('internet')) {
      errorMessage = 'No internet connection. Please check your network.';
    }

    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }
}
