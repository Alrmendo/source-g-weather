import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/env/env_config.dart';
import '../models/weather_response.dart';

class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  const WeatherApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'WeatherApiException: $message';
}

class WeatherApiService {
  final http.Client _client;
  static const String _baseUrl = ApiConstants.weatherApiBaseUrl;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  // Get current weather for a city
  Future<CurrentWeatherResponse> getCurrentWeather(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.currentWeatherEndpoint}')
          .replace(queryParameters: {
        'key': EnvConfig.weatherApiKey,
        'q': query,
        'aqi': 'no',
      });

      final response = await _client
          .get(uri)
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse<CurrentWeatherResponse>(
        response,
        (json) => CurrentWeatherResponse.fromJson(json),
      );
    } on SocketException {
      throw const WeatherApiException(
          'No internet connection. Please check your network.');
    } on http.ClientException {
      throw const WeatherApiException(
          'Network error. Please try again later.');
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Unexpected error: ${e.toString()}');
    }
  }

  // Get weather forecast for a city
  Future<ForecastWeatherResponse> getForecastWeather(
    String query, {
    int days = ApiConstants.defaultForecastDays,
  }) async {
    try {
      // Ensure days is within valid range
      final validDays = days.clamp(1, ApiConstants.maxForecastDays);

      final uri = Uri.parse('$_baseUrl${ApiConstants.forecastWeatherEndpoint}')
          .replace(queryParameters: {
        'key': EnvConfig.weatherApiKey,
        'q': query,
        'days': validDays.toString(),
        'aqi': 'no',
        'alerts': 'no',
      });

      final response = await _client
          .get(uri)
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse<ForecastWeatherResponse>(
        response,
        (json) => ForecastWeatherResponse.fromJson(json),
      );
    } on SocketException {
      throw const WeatherApiException(
          'No internet connection. Please check your network.');
    } on http.ClientException {
      throw const WeatherApiException(
          'Network error. Please try again later.');
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      throw WeatherApiException('Unexpected error: ${e.toString()}');
    }
  }

  // Get current weather by coordinates
  Future<CurrentWeatherResponse> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final query = '$latitude,$longitude';
    return getCurrentWeather(query);
  }

  /// Get forecast weather by coordinates
  Future<ForecastWeatherResponse> getForecastWeatherByCoordinates(
    double latitude,
    double longitude, {
    int days = ApiConstants.defaultForecastDays,
  }) async {
    final query = '$latitude,$longitude';
    return getForecastWeather(query, days: days);
  }

  // Validate if a city exists and return basic location info
  Future<bool> validateCity(String query) async {
    try {
      await getCurrentWeather(query);
      return true;
    } on WeatherApiException catch (e) {
      if (e.statusCode == 400) {
        return false; // City not found
      }
      rethrow;
    }
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final statusCode = response.statusCode;

    if (statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return fromJson(json);
      } catch (e) {
        throw const WeatherApiException(
            'Failed to parse weather data. Please try again.');
      }
    }

    // Handle different error status codes
    String errorMessage;
    try {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      final error = errorJson['error'] as Map<String, dynamic>?;
      errorMessage = error?['message'] ?? 'Unknown error occurred';
    } catch (e) {
      errorMessage = _getDefaultErrorMessage(statusCode);
    }

    throw WeatherApiException(errorMessage, statusCode);
  }

  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'City not found. Please check the spelling and try again.';
      case 401:
        return 'API key is invalid. Please check your configuration.';
      case 403:
        return 'API key access denied. Please check your subscription.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
        return 'Weather service is temporarily unavailable. Please try again later.';
      default:
        return 'Failed to fetch weather data. Please try again.';
    }
  }

  void dispose() {
    _client.close();
  }
}
