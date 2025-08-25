// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHistory _$SearchHistoryFromJson(Map<String, dynamic> json) =>
    SearchHistory(
      city: json['city'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      displayName: json['displayName'] as String,
    );

Map<String, dynamic> _$SearchHistoryToJson(SearchHistory instance) =>
    <String, dynamic>{
      'city': instance.city,
      'timestamp': instance.timestamp.toIso8601String(),
      'displayName': instance.displayName,
    };
