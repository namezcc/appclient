
import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/common/storage.dart';
import 'package:bangbang/handle/api_handle.dart';

class LoginLogic {
  static Future<void> refreshLoginToken() async {
    var token = await MyStorage.getString(MyStorage.loginToken);
    if (token == "") {
      return;
    }
    var tokenTime = await MyStorage.getInt(MyStorage.loginTokenTime);
    final diff = DateTime.now().millisecondsSinceEpoch - tokenTime;
    final diffday = diff ~/ (3600*24*1000);
    if (diffday  < 0) {
      return;
    }

    await apiUserRefreshToken(token);

    if (!GlobalData.isLogin()) {
      logDebug("没有登录信息去登录页");
      // AppPages.inital = Routes.login;
    }else{
      logDebug("登录去home页");
      // AppPages.inital = Routes.userinfo;
    }
  }
}