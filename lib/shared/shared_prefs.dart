import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';
import '../utils/validator.dart';
import '/models/settings_model.dart';

final sharedPrefs = SharedPrefs.value;

class SharedPrefs {
  static SharedPrefs get value => SharedPrefs._();
  SharedPrefs._();

  late SharedPreferences _sharedPrefs;

  Future init() async => _sharedPrefs = await SharedPreferences.getInstance();

  static const String _settingsKey = "settings_sp_key";
  static const String _locationKey = "location_sp_key";

  // Settings
  set settings(Settings settings) =>
      _sharedPrefs.setString(_settingsKey, json.encode(settings.toJson()));
  Settings get settings => _sharedPrefs.getString(_settingsKey) == null
      ? const Settings()
      : Settings.fromJson(json.decode(_sharedPrefs.getString(_settingsKey)!));

  // Address
  Address? get address {
    String? address = _sharedPrefs.getString(_locationKey);
    return validator.isEmpty(address) ? null : addressFromJson(address!);
  }

  set address(Address? address) => _sharedPrefs.setString(
      _locationKey, address == null ? '' : addressToJson(address));
}
