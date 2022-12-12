import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../shared/shared_prefs.dart';
import '../models/address_model.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import 'base_viewmodel.dart';

class LocationViewModel extends BaseViewModel {
  LocationViewModel(this.context) : super();

  final BuildContext context;

  LatLng? currentPosition = sharedPrefs.address == null
      ? null
      : LatLng(sharedPrefs.address!.latitude!, sharedPrefs.address!.longitude!);
  Address currentAddress = sharedPrefs.address ??
      const Address(id: 0, tag: 'Current Location', street: 'Searching...');

  currentLocation([Function(LatLng?)? listener]) async {
    setBusy(true);
    try {
      await LocationService((position) async {
        setBusy(false);
        listener?.call(LatLng(position.latitude, position.longitude));
      }, listen: false)
          .position;
    } catch (e) {
      listener?.call(null);
      setBusy(false);
    }
  }

  setDefaultLocation() async => await currentLocation(
        (pos) => {if (pos != null) setLocation(position: pos, notify: true)},
      );

  setLocation({LatLng? position, Address? address, bool notify = false}) async {
    if (position == null && address == null) return;

    Location location = const Location();

    currentPosition = LatLng(
      position?.latitude ?? address?.latitude ?? location.latitude,
      position?.longitude ?? address?.longitude ?? location.longitude,
    );

    currentAddress = address ?? await position.address;

    if (notify) notifyListeners();
    sharedPrefs.address = currentAddress;
  }
}
