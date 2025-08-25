import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/search_bar.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_grid.dart';
import '../widgets/history_chips.dart';
import '../../subscription/widgets/subscription_form.dart';
import '../../subscription/pages/subscription_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SubscriptionPage(),
              ),
            ),
            tooltip: 'Email Subscription',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           AppBar().preferredSize.height,
              ),
              child: isDesktop
                  ? _DesktopLayout()
                  : isTablet
                      ? _TabletLayout()
                      : _MobileLayout(),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar - Search form
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const _SearchSection(),
              const SizedBox(height: 24),
              const HistoryChips(),
              const SizedBox(height: 24),
              const SubscriptionForm(),
            ],
          ),
        ),
        
        const SizedBox(width: 32),
        
        // Right content - Weather display
        Expanded(
          flex: 2,
          child: Column(
            children: [
              const CurrentWeatherCard(),
              const SizedBox(height: 32),
              const ForecastGrid(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top section - Search and current weather
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left - Search form
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const _SearchSection(),
                  const SizedBox(height: 16),
                  const HistoryChips(),
                ],
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Right - Current weather
            Expanded(
              flex: 1,
              child: const CurrentWeatherCard(),
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Forecast section
        const ForecastGrid(),
        
        const SizedBox(height: 32),
        
        // Subscription form
        const SubscriptionForm(),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search section
        const _SearchSection(),
        
        const SizedBox(height: 16),
        
        // History chips
        const HistoryChips(),
        
        const SizedBox(height: 24),
        
        // Current weather card
        const CurrentWeatherCard(),
        
        const SizedBox(height: 24),
        
        // Forecast grid
        const ForecastGrid(),
        
        const SizedBox(height: 24),
        
        // Subscription form
        const SubscriptionForm(),
      ],
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a City Name',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const WeatherSearchBar(),
          ],
        ),
      ),
    );
  }
}
