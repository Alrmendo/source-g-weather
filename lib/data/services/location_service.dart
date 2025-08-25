import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  final String? code;

  const LocationException(this.message, [this.code]);

  @override
  String toString() => 'LocationException: $message';
}

class LocationService {
  // Check if location services are enabled and permissions are granted
  Future<bool> isLocationAvailable() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check permission status
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  // Request location permission from the user
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          'Location services are disabled. Please enable location services in your device settings.',
          'service_disabled',
        );
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationException(
            'Location permission denied. Please grant location access to use current location feature.',
            'permission_denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'Location permission permanently denied. Please enable location access in app settings.',
          'permission_denied_forever',
        );
      }

      // Permission granted (always or whileInUse)
      return true;
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException(
          'Failed to request location permission: ${e.toString()}');
    }
  }

  // Get current position with high accuracy
  Future<Position> getCurrentPosition() async {
    try {
      // Ensure we have permission first
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw const LocationException(
          'Location permission is required to get current position.',
          'permission_required',
        );
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      return position;
    } on LocationServiceDisabledException {
      throw const LocationException(
        'Location services are disabled. Please enable location services.',
        'service_disabled',
      );
    } on PermissionDeniedException {
      throw const LocationException(
        'Location permission denied. Please grant location access.',
        'permission_denied',
      );
    } on TimeoutException {
      throw const LocationException(
        'Location request timed out. Please try again.',
        'timeout',
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException(
        'Failed to get current location: ${e.toString()}',
        'unknown_error',
      );
    }
  }

  // Get last known position (faster but potentially less accurate)
  Future<Position?> getLastKnownPosition() async {
    try {
      // Check if we have permission
      final hasPermission = await isLocationAvailable();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      // Fail silently for last known position
      return null;
    }
  }

  // Get location with fallback to last known position
  Future<Position> getLocationWithFallback() async {
    try {
      // Try to get current position first
      return await getCurrentPosition();
    } catch (e) {
      // If current position fails, try last known position
      final lastKnown = await getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }

      // If both fail, rethrow the original error
      rethrow;
    }
  }

  // Open app settings for location permissions
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      return false;
    }
  }

  // Open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }

  // Calculate distance between two coordinates
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Check if location has changed significantly
  bool hasLocationChangedSignificantly(
    Position? oldPosition,
    Position newPosition, {
    double thresholdMeters = 1000, // 1km threshold
  }) {
    if (oldPosition == null) return true;

    final distance = calculateDistance(
      oldPosition.latitude,
      oldPosition.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    return distance > thresholdMeters;
  }

  // Format coordinates for display
  String formatCoordinates(double latitude, double longitude) {
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final lonDirection = longitude >= 0 ? 'E' : 'W';

    return '${latitude.abs().toStringAsFixed(4)}°$latDirection, '
        '${longitude.abs().toStringAsFixed(4)}°$lonDirection';
  }

  // Get location accuracy description
  String getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest accuracy (~3000m)';
      case LocationAccuracy.low:
        return 'Low accuracy (~1000m)';
      case LocationAccuracy.medium:
        return 'Medium accuracy (~100m)';
      case LocationAccuracy.high:
        return 'High accuracy (~10m)';
      case LocationAccuracy.best:
        return 'Best accuracy (~3m)';
      case LocationAccuracy.bestForNavigation:
        return 'Navigation accuracy (~1m)';
      default:
        return 'Unknown accuracy';
    }
  }
}
