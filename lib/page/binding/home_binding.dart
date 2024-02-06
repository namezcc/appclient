import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/message_control.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeControl());
    Get.lazyPut(() => MessageControl());
    
  }
  
}