import 'package:bangbang/page/control/message_control.dart';
import 'package:bangbang/page/my_task_page.dart';
import 'package:bangbang/page/task_join_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagePage extends StatelessWidget {
  MessagePage({super.key});
  
  final _messageControl = Get.find<MessageControl>();
  // final _tabControl = TabController(length: 2, vsync: this);
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _messageControl.pageIndex,
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            _messageControl.pageIndex = tabController.index;
          });
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title:Container(
                constraints:const BoxConstraints(
                  maxWidth: 200
                ),
                child: TabBar(
                  padding:const EdgeInsets.all(0),
                  onTap: (value) {
                    _messageControl.pageIndex = value;
                  },
                  tabs:const <Widget>[
                    Tab(
                      // icon: Icon(Icons.cloud_outlined),
                      // text: "已报名",
                      // height: 40,
                      child: Text("已报名"),
                    ),
                    Tab(
                      // icon: Icon(Icons.beach_access_sharp),
                      // text: "我的",
                      // height: 40,
                      child: Text("我的"),
                    ),
                  ],
                ),
              ),
            ),
            body:const TabBarView(
              children: <Widget>[
                TaskJoinPage(),
                MyTaskPage(),
              ],
            ),
          );
        }
      ),
    );
  }
}