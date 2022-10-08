import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserSettings {
  static SharedPreferences? _preferences;

  static const _keyUID = 'keyString0';
  static const _keyDevice = 'keyDevice';
  static const _keyDevList = 'keyDeviceList1';

//initializer
  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  //uid setter
  static Future setUID(String uid) async =>
      await _preferences?.setString(_keyUID, uid);

  //user key getter (remove initial key once google login complete!)
  static String getUID() => _preferences?.getString(_keyUID) ?? '';

//sets currently selected device
  static Future setDevice(int device) async =>
      await _preferences?.setInt(_keyDevice, device);

  static int getDevice() => _preferences?.getInt(_keyDevice) ?? 0;

//json list of device names and their keys
  static Future setDeviceList(String deviceList) async =>
      await _preferences?.setString(_keyDevList, deviceList);

  static String getDeviceList() =>
      _preferences?.getString(_keyDevList) ?? '[["LampRP", "33332524"],["LampESP","18128"]]';
}

//provides instances for Provider!
class UserProvider extends ChangeNotifier {
  String _uid = '';
  String get uid => _uid;

  int _device = 0;
  int get device => _device;

  String _deviceList = '[['', '']]';
  String get deviceList => _deviceList;

  //initializer
  UserProvider() {
    getUID();
    getDevice();
    getDeviceList();
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

  getDevice() async {
    _device = UserSettings.getDevice();
    notifyListeners();
  }

  set device(int value) {
    _device = value;
    UserSettings.setDevice(value);
    notifyListeners();
  }

  
  getDeviceList() async {
    _deviceList = UserSettings.getDeviceList();
    notifyListeners();
  }

  set deviceList(String value) {
    _deviceList = value;
    UserSettings.setDeviceList(value.toString());
    notifyListeners();
  }
}
