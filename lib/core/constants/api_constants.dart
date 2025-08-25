class ApiConstants {
  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  static const String currentWeatherEndpoint = '/current.json';
  static const String forecastWeatherEndpoint = '/forecast.json';
  
  static const int defaultForecastDays = 4;
  static const int maxForecastDays = 10;
  
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration searchDebounceTime = Duration(milliseconds: 400);
}
