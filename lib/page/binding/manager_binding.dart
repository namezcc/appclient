
import 'package:bangbang/page/control/join_control.dart';
import 'package:bangbang/page/control/map_location_control.dart';
import 'package:get/get.dart';

class ManagerBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(JoinControl());
    Get.put(MapLocationControl());
  }
  
}