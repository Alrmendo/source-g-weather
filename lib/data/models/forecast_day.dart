import 'package:json_annotation/json_annotation.dart';
import 'condition.dart';

part 'forecast_day.g.dart';

@JsonSerializable()
class ForecastDay {
  final String date;
  @JsonKey(name: 'date_epoch')
  final int dateEpoch;
  final DayWeather day;
  final AstroInfo astro;
  final List<HourWeather> hour;

  const ForecastDay({
    required this.date,
    required this.dateEpoch,
    required this.day,
    required this.astro,
    required this.hour,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) =>
      _$ForecastDayFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastDayToJson(this);

  @override
  String toString() => 'ForecastDay(date: $date, day: $day)';
}

@JsonSerializable()
class DayWeather {
  @JsonKey(name: 'maxtemp_c')
  final double maxtempC;
  @JsonKey(name: 'maxtemp_f')
  final double maxtempF;
  @JsonKey(name: 'mintemp_c')
  final double mintempC;
  @JsonKey(name: 'mintemp_f')
  final double mintempF;
  @JsonKey(name: 'avgtemp_c')
  final double avgtempC;
  @JsonKey(name: 'avgtemp_f')
  final double avgtempF;
  @JsonKey(name: 'maxwind_mph')
  final double maxwindMph;
  @JsonKey(name: 'maxwind_kph')
  final double maxwindKph;
  @JsonKey(name: 'totalprecip_mm')
  final double totalprecipMm;
  @JsonKey(name: 'totalprecip_in')
  final double totalprecipIn;
  @JsonKey(name: 'totalsnow_cm')
  final double totalsnowCm;
  @JsonKey(name: 'avgvis_km')
  final double avgvisKm;
  @JsonKey(name: 'avgvis_miles')
  final double avgvisMiles;
  @JsonKey(name: 'avghumidity')
  final double avghumidity;
  @JsonKey(name: 'daily_will_it_rain')
  final int dailyWillItRain;
  @JsonKey(name: 'daily_chance_of_rain')
  final int dailyChanceOfRain;
  @JsonKey(name: 'daily_will_it_snow')
  final int dailyWillItSnow;
  @JsonKey(name: 'daily_chance_of_snow')
  final int dailyChanceOfSnow;
  final Condition condition;
  final double uv;

  const DayWeather({
    required this.maxtempC,
    required this.maxtempF,
    required this.mintempC,
    required this.mintempF,
    required this.avgtempC,
    required this.avgtempF,
    required this.maxwindMph,
    required this.maxwindKph,
    required this.totalprecipMm,
    required this.totalprecipIn,
    required this.totalsnowCm,
    required this.avgvisKm,
    required this.avgvisMiles,
    required this.avghumidity,
    required this.dailyWillItRain,
    required this.dailyChanceOfRain,
    required this.dailyWillItSnow,
    required this.dailyChanceOfSnow,
    required this.condition,
    required this.uv,
  });

  factory DayWeather.fromJson(Map<String, dynamic> json) =>
      _$DayWeatherFromJson(json);

  Map<String, dynamic> toJson() => _$DayWeatherToJson(this);

  // Helper methods for formatted display
  String get temperatureDisplay => '${avgtempC.toStringAsFixed(1)}°C';
  String get windDisplay => '${(maxwindKph / 3.6).toStringAsFixed(1)} M/S';
  String get humidityDisplay => '${avghumidity.toStringAsFixed(0)}%';

  @override
  String toString() =>
      'DayWeather(avgtemp: $avgtempC°C, condition: ${condition.text})';
}

@JsonSerializable()
class AstroInfo {
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  @JsonKey(name: 'moon_phase')
  final String moonPhase;
  @JsonKey(name: 'moon_illumination')
  final int moonIllumination;

  const AstroInfo({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonIllumination,
  });

  factory AstroInfo.fromJson(Map<String, dynamic> json) =>
      _$AstroInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AstroInfoToJson(this);
}

@JsonSerializable()
class HourWeather {
  @JsonKey(name: 'time_epoch')
  final int timeEpoch;
  final String time;
  @JsonKey(name: 'temp_c')
  final double tempC;
  @JsonKey(name: 'temp_f')
  final double tempF;
  @JsonKey(name: 'is_day')
  final int isDay;
  final Condition condition;
  @JsonKey(name: 'wind_mph')
  final double windMph;
  @JsonKey(name: 'wind_kph')
  final double windKph;
  @JsonKey(name: 'wind_degree')
  final int windDegree;
  @JsonKey(name: 'wind_dir')
  final String windDir;
  @JsonKey(name: 'pressure_mb')
  final double pressureMb;
  @JsonKey(name: 'pressure_in')
  final double pressureIn;
  @JsonKey(name: 'precip_mm')
  final double precipMm;
  @JsonKey(name: 'precip_in')
  final double precipIn;
  final int humidity;
  final int cloud;
  @JsonKey(name: 'feelslike_c')
  final double feelslikeC;
  @JsonKey(name: 'feelslike_f')
  final double feelslikeF;
  @JsonKey(name: 'windchill_c')
  final double windchillC;
  @JsonKey(name: 'windchill_f')
  final double windchillF;
  @JsonKey(name: 'heatindex_c')
  final double heatindexC;
  @JsonKey(name: 'heatindex_f')
  final double heatindexF;
  @JsonKey(name: 'dewpoint_c')
  final double dewpointC;
  @JsonKey(name: 'dewpoint_f')
  final double dewpointF;
  @JsonKey(name: 'will_it_rain')
  final int willItRain;
  @JsonKey(name: 'chance_of_rain')
  final int chanceOfRain;
  @JsonKey(name: 'will_it_snow')
  final int willItSnow;
  @JsonKey(name: 'chance_of_snow')
  final int chanceOfSnow;
  @JsonKey(name: 'vis_km')
  final double visKm;
  @JsonKey(name: 'vis_miles')
  final double visMiles;
  @JsonKey(name: 'gust_mph')
  final double gustMph;
  @JsonKey(name: 'gust_kph')
  final double gustKph;
  final double uv;

  const HourWeather({
    required this.timeEpoch,
    required this.time,
    required this.tempC,
    required this.tempF,
    required this.isDay,
    required this.condition,
    required this.windMph,
    required this.windKph,
    required this.windDegree,
    required this.windDir,
    required this.pressureMb,
    required this.pressureIn,
    required this.precipMm,
    required this.precipIn,
    required this.humidity,
    required this.cloud,
    required this.feelslikeC,
    required this.feelslikeF,
    required this.windchillC,
    required this.windchillF,
    required this.heatindexC,
    required this.heatindexF,
    required this.dewpointC,
    required this.dewpointF,
    required this.willItRain,
    required this.chanceOfRain,
    required this.willItSnow,
    required this.chanceOfSnow,
    required this.visKm,
    required this.visMiles,
    required this.gustMph,
    required this.gustKph,
    required this.uv,
  });

  factory HourWeather.fromJson(Map<String, dynamic> json) =>
      _$HourWeatherFromJson(json);

  Map<String, dynamic> toJson() => _$HourWeatherToJson(this);
}
