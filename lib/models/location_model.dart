import 'dart:convert';

Location locationFromJson(String str) => Location.fromJson(json.decode(str));
String locationToJson(Location data) => json.encode(data.toJson());

class Location {
  const Location({
    this.id,
    this.name,
    this.latitude = 23.4905831,
    this.longitude = 88.1002603,
    this.isActive = false,
    this.isDefault = false,
  });

  final int? id;
  final String? name;
  final double latitude;
  final double longitude;
  final bool isActive;
  final bool isDefault;

  Location copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    bool? isActive,
    bool? isDefault,
  }) =>
      Location(
        id: id ?? this.id,
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isActive: isActive ?? this.isActive,
        isDefault: isDefault ?? this.isDefault,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json["id"],
        name: json["name"],
        latitude: double.parse('${json["latitude"] ?? 23.4905831}'),
        longitude: double.parse('${json["longitude"] ?? 88.1002603}'),
        isActive: (json["is_active"] ?? 0) == 1,
        isDefault: (json["is_default"] ?? 0) == 1,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "is_active": isActive ? 1 : 0,
        "is_default": isDefault ? 1 : 0,
      };

  Map<String, dynamic> toMap() => {
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
      };
}
