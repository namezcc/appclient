import 'package:bangbang/page/add_task_page.dart';
import 'package:bangbang/page/binding/chat_binding.dart';
import 'package:bangbang/page/binding/home_binding.dart';
import 'package:bangbang/page/binding/user_bind.dart';
import 'package:bangbang/page/home.dart';
import 'package:bangbang/page/loading.dart';
import 'package:bangbang/page/login.dart';
import 'package:bangbang/page/show_map.dart';
import 'package:bangbang/page/task_info_page.dart';
import 'package:bangbang/page/task_member_page.dart';
import 'package:bangbang/page/task_talk_page.dart';
import 'package:get/get.dart';

part 'app_route.dart';


class AppPages {
  static String inital = Routes.home;

  static final routs = [
    GetPage(name: Routes.home, page: ()=>const HomePage(),bindings: [HomeBinding(),UserBinding()]),
    GetPage(name: Routes.login, page: ()=>const LoginPage()),
    GetPage(name: Routes.loading, page: ()=>const Loading()),
    GetPage(name: Routes.addtask, page: ()=>const AddTaskPage()),
    GetPage(name: Routes.showmap, page: ()=>const GDMap()),
    GetPage(name: Routes.taskInfo, page: ()=>const TaskInfoPage()),
    GetPage(name: Routes.taskTalk, page: ()=>const TaskTalkPage(),binding: ChatBinding()),
    GetPage(name: Routes.taskMember, page: ()=>TaskMemberPage()),
  ];

}