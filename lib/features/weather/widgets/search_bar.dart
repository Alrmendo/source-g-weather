import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/weather_providers.dart';
import '../../../data/services/location_service.dart';

class WeatherSearchBar extends ConsumerStatefulWidget {
  const WeatherSearchBar({super.key});

  @override
  ConsumerState<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends ConsumerState<WeatherSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  final _locationService = LocationService();
  bool _isDisposed = false;
  bool _showSuggestions = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Listen to focus changes with delay to allow clicks
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Add delay to allow suggestion clicks to register
        Timer(const Duration(milliseconds: 150), () {
          if (!_focusNode.hasFocus) {
            _hideSuggestions();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _hideSuggestions();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_isDisposed) return;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Update search query state
    if (mounted) {
      ref.read(searchQueryProvider.notifier).state = query;
    }

    // Show suggestions if query is not empty and has focus
    if (query.trim().isNotEmpty && _focusNode.hasFocus) {
      // Get location suggestions
      ref
          .read(locationSuggestionsProvider.notifier)
          .getLocationSuggestions(query);
      // Delay showing overlay to avoid build phase issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showSuggestionsOverlay();
        }
      });
    } else {
      _hideSuggestions();
      ref.read(locationSuggestionsProvider.notifier).clearSuggestions();
    }
  }

  void _showSuggestionsOverlay() {
    if (_overlayEntry != null) return;
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {}, // Prevent overlay from closing on tap
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0.0, 60.0),
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(8.0),
                  clipBehavior: Clip.hardEdge,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final suggestionsAsync =
                          ref.watch(locationSuggestionsProvider);

                      return suggestionsAsync.when(
                        data: (suggestions) {
                          if (suggestions.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              itemCount: suggestions.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final suggestion = suggestions[index];
                                return InkWell(
                                  onTap: () {
                                    print(
                                        'Suggestion tapped: $suggestion'); // Debug
                                    _onSuggestionSelected(suggestion);
                                  },
                                  hoverColor:
                                      AppColors.primaryBlue.withOpacity(0.1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 20,
                                          color: AppColors.primaryBlue,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            suggestion,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.north_west,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Searching locations...'),
                            ],
                          ),
                        ),
                        error: (error, stack) => const SizedBox.shrink(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay?.insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSuggestionSelected(String suggestion) {
    print('_onSuggestionSelected called with: $suggestion'); // Debug

    // Update text field
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );

    // Hide suggestions immediately
    _hideSuggestions();

    // Clear suggestions from provider
    ref.read(locationSuggestionsProvider.notifier).clearSuggestions();

    // Unfocus to hide keyboard
    _focusNode.unfocus();

    // Perform search with selected suggestion
    _performSearch(suggestion);
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _hideSuggestions();
      _focusNode.unfocus();
      _performSearch(query.trim());
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty || _isDisposed || !mounted) return;

    try {
      // Clear any existing error
      ref.read(errorMessageProvider.notifier).state = null;

      // Perform search for both current weather and forecast
      ref.read(currentWeatherProvider.notifier).getCurrentWeather(query);
      ref.read(forecastWeatherProvider.notifier).getForecastWeather(
            query,
            days: ref.read(forecastDaysProvider),
          );

      // Clear suggestions
      ref.read(locationSuggestionsProvider.notifier).clearSuggestions();
      
      // Refresh search history after a delay to ensure weather data is saved
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          print('Refreshing search history for query: $query'); // Debug
          ref.read(searchHistoryProvider.notifier).refreshHistory();
        }
      });
    } catch (e) {
      if (mounted) {
        ref.read(errorMessageProvider.notifier).state =
            'Search failed: ${e.toString()}';
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    ref.read(isUsingCurrentLocationProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = null;

    try {
      final position = await _locationService.getLocationWithFallback();

      // Update current location state
      ref.read(currentLocationProvider.notifier).state = (
        lat: position.latitude,
        lon: position.longitude,
      );

      // Get weather for current location
      ref.read(currentWeatherProvider.notifier).getCurrentWeatherByCoordinates(
          position.latitude, position.longitude);
      ref
          .read(forecastWeatherProvider.notifier)
          .getForecastWeatherByCoordinates(
            position.latitude,
            position.longitude,
            days: ref.read(forecastDaysProvider),
          );

      // Update search field with coordinates for display
      _controller.text = _locationService.formatCoordinates(
          position.latitude, position.longitude);

      // Refresh search history
      ref.read(searchHistoryProvider.notifier).refreshHistory();
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to get current location';
        if (e is LocationException) {
          errorMessage = e.message;

          // Show dialog for permission errors
          if (e.code == 'permission_denied_forever' ||
              e.code == 'service_disabled') {
            _showLocationPermissionDialog(e.message, e.code);
          }
        }

        ref.read(errorMessageProvider.notifier).state = errorMessage;

        // Show snackbar for immediate feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      ref.read(isUsingCurrentLocationProvider.notifier).state = false;
    }
  }

  void _showLocationPermissionDialog(String message, String? code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Access Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (code == 'service_disabled') {
                await _locationService.openLocationSettings();
              } else {
                await _locationService.openAppSettings();
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUsingLocation = ref.watch(isUsingCurrentLocationProvider);
    final currentWeatherAsync = ref.watch(currentWeatherProvider);
    final forecastAsync = ref.watch(forecastWeatherProvider);

    final isLoading = currentWeatherAsync.isLoading ||
        forecastAsync.isLoading ||
        isUsingLocation;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search input field
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            enabled: !isLoading,
            decoration: InputDecoration(
              hintText: 'E.g., New York, London, Tokyo',
              prefixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                        _hideSuggestions();
                        ref
                            .read(locationSuggestionsProvider.notifier)
                            .clearSuggestions();
                      },
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          // Search button
          ElevatedButton(
            onPressed: isLoading || _controller.text.trim().isEmpty
                ? null
                : () => _onSearchSubmitted(_controller.text.trim()),
            child: const Text('Search'),
          ),

          const SizedBox(height: 12),

          // "or" divider
          Row(
            children: [
              Expanded(
                  child:
                      Divider(color: AppColors.textSecondary.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              Expanded(
                  child:
                      Divider(color: AppColors.textSecondary.withOpacity(0.3))),
            ],
          ),

          const SizedBox(height: 12),

          // Current location button
          OutlinedButton.icon(
            onPressed: isLoading ? null : _useCurrentLocation,
            icon: isUsingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(isUsingLocation
                ? 'Getting location...'
                : 'Use Current Location'),
          ),
        ],
      ),
    );
  }
}
