import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_constants.dart';
import '../models/search_history.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  /// Save a search to history
  Future<void> saveSearchHistory(String city, String displayName) async {
    try {
      final history = SearchHistory(
        city: city,
        timestamp: DateTime.now(),
        displayName: displayName,
      );

      final existingHistory = await getSearchHistory();
      
      // Remove duplicate if exists (by city name, case-insensitive)
      existingHistory.removeWhere(
        (item) => item.city.toLowerCase() == city.toLowerCase(),
      );
      
      // Add new search to the beginning
      existingHistory.insert(0, history);
      
      // Keep only recent searches (within the day limit) and max count
      final filteredHistory = existingHistory
          .where((item) => item.isFromToday)
          .take(StorageConstants.maxRecentSearches)
          .toList();

      await _saveSearchHistoryList(filteredHistory);
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  /// Get search history for today
  Future<List<SearchHistory>> getSearchHistory() async {
    try {
      final jsonString = _prefs.getString(StorageConstants.recentSearchesKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final history = jsonList
          .map((item) => SearchHistory.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isFromToday) // Filter for today only
          .toList();

      return history;
    } catch (e) {
      print('Error loading search history: $e');
      return [];
    }
  }

  /// Clear all search history
  Future<void> clearSearchHistory() async {
    try {
      await _prefs.remove(StorageConstants.recentSearchesKey);
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Save the last searched city
  Future<void> saveLastSearchCity(String city) async {
    try {
      await _prefs.setString(StorageConstants.lastSearchCityKey, city);
    } catch (e) {
      print('Error saving last search city: $e');
    }
  }

  /// Get the last searched city
  String? getLastSearchCity() {
    try {
      return _prefs.getString(StorageConstants.lastSearchCityKey);
    } catch (e) {
      print('Error loading last search city: $e');
      return null;
    }
  }

  /// Clean up old search history (older than today)
  Future<void> cleanupOldHistory() async {
    try {
      final currentHistory = await getSearchHistory();
      // getSearchHistory already filters for today, so just save the filtered list
      await _saveSearchHistoryList(currentHistory);
    } catch (e) {
      print('Error cleaning up old history: $e');
    }
  }

  /// Private helper to save search history list
  Future<void> _saveSearchHistoryList(List<SearchHistory> history) async {
    final jsonList = history.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(StorageConstants.recentSearchesKey, jsonString);
  }

  /// Check if there's any search history
  bool hasSearchHistory() {
    return _prefs.containsKey(StorageConstants.recentSearchesKey);
  }

  /// Get search history count
  Future<int> getSearchHistoryCount() async {
    final history = await getSearchHistory();
    return history.length;
  }

  /// Remove a specific search from history
  Future<void> removeSearchFromHistory(String city) async {
    try {
      final history = await getSearchHistory();
      history.removeWhere(
        (item) => item.city.toLowerCase() == city.toLowerCase(),
      );
      await _saveSearchHistoryList(history);
    } catch (e) {
      print('Error removing search from history: $e');
    }
  }

  /// Remove a specific search history item (alias for removeSearchFromHistory)
  Future<void> removeSearchHistoryItem(String city) async {
    await removeSearchFromHistory(city);
  }
}
