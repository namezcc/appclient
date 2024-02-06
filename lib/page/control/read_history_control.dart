import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/util/db_util.dart';
import 'package:get/get.dart';

class ReadHistoryControl extends GetxController {
  final List<JsonTaskInfo> taskList = [];
  bool _loadOver = false;

  Future<bool> loadMore() async {
    if (_loadOver) {
      return false;
    }
    var newtask = await DbUtil.instance.loadReadTask(taskList.length);
    if (newtask.isNotEmpty) {
      taskList.addAll(newtask);
    }
    if (newtask.length < 20) {
      _loadOver = true;
    }
    return newtask.isNotEmpty;
  }



}