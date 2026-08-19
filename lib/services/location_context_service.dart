import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/context_place.dart';

class DeviceCoordinates {
  final double latitude;
  final double longitude;

  const DeviceCoordinates({required this.latitude, required this.longitude});
}

enum LocationContextStatus {
  disabled,
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

abstract class LocationPermissionGateway {
  const LocationPermissionGateway();

  Future<bool> isServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<DeviceCoordinates> getCurrentCoordinates();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

class GeolocatorLocationPermissionGateway implements LocationPermissionGateway {
  const GeolocatorLocationPermissionGateway();

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<DeviceCoordinates> getCurrentCoordinates() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return DeviceCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}

class LocationContextService {
  static const String _enabledKey = 'location_context_enabled';
  static const Duration _cacheDuration = Duration(minutes: 5);

  static DateTime? _cachedAt;
  static String? _cachedPlacesSignature;
  static ContextPlace? _cachedPlace;
  static bool _hasCachedDetection = false;

  final LocationPermissionGateway permissionGateway;

  const LocationContextService({
    this.permissionGateway = const GeolocatorLocationPermissionGateway(),
  });

  Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enabledKey) ?? false;
  }

  Future<LocationContextStatus> loadStatus() async {
    if (!await isEnabled()) {
      return LocationContextStatus.disabled;
    }

    return _grantedStatus();
  }

  Future<LocationContextStatus> enable() async {
    if (!await permissionGateway.isServiceEnabled()) {
      return LocationContextStatus.serviceDisabled;
    }

    var permission = await permissionGateway.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await permissionGateway.requestPermission();
    }

    final status = _statusForPermission(permission);
    if (status == LocationContextStatus.ready) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_enabledKey, true);
    }
    return status;
  }

  Future<void> disable() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, false);
    clearDetectionCache();
  }

  static void clearDetectionCache() {
    _cachedAt = null;
    _cachedPlacesSignature = null;
    _cachedPlace = null;
    _hasCachedDetection = false;
  }

  Future<ContextPlace?> detectCurrentPlace(
    List<ContextPlace> places, {
    double radiusMeters = 200,
  }) async {
    if (await loadStatus() != LocationContextStatus.ready) return null;

    final resolvedPlaces = places
        .where((place) => place.hasCoordinates)
        .toList();
    if (resolvedPlaces.isEmpty) return null;

    final signature = resolvedPlaces
        .map((place) => '${place.id}:${place.latitude}:${place.longitude}')
        .join('|');
    final cachedAt = _cachedAt;
    if (_hasCachedDetection &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheDuration &&
        _cachedPlacesSignature == signature) {
      return _cachedPlace;
    }

    final current = await permissionGateway.getCurrentCoordinates();
    ContextPlace? nearest;
    var nearestDistance = double.infinity;

    for (final place in resolvedPlaces) {
      final distance = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,
        place.latitude!,
        place.longitude!,
      );
      if (distance < nearestDistance) {
        nearest = place;
        nearestDistance = distance;
      }
    }

    final detected = nearestDistance <= radiusMeters ? nearest : null;
    _cachedAt = DateTime.now();
    _cachedPlacesSignature = signature;
    _cachedPlace = detected;
    _hasCachedDetection = true;
    return detected;
  }

  Future<bool> openRelevantSettings(LocationContextStatus status) {
    if (status == LocationContextStatus.serviceDisabled) {
      return permissionGateway.openLocationSettings();
    }
    return permissionGateway.openAppSettings();
  }

  Future<LocationContextStatus> _grantedStatus() async {
    if (!await permissionGateway.isServiceEnabled()) {
      return LocationContextStatus.serviceDisabled;
    }
    return _statusForPermission(await permissionGateway.checkPermission());
  }

  LocationContextStatus _statusForPermission(LocationPermission permission) {
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => LocationContextStatus.ready,
      LocationPermission.deniedForever =>
        LocationContextStatus.permissionDeniedForever,
      LocationPermission.denied => LocationContextStatus.permissionDenied,
      LocationPermission.unableToDetermine =>
        LocationContextStatus.permissionDenied,
    };
  }
}
