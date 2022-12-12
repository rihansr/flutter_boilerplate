import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../services/navigation_service.dart';
import '../shared/shared_prefs.dart';
import '../models/address_model.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import '../utils/debug.dart';
import '../utils/validator.dart';
import 'base_viewmodel.dart';

LocationViewModel locationProvider({BuildContext? context, listen = false}) =>
    Provider.of<LocationViewModel>(context ?? navigator.context,
        listen: listen);

class LocationViewModel extends BaseViewModel {
  LocationViewModel(this.context) : super();

  final BuildContext context;

  LatLng? currentPosition = sharedPrefs.address == null
      ? null
      : LatLng(sharedPrefs.address!.latitude!, sharedPrefs.address!.longitude!);
  Address currentAddress = sharedPrefs.address ??
      const Address(id: 0, label: 'Current Location', street: 'Searching...');

  Future<void> fetchLocation([Function(LatLng?)? listener]) async {
    setBusy(true);
    await LocationService(
            (position) => {
                  debug.print(position.toJson(), boundedText: 'Position'),
                  position.address.then((address) =>
                      debug.print(address.toJson(), boundedText: 'Address')),
                  listener?.call(LatLng(position.latitude, position.longitude)),
                  setLocation(position, true)
                },
            listen: true)
        .invoke;
    setBusy(false);
  }

  Future<List<Location>> searchLocations(String? query) async {
    if (validator.isEmpty(query)) return [];
    Response response = await api.invoke(
      via: InvokeType.dio,
      method: Method.get,
      baseUrl: 'https://nominatim.openstreetmap.org',
      endpoint: 'search.php',
      queryParams: {
        'q': query,
        'accept-language': sharedPrefs.settings.locale.languageCode,
        'countrycodes': sharedPrefs.address?.countryCode,
        'format': 'jsonv2',
      }..removeWhere((key, value) => value == null),
      showMessage: true,
      cacheSubKey: query,
      cacheDuration: const Duration(minutes: 1),
    );

    return response.data == null
        ? []
        : List<Location>.from(
            response.data.map((json) => Location.fromJson(json)),
          );
  }

  setDefaultLocation() async => await fetchLocation(
        (pos) => {if (pos != null) setLocation(pos, true)},
      );

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
}
