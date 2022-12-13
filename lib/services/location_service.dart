import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../shared/enums.dart';
import '../shared/styles.dart';
import '../utils/debug.dart';
import '../models/location_model.dart' as model;
import '../models/address_model.dart' as model;

class LocationService {
  final Function(Position position) listener;
  final bool listen;
  final bool actionHandling;
  final bool alertMessage;

  LocationService(
    this.listener, {
    this.listen = false,
    this.actionHandling = true,
    this.alertMessage = true,
  });

  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<bool> get _hasPermission async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (actionHandling) Geolocator.openLocationSettings();
      _showErrorMessage(
        'location services are disabled',
        logOnly: !alertMessage,
        tag: 'Location Service',
      );
      return false;
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
        if (actionHandling) Geolocator.openAppSettings();
        _showErrorMessage(
          'Location permissions are denied',
          logOnly: !alertMessage,
          tag: 'Location Permisson',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (actionHandling) Geolocator.openAppSettings();
      _showErrorMessage(
        'Location permissions are permanently denied, we cannot request permissions',
        logOnly: !alertMessage,
        tag: 'Location Permisson',
      );
      return false;
    }
    return true;
  }

  Future<void> get invoke async {
    if (!await _hasPermission) return;

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
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((position) => listener(position))
          .catchError((e) {
        _showErrorMessage(
          e,
          logOnly: !alertMessage,
          tag: 'Current Position Exception',
        );
      });
    }
  }

  void _showErrorMessage(
    String? message, {
    String? tag,
    bool logOnly = false,
  }) {
    if (message == null) return;
    if (!logOnly) style.toast(message, type: MessageType.error);
    debug.print(message, boundedText: tag ?? 'Location Exception');
  }
}

extension PlacemarkAddress on dynamic {
  LatLng? get latLng => this is LatLng
      ? this as LatLng
      : this is Position || this is Location || this is model.Location
          ? LatLng(this.latitude, this.longitude)
          : null;

  Future<model.Address> get address async {
    if (latLng == null) return Address(id: 0, createdAt: DateTime.now());
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng!.latitude, latLng!.longitude);
      Placemark place = placemarks[0];

      return model.Address(
        id: 0,
        street: ([
          '${place.subThoroughfare ?? ''} ${place.thoroughfare ?? ''}'.trim(),
          place.subLocality ?? '',
          '${place.locality ?? ''} ${place.postalCode ?? ''}'.trim(),
          place.subAdministrativeArea ?? '',
          place.administrativeArea ?? '',
          place.country ?? '',
        ]..removeWhere((element) => element.isEmpty))
            .join(', '),
        countryCode: place.isoCountryCode,
        createdAt: DateTime.now(),
        latitude: latLng?.latitude,
        longitude: latLng?.longitude,
      );
    } catch (e) {
      return model.Address(
        id: 0,
        street: 'Unknown Location',
        createdAt: DateTime.now(),
        latitude: latLng?.latitude,
        longitude: latLng?.latitude,
      );
    }
  }
}
