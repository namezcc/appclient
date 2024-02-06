import 'package:bangbang/common/loger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyStorage {
  static const loginToken = "loginToken";
  static const loginTokenTime = "loginTokenTime";



  static Future<void> saveString(String key,String val) async {
    final pref = await SharedPreferences.getInstance();
    var res = pref.setString(key, val);
    res.then((value) {
      if (value == false) {
        logError("save $key val: $val fail");
      }
    });
  }

  static Future<void> saveInt(String key,int val) async {
    final pref = await SharedPreferences.getInstance();
    var res = pref.setInt(key, val);
    res.then((value) {
      if (value == false) {
        logError("save $key val: $val fail");
      }
    });
  }

  static Future<String> getString(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(key) ?? "";
  }

  static Future<int> getInt(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt(key) ?? 0;
  }
}