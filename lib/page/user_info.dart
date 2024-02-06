import 'package:bangbang/define/define.dart';
import 'package:bangbang/page/control/chat_data_control.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/join_control.dart';
import 'package:bangbang/page/control/message_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/editinfo/edit_page.dart';
import 'package:bangbang/page/read_history_page.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final colorscheme = Get.theme.colorScheme;

  final RefreshController _refreshController = RefreshController();
  LoadState _loadState = LoadState.none;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserControl>(
      id: "userinfo",
      builder:(UserControl c) => Scaffold(
        body: SmartRefresher(
          controller: _refreshController,
          header:const WaterDropHeader(),
          onRefresh: () async {
            if (_loadState != LoadState.none) {
              return;
            }
            _loadState = LoadState.loading;
            await c.reloadUserInfo();
            _loadState = LoadState.none;
            _refreshController.refreshCompleted();
          },
          child: ListView(
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: colorscheme.secondary,),
                  Text(c.userInfo.name),
                  const Expanded(child: SizedBox()),
                  Text("${c.userInfo.money} 元")
                ],
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: () {
                    Get.to(()=>EditPage());
                  }, child:const Text("编辑资料",style: TextStyle(fontSize: 14),)),
                  FilledButton(onPressed: () {
                    Get.to(()=>const ReadHistoryPage());
                  }, child:const Text("浏览记录"))
                ],
              ),
              ElevatedButton(onPressed: () {
                // 清理
                Get.find<HomeControl>().clear();
                Get.find<MessageControl>().clear();
                Get.find<JoinControl>().clear();
                c.clear();
                ChatDataControl.instance.clear();
                Get.toNamed(Routes.login,arguments: true);

              }, child:const Text("退出登录"))
            ],
          ),
        )
      ),
    );
  }
}