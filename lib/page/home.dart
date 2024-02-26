import 'package:bangbang/page/control/chat_data_control.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/message_page.dart';
import 'package:bangbang/page/task_page.dart';
import 'package:bangbang/page/user_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final colorscheme = Get.theme.colorScheme;

  @override
  Widget build(BuildContext context) {
    var userControl = Get.find<UserControl>();

    return FutureBuilder(future: userControl.loadUserInfo(), builder: (context, snapshot) => GetBuilder<HomeControl>(
      builder: (HomeControl controller) {
        ChatDataControl.instance.setHomeControl(controller);
        return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: controller.onBarSelected,
          selectedIndex: controller.barindex,
          // backgroundColor: colorscheme.surface,
          surfaceTintColor: colorscheme.surface,
          destinations: const [
            NavigationDestination(icon:Icon(Icons.handshake), label: "help"),
            NavigationDestination(icon:Icon(Icons.messenger), label: "message"),
            NavigationDestination(icon:Icon(Icons.account_circle_rounded), label: "my"),
          ]),
        body: [
          const TaskPage(),
          MessagePage(),
          const UserInfoPage(),
        ][controller.barindex],
      );
      }
    ));
  }
}