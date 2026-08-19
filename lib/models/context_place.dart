enum ContextPlaceType { home, work, school, childcare, other }

class ContextPlace {
  final String id;
  final ContextPlaceType type;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;

  const ContextPlace({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
  });

  ContextPlace copyWith({
    ContextPlaceType? type,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
  }) {
    return ContextPlace(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: clearCoordinates ? null : latitude ?? this.latitude,
      longitude: clearCoordinates ? null : longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ContextPlace.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String?;
    final type = ContextPlaceType.values.firstWhere(
      (item) => item.name == rawType,
      orElse: () => ContextPlaceType.other,
    );

    return ContextPlace(
      id: json['id'] as String,
      type: type,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}
