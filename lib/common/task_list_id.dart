import 'package:bangbang/define/json_class.dart';

class TaskListId {
  List<String> list = [];
  final Map<String,int> _check = {};

  void addList(List<JsonTaskInfo> taskList) {
    for (var e in taskList) {
      if (_check[e.id] == null) {
        list.add(e.id);
        _check[e.id] = 1;
      }
    }
  }

  void clear() {
    list.clear();
    _check.clear();
  }

  void removeTask(JsonTaskInfo t) {
    list.removeWhere((element) => element == t.id);
    _check.remove(t.id);
  }

  void insertTask(JsonTaskInfo t,int index) {
    if (_check[t.id] == null) {
      list.insert(index, t.id);
      _check[t.id] = 1;
    }
  }

  String getValue(int index) {
    return list.elementAtOrNull(index) ?? "";
  }
}