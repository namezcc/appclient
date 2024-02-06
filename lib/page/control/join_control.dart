import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/control/task_refresh_control.dart';

class JoinControl extends TaskRefreshControl {
  JoinControl():super("joinTaskloadState","joinTaskList");
  
  @override
  Future<List<JsonTaskInfo>?> loadTask() async {
    return await apiLoadJoinTaskList(taskSkip);
    
  }
}