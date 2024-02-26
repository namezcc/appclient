import 'package:bangbang/page/compnent/task_list_title.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/interest_task_control.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InterestTaskPage extends StatefulWidget {
  const InterestTaskPage({super.key});

  @override
  State<InterestTaskPage> createState() => _InterestTaskPageState();
}

class _InterestTaskPageState extends State<InterestTaskPage> {
  final _interestControl = Get.find<InterestControl>();
  late final RefreshController _refreshController;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();

    _refreshController = RefreshController(initialRefresh: _interestControl.taskRefresh);
    _controller = ScrollController(initialScrollOffset: _interestControl.taskOffset);
  }

  @override
  void deactivate() {
    _interestControl.taskOffset = _controller.offset;

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
      body: GetBuilder<InterestControl>(
        id: "interestList",
        builder: (_) => SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          enablePullDown: true,
          header:const WaterDropHeader(),
          footer: CustomFooter(builder: (context, mode) {
              return GetBuilder<InterestControl>(
                id: "interestState",
                builder:(_) => Center(child: getLoadStateString(_interestControl.loadMyTaskState))
              );
          },),
          onRefresh: () async {
            _interestControl.taskRefresh = false;
            await _interestControl.refreshTask();
            _refreshController.refreshCompleted(resetFooterState: true);
          },
          onLoading: () async {
            await _interestControl.loadMoreTask();
            _refreshController.loadComplete();
          },
          child: ListView.builder(
            itemCount: _interestControl.taskList.list.length,
            controller: _controller,
            itemBuilder: (context, index) {
              return Container(
                margin:const EdgeInsets.only(left: 5,right: 5),
                child: GetBuilder<HomeControl>(
                  id: "task_chat_${_interestControl.taskList.list[index]}",
                  builder: (_) {
                    var task = _interestControl.getTask(index);
                    return Container(
                        margin:const EdgeInsets.only(top: 0,left: 5,right: 5),
                        child: TaskListTitle(
                          task,
                          onTap: () {
                            Get.toNamed(Routes.taskInfo ,arguments: {"task":task});
                          },
                        ),
                      );
                  }
                ),
              );
            },
          ),
        ),),
    );
  }
}