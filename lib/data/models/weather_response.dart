import 'package:json_annotation/json_annotation.dart';
import 'location.dart';
import 'current_weather.dart';
import 'forecast_day.dart';

part 'weather_response.g.dart';

@JsonSerializable()
class CurrentWeatherResponse {
  final Location location;
  final CurrentWeather current;

  const CurrentWeatherResponse({
    required this.location,
    required this.current,
  });

  factory CurrentWeatherResponse.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentWeatherResponseToJson(this);

  @override
  String toString() =>
      'CurrentWeatherResponse(location: ${location.displayName}, current: $current)';
}

@JsonSerializable()
class ForecastWeatherResponse {
  final Location location;
  final CurrentWeather current;
  final ForecastInfo forecast;

  const ForecastWeatherResponse({
    required this.location,
    required this.current,
    required this.forecast,
  });

  factory ForecastWeatherResponse.fromJson(Map<String, dynamic> json) =>
      _$ForecastWeatherResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastWeatherResponseToJson(this);

  @override
  String toString() =>
      'ForecastWeatherResponse(location: ${location.displayName}, forecast: ${forecast.forecastday.length} days)';
}

@JsonSerializable()
class ForecastInfo {
  final List<ForecastDay> forecastday;

  const ForecastInfo({
    required this.forecastday,
  });

  factory ForecastInfo.fromJson(Map<String, dynamic> json) =>
      _$ForecastInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastInfoToJson(this);

  @override
  String toString() => 'ForecastInfo(days: ${forecastday.length})';
}
