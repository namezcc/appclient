import 'package:bangbang/common/loger.dart';

class GlobalData {
  static String hostBase = "";
  static String jwtToken = "";
  static bool runApp = false;

  static void setHostBase(String url) {
    hostBase = url;
  }

  static void setJwtToken(String token) {
    jwtToken = token;
  }

  static bool isLogin() {
    return jwtToken != "";
  }

  static void setRunApp(){
    logInfo("app ready ...");
    runApp = true;
  }
}