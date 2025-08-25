import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CountriesApiException implements Exception {
  final String message;
  final int? statusCode;

  const CountriesApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'CountriesApiException: $message';
}

class Country {
  final String name;
  final String capital;
  final String region;
  final String flag;
  final List<String> altSpellings;

  const Country({
    required this.name,
    required this.capital,
    required this.region,
    required this.flag,
    required this.altSpellings,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final name = json['name']['common'] as String? ?? '';
    final capital = (json['capital'] as List?)?.first as String? ?? '';
    final region = json['region'] as String? ?? '';
    final flag = json['flag'] as String? ?? '';
    final altSpellings = (json['altSpellings'] as List?)?.cast<String>() ?? [];

    return Country(
      name: name,
      capital: capital,
      region: region,
      flag: flag,
      altSpellings: altSpellings,
    );
  }

  String get displayName {
    if (capital.isNotEmpty && capital != name) {
      return '$capital, $name';
    }
    return name;
  }

  String get searchableText {
    return [name, capital, ...altSpellings].join(' ').toLowerCase();
  }

  @override
  String toString() => displayName;
}

class CountriesApiService {
  final http.Client _client;
  static const String _baseUrl = 'https://restcountries.com/v3.1';
  static const Duration _timeout = Duration(seconds: 10);
  
  // Cache for countries data
  List<Country>? _cachedCountries;
  DateTime? _lastFetch;
  static const Duration _cacheTimeout = Duration(hours: 24);

  CountriesApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Get all countries from REST Countries API
  Future<List<Country>> getAllCountries() async {
    // Return cached data if available and not expired
    if (_cachedCountries != null && 
        _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheTimeout) {
      return _cachedCountries!;
    }

    try {
      final uri = Uri.parse('$_baseUrl/all?fields=name,capital,region,flag,altSpellings');
      
      final response = await _client
          .get(uri, headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          })
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        
        final countries = jsonList
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .where((country) => country.name.isNotEmpty)
            .toList();

        // Sort countries by name
        countries.sort((a, b) => a.name.compareTo(b.name));

        // Cache the results
        _cachedCountries = countries;
        _lastFetch = DateTime.now();

        return countries;
      } else {
        throw CountriesApiException(
          'Failed to fetch countries: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException {
      throw const CountriesApiException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException {
      throw const CountriesApiException(
        'Network error. Please try again later.',
      );
    } catch (e) {
      if (e is CountriesApiException) rethrow;
      throw CountriesApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// Search countries by query
  Future<List<Country>> searchCountries(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final countries = await getAllCountries();
      final queryLower = query.toLowerCase().trim();

      final results = countries.where((country) {
        return country.searchableText.contains(queryLower) ||
               country.name.toLowerCase().startsWith(queryLower) ||
               country.capital.toLowerCase().startsWith(queryLower);
      }).toList();

      // Sort results by relevance
      results.sort((a, b) {
        // Exact matches first
        if (a.name.toLowerCase() == queryLower) return -1;
        if (b.name.toLowerCase() == queryLower) return 1;
        
        // Capital exact matches
        if (a.capital.toLowerCase() == queryLower) return -1;
        if (b.capital.toLowerCase() == queryLower) return 1;
        
        // Name starts with query
        final aNameStarts = a.name.toLowerCase().startsWith(queryLower);
        final bNameStarts = b.name.toLowerCase().startsWith(queryLower);
        if (aNameStarts && !bNameStarts) return -1;
        if (!aNameStarts && bNameStarts) return 1;
        
        // Capital starts with query
        final aCapitalStarts = a.capital.toLowerCase().startsWith(queryLower);
        final bCapitalStarts = b.capital.toLowerCase().startsWith(queryLower);
        if (aCapitalStarts && !bCapitalStarts) return -1;
        if (!aCapitalStarts && bCapitalStarts) return 1;
        
        // Alphabetical order
        return a.name.compareTo(b.name);
      });

      // Limit results to prevent UI performance issues
      return results.take(10).toList();
    } catch (e) {
      if (e is CountriesApiException) rethrow;
      throw CountriesApiException('Search failed: ${e.toString()}');
    }
  }

  /// Get countries by region
  Future<List<Country>> getCountriesByRegion(String region) async {
    try {
      final uri = Uri.parse('$_baseUrl/region/$region');
      
      final response = await _client
          .get(uri)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        
        return jsonList
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .where((country) => country.name.isNotEmpty)
            .toList();
      } else {
        throw CountriesApiException(
          'Failed to fetch countries by region: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is CountriesApiException) rethrow;
      throw CountriesApiException('Region search failed: ${e.toString()}');
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedCountries = null;
    _lastFetch = null;
  }

  void dispose() {
    _client.close();
  }
}
