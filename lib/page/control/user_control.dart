import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/tcp_control.dart';
import 'package:bangbang/util/db_util.dart';
import 'package:get/get.dart';

class UserControl extends GetxController {
  JsonUserInfo userInfo = JsonUserInfo(0, "", "",0);

  void clear() {
    userInfo = JsonUserInfo(0, "", "",0);
  }

  Future<bool> loadUserInfo() async {
    if (!GlobalData.isLogin()) {
      return false;
    }
    if (userInfo.cid > 0) {
      return true;
    }
    final info = await apiGetUserInfo();
    if (info == null) {
      showToastMsg("获取用户信息失败");
      return false;
    }
    userInfo = info.data;
    // 初始化数据库
    await DbUtil.instance.initDb(userInfo.cid);
    // 链接tcp
    TcpControl.instance.connectServer();
    update();
    return true;
  }

  Future<void> reloadUserInfo() async {
    final info = await apiGetUserInfo();
    if (info != null) {
      userInfo = info.data;
      update();
    }
  }

  void updateName(String name) {
    userInfo.name = name;
    update(["userinfo"]);
  }

  void updateSex(int sex) {
    userInfo.sex = sex;
    update(["userinfo"]);
  }
}