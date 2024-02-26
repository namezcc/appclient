import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/control/task_refresh_control.dart';

class MessageControl extends TaskRefreshControl {
  int pageIndex = 0;

  MessageControl():super("myTaskloadState","myTaskList");
  
  @override
  Future<List<JsonTaskInfo>?> loadTask() async {
    var res = await apiLoadMyTaskList(taskSkip);
    res = res?.reversed.toList();
    return res;
    
  }
}