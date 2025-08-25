import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../data/services/weather_api_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/email_subscription_service.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/countries_api_service.dart';
import '../../../data/models/weather_response.dart';
import '../../../data/models/search_history.dart';

// Service providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

final emailSubscriptionServiceProvider = Provider<IEmailSubscriptionService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  // Use simple email service with Nodemailer backend
  return SimpleEmailSubscriptionService(prefs: prefs);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final countriesApiServiceProvider = Provider<CountriesApiService>((ref) {
  return CountriesApiService();
});

// Weather state providers
final currentWeatherProvider = StateNotifierProvider<CurrentWeatherNotifier, AsyncValue<CurrentWeatherResponse?>>((ref) {
  final weatherService = ref.watch(weatherApiServiceProvider);
  final storageService = ref.watch(localStorageServiceProvider);
  return CurrentWeatherNotifier(weatherService, storageService);
});

final forecastWeatherProvider = StateNotifierProvider<ForecastWeatherNotifier, AsyncValue<ForecastWeatherResponse?>>((ref) {
  final weatherService = ref.watch(weatherApiServiceProvider);
  return ForecastWeatherNotifier(weatherService);
});

// Search and history providers
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, AsyncValue<List<SearchHistory>>>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return SearchHistoryNotifier(storageService);
});

// Location suggestions provider
final locationSuggestionsProvider = StateNotifierProvider<LocationSuggestionsNotifier, AsyncValue<List<String>>>((ref) {
  final countriesService = ref.watch(countriesApiServiceProvider);
  return LocationSuggestionsNotifier(countriesService);
});

// UI state providers
final isLoadingProvider = StateProvider<bool>((ref) => false);
final errorMessageProvider = StateProvider<String?>((ref) => null);
final forecastDaysProvider = StateProvider<int>((ref) => 4);

// Location providers
final isUsingCurrentLocationProvider = StateProvider<bool>((ref) => false);
final currentLocationProvider = StateProvider<({double lat, double lon})?> ((ref) => null);

// State notifiers
class CurrentWeatherNotifier extends StateNotifier<AsyncValue<CurrentWeatherResponse?>> {
  final WeatherApiService _weatherService;
  final LocalStorageService _storageService;

  CurrentWeatherNotifier(this._weatherService, this._storageService) 
      : super(const AsyncValue.data(null));

