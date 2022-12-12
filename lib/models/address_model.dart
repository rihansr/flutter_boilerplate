import 'dart:convert';

Address addressFromJson(String str) => Address.fromJson(json.decode(str));
String addressToJson(Address data) => json.encode(data.toJson());

class Address {
  const Address({
    this.id,
    this.userId,
    this.street,
    this.house,
    this.countryCode,
    this.label,
    this.createdAt,
    this.latitude,
    this.longitude,
  });

  final int? id;
  final String? userId;
  final String? street;
  final String? house;
  final String? countryCode;
  final String? label;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;

  Address copyWith({
    int? id,
    String? userId,
    String? street,
    String? house,
    String? countryCode,
    String? label,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
  }) =>
      Address(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        street: street ?? this.street,
        house: house ?? this.house,
        countryCode: countryCode ?? this.countryCode,
        label: label ?? this.label,
        createdAt: createdAt ?? this.createdAt,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        userId: json["user_id"],
        street: json["street_address"],
        house: json["house"],
        countryCode: json["country_code"],
        label: json["label"],
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
        "house": house,
        "country_code": countryCode,
        "label": label,
        "created_at": createdAt?.toIso8601String(),
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
      };

  Map<String, dynamic> toMap() => {
        "id": id,
        "street_address": street,
        "house": house,
        "country_code": countryCode,
        "label": label,
        "latitude": latitude,
        "longitude": longitude,
      }..removeWhere((key, value) => value == null);

  String get _address =>
      ([house, street]..removeWhere((element) => element?.isEmpty ?? true))
          .join(', ');
  String? get address => _address.isEmpty ? null : _address;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.label == label;
  }

  @override
  int get hashCode {
    return label.hashCode;
  }
}
