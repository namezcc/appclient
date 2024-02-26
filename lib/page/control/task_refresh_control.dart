
import 'package:bangbang/common/task_list_id.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:get/get.dart';

abstract class TaskRefreshControl extends GetxController {
  String loadStateId;
  String taskListId;
  TaskRefreshControl(this.loadStateId,this.taskListId);

  final TaskListId taskList = TaskListId();
  LoadState loadMyTaskState = LoadState.none;
  bool taskRefresh = true;
  double taskOffset = 0;
  int taskSkip = 0;

  void clear() {
    taskList.clear();
    taskRefresh = true;
    taskOffset = 0;
    taskSkip = 0;
    update([taskListId]);
  }

  Future<List<JsonTaskInfo>?> loadTask();

  Future<List<JsonTaskInfo>> _getList() async {
    // 从服务器获取数据
    setLoadTaskState(LoadState.loading);
    var taskres = await loadTask();
    if (taskres == null) {
      setLoadTaskState(LoadState.error);
    }else{
      if (taskres.isEmpty) {
        setLoadTaskState(LoadState.noMore);
      }else{
        taskSkip += taskres.length;
        if (taskres.length < 20) {
          setLoadTaskState(LoadState.noMore);
        }else{
          setLoadTaskState(LoadState.none);
        }
        return taskres;
      }
    }
    // 返回数据
    return [];
  }

  Future<void> refreshTask() async {
    if (loadMyTaskState == LoadState.loading) {
      return;
    }
    taskSkip = 0;
    // 获取数据
    var list = await _getList();
    var homeControl = Get.find<HomeControl>();
    homeControl.updateAllTaskList(list);
    // 更新列表
    taskList.clear();
    taskList.addList(list);
    update([taskListId]);
  }

  Future<void> loadMoreTask() async {
    if (loadMyTaskState == LoadState.loading || loadMyTaskState == LoadState.noMore) {
      return;
    }
    // 获取数据
    List<JsonTaskInfo> list = await _getList();
    // 更新列表
    if (list.isNotEmpty) {
      var homeControl = Get.find<HomeControl>();
      homeControl.updateAllTaskList(list);
      taskList.addList(list);
      update([taskListId]);
    }
  }

  void setLoadTaskState(LoadState state) {
    loadMyTaskState = state;
    update([loadStateId]);
  }

  void addTask(JsonTaskInfo task) {
    var homeControl = Get.find<HomeControl>();
    homeControl.updateAllTaskOne(task);
    taskList.insertTask(task, 0);
    update([taskListId]);
  }

  void removeTask(JsonTaskInfo task) {
    taskList.removeTask(task);
    update([taskListId]);
  }

  JsonTaskInfo getTask(int index) {
    var homeControl = Get.find<HomeControl>();
    return homeControl.getTask(taskList.getValue(index));
  }

}