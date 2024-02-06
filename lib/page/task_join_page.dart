import 'package:bangbang/page/compnent/task_chat_item.dart';
// import 'package:bangbang/page/compnent/task_list_title.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/join_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskJoinPage extends StatefulWidget {
  const TaskJoinPage({super.key});

  @override
  State<TaskJoinPage> createState() => _TaskJoinPageState();
}

class _TaskJoinPageState extends State<TaskJoinPage> {
  final _joinControl = Get.find<JoinControl>();
  final _userControl = Get.find<UserControl>();
  late final RefreshController _refreshController;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: _joinControl.taskRefresh);
    _controller = ScrollController(initialScrollOffset: _joinControl.taskOffset);
  }

  @override
  void deactivate() {
    _joinControl.taskOffset = _controller.offset;
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
      body: GetBuilder<JoinControl>(
        id: "joinTaskList",
        builder:(_) => SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          enablePullDown: true,
          header:const WaterDropHeader(),
          footer: CustomFooter(builder: (context, mode) {
              return GetBuilder<JoinControl>(
                id: "joinTaskloadState",
                builder:(_) => Center(child: getLoadStateString(_joinControl.loadMyTaskState))
              );
          },),
          onRefresh: () async {
            _joinControl.taskRefresh = false;
            await _joinControl.refreshTask();
            _refreshController.refreshCompleted(resetFooterState: true);
          },
          onLoading: () async {
            await _joinControl.loadMoreTask();
            _refreshController.loadComplete();
          },
          // physics:const AlwaysScrollableScrollPhysics(),
          child: ListView.builder(
            itemCount: _joinControl.taskList.list.length,
            // physics:const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            itemBuilder: (context, index) {
              return Container(
                margin:const EdgeInsets.only(left: 5,right: 5),
                child: GetBuilder<HomeControl>(
                  id: "task_chat_${_joinControl.taskList.getValue(index)}",
                  builder: (_) {
                    var task = _joinControl.getTask(index);
                    return TaskChatItem(
                      taskInfo: task,
                      cid: _userControl.userInfo.cid,
                      control: _joinControl,
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