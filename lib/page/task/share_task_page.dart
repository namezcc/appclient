import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/compnent/task_list_title.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/chat_data_control.dart';
import 'package:bangbang/page/control/task_refresh_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ShareTaskPage<T extends TaskRefreshControl> extends StatefulWidget {
  const ShareTaskPage({super.key});

  @override
  State<ShareTaskPage> createState() => _ShareTaskPageState<T>();
}

class _ShareTaskPageState<T extends TaskRefreshControl> extends State<ShareTaskPage> {
  final UserControl _userControl = Get.find<UserControl>();
  final _taskRefreshControl = Get.find<T>();
  final JsonTaskInfo _taskInfo = Get.arguments["task"];
  final RefreshController _refreshController = RefreshController();
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    
    _refreshController.dispose();
    _controller.dispose();

    super.dispose();
  }

  void sendChatTask(String taskid) {
    var msg = ToolCompnent.buildTaskChat(_taskInfo,_userControl.userInfo);
    ChatDataControl.instance.sendTaskChat(taskid, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title:const Text("分享到"),
        centerTitle: true,
      ),
      body: GetBuilder<T>(
        id: _taskRefreshControl.taskListId,
        builder:(_) => SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          enablePullDown: true,
          header:const WaterDropHeader(),
          footer: CustomFooter(builder: (context, mode) {
              return GetBuilder<T>(
                id: _taskRefreshControl.loadStateId,
                builder:(_) => Center(child: getLoadStateString(_taskRefreshControl.loadMyTaskState))
              );
          },),
          onRefresh: () async {
            _taskRefreshControl.taskRefresh = false;
            await _taskRefreshControl.refreshTask();
            _refreshController.refreshCompleted(resetFooterState: true);
          },
          onLoading: () async {
            await _taskRefreshControl.loadMoreTask();
            _refreshController.loadComplete();
          },
          // physics:const AlwaysScrollableScrollPhysics(),
          child: ListView.builder(
            itemCount: _taskRefreshControl.taskList.list.length,
            // physics:const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            itemBuilder: (context, index) {
              var task = _taskRefreshControl.getTask(index);
              return Container(
                margin:const EdgeInsets.only(left: 5,right: 5),
                child: TaskListTitle(
                  task,
                  onTap: () {
                    ToolCompnent.bottomSheetDialog(const Text("分享到该任务"), "确定", "取消",onCancel: () {
                      Get.back();
                    },onConfirm: () {
                      sendChatTask(task.id);
                      showToastMsg("已发送");
                      Get.back(result: true);
                    },);
                  },
                )
              );
            },
          ),
        ),
      ),
    );
  }
}