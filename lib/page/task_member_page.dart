import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskMemberPage extends StatelessWidget {
  final colorscheme = Get.theme.colorScheme;
  final JsonTaskInfo _taskInfo = Get.arguments["task"];
  final UserControl _userControl = Get.find<UserControl>();

  TaskMemberPage({super.key});
  
  Widget getIcon(JsonSimpleUserInfo i) {
    if (i.sex == sexMan) {
      return const Icon(Icons.male,color: Colors.blue,);
    }else{
      return Icon(Icons.female,color: Colors.pink.shade400,);
    }
  }

  Future<void> kickPeople(int cid) async {
    var res = await apiKickTask(_taskInfo.id, cid);
    if (res != null) {
      _taskInfo.join = res.join;
      final homeControl = Get.find<HomeControl>();
      homeControl.updateAllTaskOne(_taskInfo);
    }else{
      showToastMsg("服务器错误");
    }
    Get.back();
  }

  Widget buildOptButton(JsonSimpleUserInfo info) {
    if (info.state == FinishState.none.index) {
      return CupertinoButton(
        onPressed: () {
          Get.defaultDialog(
            title: "",
            content: Text("踢掉${info.name}吗?"),
            onConfirm: () {
              kickPeople(info.cid);
            },
            textConfirm: "确定",
            textCancel: "取消",
          );
        },
        child:const Text("踢出"),
      );
    }else{
      return const ElevatedButton(onPressed: null, child: Text("已完成"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("已报名"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: colorscheme.primary,),
          onPressed: ()=> Get.back()),
      ),
      body: GetBuilder<HomeControl>(
        id: "task_${_taskInfo.id}",
        builder: (_) {
          return ListView.builder(
            itemCount: _taskInfo.join.data.length,
            itemBuilder: (context, index) {
              var joininfo = _taskInfo.join.data[index];
              var cid = _userControl.userInfo.cid;
              return Card(
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ToolCompnent.toUserPage(ToolCompnent.headIcon(joininfo.icon),_taskInfo.cid),
                      getIcon(joininfo)
                    ]
                  ),
                  title: Text(joininfo.name),
                  trailing: (cid == _taskInfo.cid ) ? buildOptButton(joininfo) : null,
                ),
              );
            },);
        }
      ),
    );
  }
  
}