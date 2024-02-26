import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/tcp_control.dart';
import 'package:bangbang/util/db_util.dart';
import 'package:get/get.dart';

class UserControl extends GetxController {
  JsonUserInfo userInfo = JsonUserInfo(0, "", "",0);
  List<int> blackList = [];
  final List<String> _userInterestTask = [];

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
    // 黑名单
    _loadBlackList();
    // 收藏
    _loadInterest();
    update();
    return true;
  }

  bool isLogin() {
    return userInfo.cid > 0;
  }

  Future<void> reloadUserInfo() async {
    final info = await apiGetUserInfo();
    if (info != null) {
      userInfo = info.data;
      update();
    }
  }

  Future<void> _loadBlackList() async {
    var res = await apiGetBlackList();
    if (res != null) {
      blackList = res.data;
    }
  }

  Future<void> _loadInterest() async {
    var res = await apiLoadInterest();
    if (res != null) {
      _userInterestTask.clear();
      _userInterestTask.addAll(res.data);
    }
  }

  bool isInterestTask(String taskid) {
    return _userInterestTask.contains(taskid);
  }

  Future<bool> pushTaskInterest(String taskid) async {
    if (_userInterestTask.length >= maxInterestTask) {
      showToastMsg("兴趣列表已达上限,请清理");
      return false;
    }
    var res = await apiTaskPushInterest(taskid);
    if (res != null && res.code == ErrorCode.errSuccess) {
      showToastMsg("已加入兴趣列表,在 消息-兴趣 查看");
      _userInterestTask.add(taskid);
      return true;
    }else{
      showToastMsg("服务器错误");
      return true;
    }
  }

  void pullTaskInterest(String taskid) {
    apiTaskPullInterest(taskid);
    _userInterestTask.remove(taskid);
  }

  bool isInBlackList(int cid) {
    for (var e in blackList) {
      if (e == cid) {
        return true;
      }
    }
    return false;
  }

  void pushBlackList(int cid) async {
    var res = await apiPushBlackList(cid);
    if (res) {
      blackList.add(cid);
      showToastMsg("已拉黑");
    }else{
      showToastMsg("操作失败");
    }
  }

  void removeBlackList(int cid) async {
    var res = await apiPullBlackList(cid);
    if (res) {
      blackList.remove(cid);
      showToastMsg("已移出黑名单");
    }else{
      showToastMsg("操作失败");
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

  void updateIcon(String icon) {
    userInfo.icon = icon;
    update(["userinfo"]);
  }
}