  Future<void> getCurrentWeather(String query) async {
    if (query.trim().isEmpty) return;

    state = const AsyncValue.loading();
    
    try {
      final response = await _weatherService.getCurrentWeather(query);
      state = AsyncValue.data(response);
      
      // Save to search history
      await _storageService.saveSearchHistory(
        query,
        response.location.displayName,
      );
      await _storageService.saveLastSearchCity(query);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> getCurrentWeatherByCoordinates(double lat, double lon) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _weatherService.getCurrentWeatherByCoordinates(lat, lon);
      state = AsyncValue.data(response);
      
      // Save to search history with coordinates
      final query = '$lat,$lon';
      await _storageService.saveSearchHistory(
        query,
        response.location.displayName,
      );
      await _storageService.saveLastSearchCity(query);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearWeather() {
    state = const AsyncValue.data(null);
  }
}

class ForecastWeatherNotifier extends StateNotifier<AsyncValue<ForecastWeatherResponse?>> {
  final WeatherApiService _weatherService;

  ForecastWeatherNotifier(this._weatherService) 
      : super(const AsyncValue.data(null));

  Future<void> getForecastWeather(String query, {int days = 4}) async {
    if (query.trim().isEmpty) return;

    state = const AsyncValue.loading();
    
    try {
      final response = await _weatherService.getForecastWeather(query, days: days);
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> getForecastWeatherByCoordinates(
    double lat, 
    double lon, {
    int days = 4,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _weatherService.getForecastWeatherByCoordinates(
        lat, 
        lon, 
        days: days,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMoreForecastDays(String query, int additionalDays) async {
    final currentForecast = state.valueOrNull;
    if (currentForecast == null) return;

    final newDays = currentForecast.forecast.forecastday.length + additionalDays;
    await getForecastWeather(query, days: newDays);
  }

  void clearForecast() {
    state = const AsyncValue.data(null);
  }
}

class SearchHistoryNotifier extends StateNotifier<AsyncValue<List<SearchHistory>>> {
  final LocalStorageService _storageService;

  SearchHistoryNotifier(this._storageService) 
      : super(const AsyncValue.loading()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _storageService.getSearchHistory();
      state = AsyncValue.data(history);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshHistory() async {
    await _loadHistory();
  }

  Future<void> clearHistory() async {
    try {
      await _storageService.clearSearchHistory();
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeHistoryItem(String query) async {
    try {
      await _storageService.removeSearchHistoryItem(query);
      await refreshHistory();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeSearchFromHistory(String query) async {
    await removeHistoryItem(query);
  }
}

class LocationSuggestionsNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final CountriesApiService _countriesService;
  Timer? _debounceTimer;

  LocationSuggestionsNotifier(this._countriesService) : super(const AsyncValue.data([]));

  Future<void> getLocationSuggestions(String query) async {
    if (query.trim().length < 2) {
      state = const AsyncValue.data([]);
      return;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Set up debounced search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        state = const AsyncValue.loading();
        
        // Get suggestions from Countries API
        final countries = await _countriesService.searchCountries(query);
        final suggestions = countries.map((country) => country.displayName).toList();
        
        state = AsyncValue.data(suggestions);
      } catch (error, stackTrace) {
        // Fallback to local suggestions if API fails
        try {
          final fallbackSuggestions = await _getFallbackSuggestions(query);
          state = AsyncValue.data(fallbackSuggestions);
        } catch (fallbackError) {
          state = AsyncValue.error(error, stackTrace);
        }
      }
    });
  }

  Future<List<String>> _getFallbackSuggestions(String query) async {
    // Fallback list of popular cities when API fails
    final popularLocations = [
      'Ho Chi Minh City, Vietnam',
      'Hanoi, Vietnam',
      'Da Nang, Vietnam',
      'Can Tho, Vietnam',
      'Hai Phong, Vietnam',
      'Hue, Vietnam',
      'Nha Trang, Vietnam',
      'Vung Tau, Vietnam',
      'London, United Kingdom',
      'New York, United States',
      'Tokyo, Japan',
      'Paris, France',
      'Sydney, Australia',
      'Singapore, Singapore',
      'Bangkok, Thailand',
      'Seoul, South Korea',
      'Beijing, China',
      'Shanghai, China',
      'Mumbai, India',
      'Delhi, India',
      'Los Angeles, United States',
      'Chicago, United States',
      'Toronto, Canada',
      'Vancouver, Canada',
      'Berlin, Germany',
      'Rome, Italy',
      'Madrid, Spain',
      'Amsterdam, Netherlands',
      'Stockholm, Sweden',
      'Oslo, Norway',
      'Copenhagen, Denmark',
      'Vienna, Austria',
      'Zurich, Switzerland',
      'Dublin, Ireland',
      'Edinburgh, United Kingdom',
      'Brussels, Belgium',
      'Warsaw, Poland',
      'Prague, Czech Republic',
      'Budapest, Hungary',
      'Athens, Greece',
    ];
    
    return popularLocations
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .take(8)
        .toList();
  }

  void clearSuggestions() {
    state = const AsyncValue.data([]);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Subscription providers
final subscriptionStatusProvider = StateNotifierProvider<SubscriptionStatusNotifier, AsyncValue<SubscriptionStatus>>((ref) {
  final emailService = ref.watch(emailSubscriptionServiceProvider);
  return SubscriptionStatusNotifier(emailService);
});

class SubscriptionStatusNotifier extends StateNotifier<AsyncValue<SubscriptionStatus>> {
  final IEmailSubscriptionService _emailService;

  SubscriptionStatusNotifier(this._emailService) 
      : super(const AsyncValue.data(SubscriptionStatus.unsubscribed));

  Future<void> checkSubscriptionStatus(String email) async {
    if (email.trim().isEmpty) return;

    state = const AsyncValue.loading();
    
    try {
      final status = await _emailService.getSubscriptionStatus(email);
      state = AsyncValue.data(status);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> requestSubscription(String email) async {
    try {
      await _emailService.requestSubscription(email);
      // Check status after subscription request
      await checkSubscriptionStatus(email);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> requestUnsubscription(String email) async {
    try {
      await _emailService.requestUnsubscription(email);
      // Check status after unsubscription request
      await checkSubscriptionStatus(email);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Computed providers
final hasWeatherDataProvider = Provider<bool>((ref) {
  final currentWeather = ref.watch(currentWeatherProvider);
  return currentWeather.hasValue && currentWeather.value != null;
});

final isAnyLoadingProvider = Provider<bool>((ref) {
  final currentWeather = ref.watch(currentWeatherProvider);
  final forecast = ref.watch(forecastWeatherProvider);
  final isUsingLocation = ref.watch(isUsingCurrentLocationProvider);
  
  return currentWeather.isLoading || 
         forecast.isLoading || 
         isUsingLocation;
});