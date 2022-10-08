import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserSettings {
  static SharedPreferences? _preferences;

  static const _keyUID = 'keyString0';


//initializer
  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  //uid setter
  static Future setUID(String uid) async =>
      await _preferences?.setString(_keyUID, uid);

  //user key getter (remove initial key once google login complete!)
  static String getUID() => _preferences?.getString(_keyUID) ?? '';
}

//provides instances for Provider!
class UserProvider extends ChangeNotifier {
  String _uid = '';
  String get uid => _uid;

  //initializer
  UserProvider() {
    getUID();
  }

  getUID() async {
    _uid = UserSettings.getUID();
    notifyListeners();
  }

  set uid(String value) {
    _uid = value;
    UserSettings.setUID(value);
    notifyListeners();
  }
}
