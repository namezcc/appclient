import 'package:bangbang/page/compnent/task_chat_item.dart';
// import 'package:bangbang/page/compnent/task_list_title.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/message_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyTaskPage extends StatefulWidget {
  const MyTaskPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyTaskPage();
  }
  
}

class _MyTaskPage extends State<MyTaskPage> {
  final _messageControl = Get.find<MessageControl>();
  final _userControl = Get.find<UserControl>();
  late final RefreshController _refreshController;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: _messageControl.taskRefresh);
    _controller = ScrollController(initialScrollOffset: _messageControl.taskOffset);
  }

  @override
  void deactivate() {
    _messageControl.taskOffset = _controller.offset;
    super.deactivate();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MessageControl>(
        id: "myTaskList",
        builder:(_) => SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          enablePullDown: true,
          header:const WaterDropHeader(),
          footer: CustomFooter(builder: (context, mode) {
              return GetBuilder<MessageControl>(
                id: "myTaskloadState",
                builder:(_) => Center(child: getLoadStateString(_messageControl.loadMyTaskState))
              );
          },),
          onRefresh: () async {
            _messageControl.taskRefresh = false;
            await _messageControl.refreshTask();
            _refreshController.refreshCompleted(resetFooterState: true);
          },
          onLoading: () async {
            await _messageControl.loadMoreTask();
            _refreshController.loadComplete();
          },
          // physics:const AlwaysScrollableScrollPhysics(),
          child: ListView.builder(
            itemCount: _messageControl.taskList.list.length,
            // physics:const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            itemBuilder: (context, index) {
              return Container(
                margin:const EdgeInsets.only(left: 5,right: 5),
                child: GetBuilder<HomeControl>(
                  id: "task_chat_${_messageControl.taskList.list[index]}",
                  builder: (_) {
                    var task = _messageControl.getTask(index);
                    return TaskChatItem(taskInfo: task,
                      cid: _userControl.userInfo.cid,
                      control: _messageControl,
                      onTap: () async {
                        await Get.toNamed(Routes.taskTalk,arguments: {"task":task});
                        _.refreshTaskChatState(task.id);
                      },
                    );
                  }
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
}