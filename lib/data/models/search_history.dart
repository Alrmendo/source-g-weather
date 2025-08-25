import 'package:json_annotation/json_annotation.dart';

part 'search_history.g.dart';

@JsonSerializable()
class SearchHistory {
  final String city;
  final DateTime timestamp;
  final String displayName;

  const SearchHistory({
    required this.city,
    required this.timestamp,
    required this.displayName,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$SearchHistoryToJson(this);

  // Helper method to check if search is from today
  bool get isFromToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistory &&
          runtimeType == other.runtimeType &&
          city.toLowerCase() == other.city.toLowerCase();

  @override
  int get hashCode => city.toLowerCase().hashCode;

  @override
  String toString() =>
      'SearchHistory(city: $city, displayName: $displayName, timestamp: $timestamp)';
}
