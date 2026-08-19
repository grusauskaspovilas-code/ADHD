import 'package:geocoding/geocoding.dart';

import '../models/context_place.dart';

class PlaceCoordinates {
  final double latitude;
  final double longitude;

  const PlaceCoordinates({required this.latitude, required this.longitude});
}

abstract class PlaceGeocodingGateway {
  const PlaceGeocodingGateway();

  Future<PlaceCoordinates?> coordinatesFromAddress(String address);
}

class DevicePlaceGeocodingGateway implements PlaceGeocodingGateway {
  const DevicePlaceGeocodingGateway();

  @override
  Future<PlaceCoordinates?> coordinatesFromAddress(String address) async {
    final locations = await Geocoding().locationFromAddress(address);
    if (locations.isEmpty) return null;
    final location = locations.first;
    return PlaceCoordinates(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }
}

class PlaceGeocodingService {
  final PlaceGeocodingGateway gateway;

  const PlaceGeocodingService({
    this.gateway = const DevicePlaceGeocodingGateway(),
  });

  Future<ContextPlace> resolve(ContextPlace place) async {
    try {
      final coordinates = await gateway.coordinatesFromAddress(place.address);
      if (coordinates == null) return place.copyWith(clearCoordinates: true);
      return place.copyWith(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );
    } catch (_) {
      return place.copyWith(clearCoordinates: true);
    }
  }
}
