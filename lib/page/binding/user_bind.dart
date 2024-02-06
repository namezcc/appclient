import 'package:bangbang/page/control/user_control.dart';
import 'package:get/get.dart';

class UserBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserControl());
  }
  
}