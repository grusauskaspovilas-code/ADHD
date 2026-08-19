import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_assistant/models/context_place.dart';
import 'package:focus_assistant/services/location_context_service.dart';

class FakeLocationPermissionGateway implements LocationPermissionGateway {
  bool serviceEnabled;
  LocationPermission checkedPermission;
  LocationPermission requestedPermission;
  int requestCount = 0;
  int coordinatesRequestCount = 0;
  DeviceCoordinates currentCoordinates;

  FakeLocationPermissionGateway({
    this.serviceEnabled = true,
    this.checkedPermission = LocationPermission.denied,
    this.requestedPermission = LocationPermission.whileInUse,
    this.currentCoordinates = const DeviceCoordinates(
      latitude: 54.6872,
      longitude: 25.2797,
    ),
  });

  @override
  Future<LocationPermission> checkPermission() async => checkedPermission;

  @override
  Future<DeviceCoordinates> getCurrentCoordinates() async {
    coordinatesRequestCount++;
    return currentCoordinates;
  }

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<LocationPermission> requestPermission() async {
    requestCount++;
    return requestedPermission;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocationContextService.clearDetectionCache();
  });

  test(
    'enables context only after while-in-use permission is granted',
    () async {
      final gateway = FakeLocationPermissionGateway();
      final service = LocationContextService(permissionGateway: gateway);

      final status = await service.enable();

      expect(status, LocationContextStatus.ready);
      expect(gateway.requestCount, 1);
      expect(await service.isEnabled(), isTrue);
    },
  );

  test('does not enable context when permission is denied', () async {
    final gateway = FakeLocationPermissionGateway(
      requestedPermission: LocationPermission.denied,
    );
    final service = LocationContextService(permissionGateway: gateway);

    final status = await service.enable();

    expect(status, LocationContextStatus.permissionDenied);
    expect(await service.isEnabled(), isFalse);
  });

  test('does not request permission while location services are off', () async {
    final gateway = FakeLocationPermissionGateway(serviceEnabled: false);
    final service = LocationContextService(permissionGateway: gateway);

    final status = await service.enable();

    expect(status, LocationContextStatus.serviceDisabled);
    expect(gateway.requestCount, 0);
    expect(await service.isEnabled(), isFalse);
  });

  test('disable keeps system permission but turns app context off', () async {
    SharedPreferences.setMockInitialValues({'location_context_enabled': true});
    final service = LocationContextService(
      permissionGateway: FakeLocationPermissionGateway(
        checkedPermission: LocationPermission.whileInUse,
      ),
    );

    await service.disable();

    expect(await service.loadStatus(), LocationContextStatus.disabled);
  });

  test('detects the nearest resolved place inside the radius', () async {
    SharedPreferences.setMockInitialValues({'location_context_enabled': true});
    final service = LocationContextService(
      permissionGateway: FakeLocationPermissionGateway(
        checkedPermission: LocationPermission.whileInUse,
      ),
    );
    const place = ContextPlace(
      id: 'office',
      type: ContextPlaceType.work,
      name: 'Office',
      address: 'Vilnius',
      latitude: 54.6873,
      longitude: 25.2798,
    );

    final detected = await service.detectCurrentPlace([place]);

    expect(detected?.id, place.id);
  });

  test('does not detect a place outside the radius', () async {
    SharedPreferences.setMockInitialValues({'location_context_enabled': true});
    final service = LocationContextService(
      permissionGateway: FakeLocationPermissionGateway(
        checkedPermission: LocationPermission.whileInUse,
      ),
    );
    const place = ContextPlace(
      id: 'far-away',
      type: ContextPlaceType.other,
      name: 'Far away',
      address: 'Kaunas',
      latitude: 54.8985,
      longitude: 23.9036,
    );

    final detected = await service.detectCurrentPlace([place]);

    expect(detected, isNull);
  });

  test('reuses a recent detection without requesting GPS again', () async {
    SharedPreferences.setMockInitialValues({'location_context_enabled': true});
    final gateway = FakeLocationPermissionGateway(
      checkedPermission: LocationPermission.whileInUse,
    );
    final service = LocationContextService(permissionGateway: gateway);
    const place = ContextPlace(
      id: 'office',
      type: ContextPlaceType.work,
      name: 'Office',
      address: 'Vilnius',
      latitude: 54.6873,
      longitude: 25.2798,
    );

    await service.detectCurrentPlace([place]);
    await service.detectCurrentPlace([place]);

    expect(gateway.coordinatesRequestCount, 1);
  });
}
