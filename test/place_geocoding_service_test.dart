import 'package:flutter_test/flutter_test.dart';

import 'package:focus_assistant/models/context_place.dart';
import 'package:focus_assistant/services/place_geocoding_service.dart';

class FakePlaceGeocodingGateway implements PlaceGeocodingGateway {
  final PlaceCoordinates? result;
  final bool shouldThrow;

  const FakePlaceGeocodingGateway({this.result, this.shouldThrow = false});

  @override
  Future<PlaceCoordinates?> coordinatesFromAddress(String address) async {
    if (shouldThrow) throw Exception('geocoding failed');
    return result;
  }
}

void main() {
  const place = ContextPlace(
    id: 'office',
    type: ContextPlaceType.work,
    name: 'Office',
    address: 'Main Street 1',
  );

  test('adds coordinates returned for an address', () async {
    const service = PlaceGeocodingService(
      gateway: FakePlaceGeocodingGateway(
        result: PlaceCoordinates(latitude: 54.6872, longitude: 25.2797),
      ),
    );

    final resolved = await service.resolve(place);

    expect(resolved.latitude, 54.6872);
    expect(resolved.longitude, 25.2797);
    expect(resolved.id, place.id);
  });

  test(
    'keeps the place but clears coordinates when address lookup fails',
    () async {
      const service = PlaceGeocodingService(
        gateway: FakePlaceGeocodingGateway(shouldThrow: true),
      );

      final resolved = await service.resolve(
        place.copyWith(latitude: 1, longitude: 2),
      );

      expect(resolved.id, place.id);
      expect(resolved.hasCoordinates, isFalse);
    },
  );
}
