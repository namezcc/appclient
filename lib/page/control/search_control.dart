
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/control/task_refresh_control.dart';

class SearchControl extends TaskRefreshControl {

  SearchControl():super("searchloadState","searchList");

  TaskConfig taskConfig = TaskConfig(0, 0, 0, 0, 0,0,0);

  @override
  Future<List<JsonTaskInfo>?> loadTask() async {
    var res = await apiSearchTask(taskConfig);
    if (res != null) {
      taskConfig = res.data.config;
      return res.data.data;
    }
    return null;
  }

  void resetSearchText(String text) {
    taskConfig = TaskConfig(0, 0, 0, 0, 0,0,0);
    taskConfig.search = text;
  }

  bool isSearchEmpty() {
    return taskConfig.search.isEmpty;
  }
  
}