import 'package:bangbang/page/control/chat_page_control.dart';
import 'package:get/get.dart';

class ChatBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatPageControl());
  }
  
}