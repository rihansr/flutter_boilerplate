import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/debug.dart';
import '../models/address_model.dart';

class LocationService {
  final Function(Position position) listener;
  final bool listen;

  LocationService(this.listener, {this.listen = false});

  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future get position async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
      return Future.error('location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        Geolocator.openAppSettings();
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Geolocator.openAppSettings();
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    if (listen) {
      LocationSettings? locationSettings = (() {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return AndroidSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 100,
              forceLocationManager: true,
              intervalDuration: const Duration(seconds: 10),
            );
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            return AppleSettings(
              accuracy: LocationAccuracy.high,
              activityType: ActivityType.fitness,
              distanceFilter: 100,
              pauseLocationUpdatesAutomatically: true,
            );
          default:
            return const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 100,
            );
        }
      }());

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) => {if (position != null) listener(position)});
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      listener(position);
    }
  }
}

extension PlacemarkAddress<T> on T? {
  LatLng? get latLng => T is LatLng
      ? this as LatLng
      : T is Position
          ? LatLng((this as Position).latitude, (this as Position).longitude)
          : null;

  Future<Address> get address async {
    if (latLng == null) return Address(id: 0, createdAt: DateTime.now());
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng!.latitude, latLng!.longitude);
      Placemark place = placemarks[0];
      debug.print(place.toJson(), boundedText: 'Placemark');
      return Address(
        id: 0,
        street: "${place.name}, ${place.locality}",
        apartment: place.subLocality,
        createdAt: DateTime.now(),
        latitude: latLng?.latitude,
        longitude: latLng?.longitude,
      );
    } catch (e) {
      return Address(
        id: 0,
        createdAt: DateTime.now(),
        latitude: latLng?.latitude,
        longitude: latLng?.latitude,
      );
    }
  }
}
