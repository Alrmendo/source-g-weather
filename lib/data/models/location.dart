import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;
  @JsonKey(name: 'tz_id')
  final String tzId;
  @JsonKey(name: 'localtime_epoch')
  final int localtimeEpoch;
  final String localtime;

  const Location({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tzId,
    required this.localtimeEpoch,
    required this.localtime,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  // Helper method to get display name
  String get displayName => '$name, $country';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          region == other.region &&
          country == other.country &&
          lat == other.lat &&
          lon == other.lon;

  @override
  int get hashCode =>
      name.hashCode ^
      region.hashCode ^
      country.hashCode ^
      lat.hashCode ^
      lon.hashCode;

  @override
  String toString() =>
      'Location(name: $name, region: $region, country: $country, lat: $lat, lon: $lon)';
}
