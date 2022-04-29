import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:movie2/MyApp.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'data/Profile.dart';

class Global {
  static late PackageInfo packageInfo;
  static late SharedPreferences _prefs;
  static Profile profile = Profile();
  static late final String uid;
  static bool initMain = false;
  static late BuildContext mainContext;
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    // if(Platform.isAndroid || Platform.isIOS){
    //   packageInfo = await PackageInfo.fromPlatform();
    //   print(packageInfo.buildNumber);
    // }
    _prefs = await SharedPreferences.getInstance();
    var _profile = _prefs.getString("profile");
    if (_profile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
      } catch (e) {
        print(e);
      }
    }
    if(kIsWeb == false) {
      uid = await getUUID();
    }
    runApp(const MyApp());
  }
  static Future<String> getUUID() async {
    String uid = '';
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        uid = build.androidId;
        // print(uid);
        //UUID for Android
      } else if (Platform.isIOS) {
        var build = await deviceInfoPlugin.iosInfo;
        uid = build.identifierForVendor;
        // uid = await FlutterUdid.udid;
      }else{
        uid = 'test';
      }
      return uid;
    } on PlatformException {
    }
    return uid;
  }
  static saveProfile() => _prefs.setString("profile", jsonEncode(profile.toJson()));
}