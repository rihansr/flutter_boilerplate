import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/address/address_model.dart';
import '../shared/strings.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> currentPosition(Function(Position position) callback,
      {bool notifyLocationChanges = false}) async {
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
    if (notifyLocationChanges) {
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
          (Position? position) => {if (position != null) callback(position)});
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      callback(position);
    }
  }

  Future<Address> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return Address(
        id: 0,
        tag: string.currentLocation,
        address: "${place.name}, ${place.locality}",
        house: place.subLocality,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      return Address(
        id: 0,
        tag: string.currentLocation,
        address: string.unknownLocation,
        latitude: latitude,
        longitude: longitude,
      );
    }
  }
}
