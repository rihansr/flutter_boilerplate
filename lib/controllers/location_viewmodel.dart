import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/navigation_service.dart';
import '../shared/shared_prefs.dart';
import '../models/address_model.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import 'base_viewmodel.dart';

LocationViewModel locationProvider(BuildContext? context, {listen = false}) =>
    Provider.of<LocationViewModel>(context ?? navigator.context,
        listen: listen);

class LocationViewModel extends BaseViewModel {
  LocationViewModel(this.context) : super();

  final BuildContext context;

  LatLng? currentPosition = sharedPrefs.address == null
      ? null
      : LatLng(sharedPrefs.address!.latitude!, sharedPrefs.address!.longitude!);
  Address currentAddress = sharedPrefs.address ?? const Address(id: 0);

  Future<void> fetchLocation({
    Function(LatLng)? onChange,
    notify = true,
    autoListen = true,
  }) async {
    setBusy(true, key: 'fetching_location');
    await LocationService(
      (position) => {
        onChange?.call(LatLng(position.latitude, position.longitude)),
        setLocation(position, notify),
      },
      listen: autoListen,
    ).invoke;
    setBusy(false, key: 'fetching_location');
  }

  setLocation(dynamic location, [bool notify = false]) async {
    if (location == null) return;

    currentPosition = LatLng(
      location?.latitude ?? const Location().latitude,
      location?.longitude ?? const Location().longitude,
    );

    currentAddress =
        location is Address ? location : await (location as Position).address;

    if (notify) notifyListeners();
    sharedPrefs.address = currentAddress;
  }

  Future<Address> getLocation(LatLng? position) async => await position.address;
}
