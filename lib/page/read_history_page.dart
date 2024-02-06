import 'package:bangbang/page/compnent/task_list_title.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/read_history_control.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReadHistoryPage extends StatefulWidget {
  const ReadHistoryPage({super.key});

  @override
  State<ReadHistoryPage> createState() => _ReadHistoryPageState();
}

class _ReadHistoryPageState extends State<ReadHistoryPage> {
  late final RefreshController _refreshController = RefreshController();
  final _readControl = ReadHistoryControl();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _readControl.loadMore(),
      builder: (context,_) {
        return Scaffold(
          appBar: AppBar(
            leading: backButton(),
            title:const Text("浏览记录"),
            centerTitle: true,
          ),
          body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: false,
            enablePullUp: true,
            footer: CustomFooter(builder: (context, mode) {
              return const SizedBox.shrink();
            },),
            onLoading: () async {
              var res = await _readControl.loadMore();
              _refreshController.loadComplete();
              if (res) {
                setState(() {
                  
                });
              }
            },
            child: ListView.builder(
              itemCount: _readControl.taskList.length,
              itemBuilder: (context, index) {
                var task = _readControl.taskList[index];
                return Container(
                        margin:const EdgeInsets.only(top: 10,left: 5,right: 5),
                        child: TaskListTitle(
                          task,
                          onTap: () {
                            Get.toNamed(Routes.taskInfo ,arguments: {"task":task});
                          },
                        ),
                      );
            },),
          ),
        );
      }
    );
  }
}