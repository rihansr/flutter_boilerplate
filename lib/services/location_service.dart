import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/address_model.dart' as model;

final locationService = LocationService.value;

class LocationService {
  static LocationService get value => LocationService._();
  LocationService._();

  final location.Location _location = location.Location();
  StreamSubscription<Position>? _listener;

  Future<bool> requestPermission([bool actionHandling = true]) async {
    bool serviceEnabled = await _location.serviceEnabled();

    if (!serviceEnabled) {
      if (!actionHandling) return false;
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        Geolocator.openLocationSettings();
        return false;
      }
    }

    location.PermissionStatus permissionGranted =
        await _location.hasPermission();

    if (permissionGranted == location.PermissionStatus.denied ||
        permissionGranted == location.PermissionStatus.deniedForever) {
      if (!actionHandling) return false;
      permissionGranted = await _location.requestPermission();
      if (permissionGranted == location.PermissionStatus.denied ||
          permissionGranted == location.PermissionStatus.deniedForever) {
        Geolocator.openAppSettings();
        return false;
      }
    }

    return true;
  }

  fetchLocation(Function(Position)? onChange) async {
    int count = 0;
    await Geolocator.getLastKnownPosition().then(
      (position) async {
        if (position != null) onChange?.call(position);
      },
    ).catchError((error) async {
      log('Error getLastKnownPosition');
      if (count < 2) {
        count++;
        fetchLocation(onChange);
      }
    });
  }

  listenLocation(Function(Position)? onChange,
      {bool enableBackgroundMode = false}) async {
    int count = 0;

    _listener?.cancel();

    _listener = Geolocator.getPositionStream(
            locationSettings: (() {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            forceLocationManager: true,
            intervalDuration: const Duration(seconds: 1),
          );
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return AppleSettings(
            accuracy: LocationAccuracy.high,
            activityType: ActivityType.fitness,
            distanceFilter: 10,
            allowBackgroundLocationUpdates: true,
          );
        default:
          return const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          );
      }
    }()))
        .listen(
      (Position currentLocation) {
        onChange?.call(currentLocation);
      },
      onError: (error) async {
        log(error, name: 'Error onLocationChanged');
        if (count < 3) {
          count++;
          if (await requestPermission(false)) listenLocation(onChange);
        }
      },
      onDone: () => log('onLocationChanged Done'),
      cancelOnError: false,
    );
  }

  pause() => {if (_listener?.isPaused ?? false) _listener?.pause()};

  resume() => _listener?.resume();

  cancel() => {
        if (_listener != null) {_listener!.cancel(), _listener = null}
      };
}

extension PositionExtension on Position {
  Future<model.Address> get address async =>
      await LatLng(latitude, longitude).address;
}

extension LatLngExtension on LatLng {
  Future<model.Address> get address async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
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
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      return model.Address(
        id: 0,
        street: 'Unknown Location',
        createdAt: DateTime.now(),
        latitude: latitude,
        longitude: latitude,
      );
    }
  }
}
