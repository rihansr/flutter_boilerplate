import 'dart:convert';

Address addressFromJson(String str) => Address.fromJson(json.decode(str));
String addressToJson(Address data) => json.encode(data.toJson());

class Address {
  const Address({
    this.id,
    this.userId,
    this.street,
    this.apartment,
    this.landmark,
    this.tag,
    this.createdAt,
    this.latitude,
    this.longitude,
  });

  final int? id;
  final String? userId;
  final String? street;
  final String? apartment;
  final String? landmark;
  final String? tag;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;

  Address copyWith({
    int? id,
    String? userId,
    String? street,
    String? apartment,
    String? tag,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
  }) =>
      Address(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        street: street ?? this.street,
        apartment: apartment ?? this.apartment,
        tag: tag ?? this.tag,
        createdAt: createdAt ?? this.createdAt,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        userId: json["user_id"],
        street: json["street_address"],
        apartment: json["apartment"],
        tag: json["tag"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        latitude: json["latitude"] == null
            ? null
            : double.parse('${json["latitude"]}'),
        longitude: json["longitude"] == null
            ? null
            : double.parse('${json["longitude"]}'),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "street_address": street,
        "apartment": apartment,
        "landmark": landmark,
        "tag": tag,
        "created_at": createdAt?.toIso8601String(),
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
      };

  Map<String, dynamic> toMap(
          {bool hasId = true, bool trimlatLngLabel = false}) =>
      {
        if (id != null && hasId) "address_id": id,
        if (street != null) "address": street,
        if (apartment != null) "house": apartment,
        if (tag != null) "tag": tag,
        if (latitude != null) trimlatLngLabel ? "lat" : "latitude": latitude,
        if (longitude != null) trimlatLngLabel ? "lng" : "longitude": longitude,
      };

  String get _fullAddress => [
        if (apartment != null) apartment,
        if (street != null) street,
      ].join(', ');

  String? get fullAddress => _fullAddress.isEmpty ? null : _fullAddress;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.tag == tag;
  }

  @override
  int get hashCode {
    return tag.hashCode;
  }
}
