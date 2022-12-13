import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/navigation_service.dart';
import '../shared/shared_prefs.dart';
import '../models/address_model.dart';
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

  Address? currentAddress = sharedPrefs.address;

  Future<void> findLocation({
    notifyChanges = false,
    setAsDefault = false,
    Function(LatLng)? onChange,
  }) async {
    if (!notifyChanges) setBusy(true, key: 'fetching_location');
    await LocationService(
      (position) async {
        LatLng latLng = LatLng(position.latitude, position.longitude);
        onChange?.call(latLng);
        this
          ..currentPosition = latLng
          ..currentAddress = await latLng.address;
        setAsDefault ? setDefaultAddress(currentAddress) : notifyListeners();
      },
      listen: notifyChanges,
    ).invoke;
    if (!notifyChanges) setBusy(false, key: 'fetching_location');
  }

  Address defaultAddress = sharedPrefs.address ?? const Address(id: 0);
  setDefaultAddress(dynamic address) async {
    if (address == null) return;

    defaultAddress =
        address is Address ? address : await (address as Position).address;

    notifyListeners();
    sharedPrefs.address = defaultAddress;
  }
}
