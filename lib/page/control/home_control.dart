import 'package:bangbang/common/task_list_id.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:get/get.dart';
import 'package:bangbang/define/define.dart';


class HomeControl extends GetxController {
  Map<String,JsonTaskInfo> allTaskList = {};

  int barindex = 0;
  final TaskListId taskList = TaskListId();
  LoadState loadTaskState = LoadState.none;
  TaskConfig taskConfig = TaskConfig(0, 0, 0, 0, 0,0,0);
  bool taskInitRefresh = false;
  bool getLocation = false;
  double taskListOffset = 0;
  JsonAddressInfo? myLocation;

  void clear() {
    allTaskList.clear();
    taskList.clear();
    taskConfig = TaskConfig(0, 0, 0, 0, 0,0,0);
    taskInitRefresh = false;
    getLocation = false;
    taskListOffset = 0;
    update();
  }  

  void onBarSelected(int index) {
    barindex = index;
    update();
  }

  Future<List<JsonTaskInfo>> getList() async {
    // 从服务器获取数据
    setLoadTaskState(LoadState.loading);
    var taskres = await apiGetTaskInfo(taskConfig);
    if (taskres == null) {
      setLoadTaskState(LoadState.error);
    }else{
      if (taskres.data.data.isEmpty) {
        setLoadTaskState(LoadState.noMore);
      }else{
        taskConfig = taskres.data.config;
        if (taskConfig.globelMax > 0 && taskConfig.locMax > 0) {
          setLoadTaskState(LoadState.noMore);
        }else{
          setLoadTaskState(LoadState.none);
        }
        return taskres.data.data;
      }
    }
    // 返回数据
    return [];
  }

  Future<void> refreshTask() async {
    if (loadTaskState == LoadState.loading) {
      return;
    }
    taskConfig = TaskConfig(0, 0, 0, 0, 0,0,0);
    // 获取数据
    var list = await getList();
    // 更新列表
    updateAllTaskList(list);
    taskList.clear();
    taskList.addList(list);
    update();
  }

  void setLoadTaskState(LoadState state) {
    loadTaskState = state;
    update(["loadState"]);
  }

  Future<void> loadMoreTask() async {
    if (loadTaskState == LoadState.loading || loadTaskState == LoadState.noMore) {
      return;
    }
    // 获取数据
    List<JsonTaskInfo> list = await getList();
    // 更新列表
    if (list.isNotEmpty) {
      updateAllTaskList(list);
      taskList.addList(list);
      update();
    }
  }

  void setTaskRefresh() {
    taskInitRefresh = false;
  }

  void setTaskListOffset(double offset) {
    taskListOffset = offset;
  }

  void removeTaskInfo(JsonTaskInfo task) {
    task.delete = 1;
    updateAllTaskOne(task);
    taskList.removeTask(task);
    update();
  }

  void updateAllTaskList(List<JsonTaskInfo> list) {
    for (var e in list) {
      allTaskList[e.id] = e;
    }
  }

  void updateAllTaskOne(JsonTaskInfo t) {
    var old = allTaskList[t.id];
    if (old != null) {
      old.copyFrom(t);
    }else{
      allTaskList[t.id] = t;
    }
    update(["task_${t.id}","task_chat_${t.id}"]);
  }

  void refreshTaskState(String id) {
    update(["task_$id","task_chat_$id"]);
  }

  void refreshTaskChatState(String id) {
    update(["task_chat_$id"]);
  }

  JsonTaskInfo getTask(String id) {
    return allTaskList[id] ?? TaskUtil.empttTask;
  }

  JsonTaskInfo getHomeTask(int index) {
    return getTask(taskList.list[index]);
  }
}