import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//Global Private Constant Settings Keys
const String _codexURLKey     = 'codexURL';
const String _webControlsKey  = 'showWebControls';
const String _opdsV2Key       = 'opdsV2';
const String _opdsURLKey      = 'opdsURL';
const String _usernameKey     = 'username';
const String _passwordKey     = 'password';

class SettingsManager {
  static SettingsManager? _instance;
  static late SharedPreferences _preferences;

  SettingsManager._();

  // Using a singleton pattern
  static Future<SettingsManager> getInstance() async {
    _instance ??= SettingsManager._();

    _preferences = await SharedPreferences.getInstance();

    return _instance!;
  }

  // Persist and retrieve codex URL
  String get codexURL => _getData(_codexURLKey) ?? "http://192.168.0.0:9810/f/0/1";
  set codexURL(String value) => _saveData(_codexURLKey, value);

  // Persist and retrieve if 'Show Web Controls' is enabled
  bool get showWebControls => _getData(_webControlsKey) ?? false;
  set showWebControls(bool value) => _saveData(_webControlsKey, value);

  // Persist and retrieve if 'OPDS v2.0' is enabled
  bool get opdsV2 => _getData(_opdsV2Key) ?? false;
  set opdsV2(bool value) => _saveData(_opdsV2Key, value);

  // Persist and retrieve opds URL
  String get opdsURL => _getData(_opdsURLKey) ?? "http://192.168.0.0:9810/opds/v1.2/r/0/1";
  set opdsURL(String value) => _saveData(_opdsURLKey, value);

  Future<String> getUsername() async {
    final value = await _secureStorage.read(key: _usernameKey);

    print('Retrieved $_usernameKey: $value');

    return value ?? "";
  }

  void setUsername(String value) async {
    print('Saving $_usernameKey: $value');

    await _secureStorage.write(key: _usernameKey, value: value);
  }

  Future<String> getPassword() async {
    final value = await _secureStorage.read(key: _passwordKey);

    print('Retrieved $_passwordKey: $value');

    return value ?? "";
  }

   void setPassword(String value) async {
     print('Saving $_passwordKey: $value');

     await _secureStorage.write(key: _passwordKey, value: value);
  }

    // Private generic method for retrieving data from Shared Preferences
    dynamic _getData(String key) {
      // Retrieve data from shared preferences
      var value = _preferences.get(key);

      print('Retrieved $key: $value');

      return value;
    }

// Private method for saving data to Shared Preferences
    void _saveData(String key, dynamic value) {
      print('Saving $key: $value');

      // Save data to Shared Preferences
      if (value is String) {
        _preferences.setString(key, value);
      } else if (value is int) {
        _preferences.setInt(key, value);
      } else if (value is double) {
        _preferences.setDouble(key, value);
      } else if (value is bool) {
        _preferences.setBool(key, value);
      } else if (value is List<String>) {
        _preferences.setStringList(key, value);
      }
    }

}