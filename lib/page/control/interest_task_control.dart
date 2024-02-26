import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/control/task_refresh_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:get/get.dart';

class InterestControl extends TaskRefreshControl {
  InterestControl():super("interestState","interestList");

  @override
  Future<List<JsonTaskInfo>?> loadTask() async {
    var res = await apiLoadInterestTask(taskSkip);
    res = res?.reversed.toList();
    return res;
  }

  void pullTaskInterest(JsonTaskInfo t) async {
    removeTask(t);
    Get.find<UserControl>().pullTaskInterest(t.id);
  }
  
}