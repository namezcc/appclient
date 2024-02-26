import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/page/compnent/task_list_title.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/map_location_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/search_page.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:bangbang/util/db_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TaskPage();
  }

}

class _TaskPage extends State<TaskPage> {
  final _userControl = Get.find<UserControl>();
  final _homeControl = Get.find<HomeControl>();
  final _locationControl = Get.find<MapLocationControl>();
  late final ScrollController _controller;
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: _homeControl.taskInitRefresh);
    _controller = ScrollController(initialScrollOffset: _homeControl.taskListOffset);
    if (_homeControl.getLocation == false) {
      initLocation();
    }
  }

  @override
  void deactivate() {
    _homeControl.setTaskListOffset(_controller.offset);
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void refreshList() async {
    _homeControl.setTaskRefresh();
    await _homeControl.refreshTask();
    _refreshController.refreshCompleted(resetFooterState: true);
  }

  void initLocation() async {
      await _locationControl.loadLocation();
      getLocation();
  }

  Future<void> getLocation() async {
    _locationControl.startLoaction((res) {
      _refreshController.requestRefresh();
      _homeControl.getLocation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorscheme = Get.theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        // title:const Text("task"),
        // centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            // Get.dialog( Center(
            //         child:Material(
            //           color: Colors.transparent,
            //           child: Container(
            //             // height: 50,
            //             // width: Get.mediaQuery.size.width - 50,
            //             // alignment: Alignment.center,
            //             // padding:const EdgeInsets.only(bottom: 28),
            //             constraints: BoxConstraints(
            //               minHeight: 200,
            //               minWidth: Get.mediaQuery.size.width*0.7
            //             ),
            //             decoration: BoxDecoration(
            //               color: colorscheme.surface,
            //               borderRadius: BorderRadius.circular(10)
            //             ),
            //             child:const Text("aaaa"),
            //           ),
            //         ),
            //       ),
            //   useSafeArea: false
            //   );
            Get.to(()=>const SearchPage());
          }, icon: Icon(Icons.search,color: colorscheme.primary))
        ],
        leading: IconButton(
          onPressed: (){
            if (GlobalData.isLogin()) {
              Get.toNamed(Routes.addtask);
            }else{
              Get.toNamed(Routes.login);
              showToastMsg("请先登录");
            }
          },
          icon: Icon(Icons.add_circle_outline,color: colorscheme.primary),
        ),
      ),
      // backgroundColor: colorscheme.onPrimary,
      body: GetBuilder<HomeControl>(
        builder: (HomeControl controller) => SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          // scrollController: _controller,
          enablePullUp: true,
          header:const WaterDropHeader(),
          footer: CustomFooter(builder: (context, mode) {
            return GetBuilder<HomeControl>(
              id: "loadState",
              builder:(HomeControl homeControl) => Center(child: getLoadStateString(homeControl.loadTaskState))
            );
          },),
          onRefresh: refreshList,
          onLoading: () async {
            await controller.loadMoreTask();
            _refreshController.loadComplete();
          },
          // physics: const AlwaysScrollableScrollPhysics(),
          child: ListView.builder(
              itemCount: controller.taskList.list.length,
              // physics:const AlwaysScrollableScrollPhysics(),
              controller: _controller,
              itemBuilder: (context, index) {
                return GetBuilder<HomeControl>(
                  id: "task_${controller.taskList.list[index]}",
                  builder: (_) {
                    var task = controller.getHomeTask(index);
                    return Container(
                        margin:const EdgeInsets.only(top: 0,left: 5,right: 5),
                        child: TaskListTitle(
                          task,
                          onTap: () {
                            Get.toNamed(Routes.taskInfo ,arguments: {"task":task});
                            // 保存记录
                            if (_userControl.isLogin() && _userControl.userInfo.cid != task.cid) {
                              DbUtil.instance.saveReadTask(task);
                            }
                          },
                        ),
                      );
                  }
                );
              },
          ),
        ),
      )
    );
  }

}