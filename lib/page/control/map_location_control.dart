import 'dart:async';
import 'dart:convert';

import 'package:bangbang/common/loger.dart';
import 'package:bangbang/common/map.dart';
import 'package:bangbang/common/storage.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:get/get.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';

typedef OnLocation = Function(bool);

class MapLocationControl extends GetxController {
  late StreamSubscription<Map<String, Object>> _locationListener;
  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
  JsonAddressInfo? myLocation;
  OnLocation? _onGetLocation;

  @override
  void onInit() {
    super.onInit();
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);

    _locationListener = _locationPlugin.onLocationChanged().listen((event) { 
      logError(event.toString());
      myLocation = JsonAddressInfo(
        event["address"] as String,
        "", 
        event["city"] as String,
        "", 
        event["address"] as String,""
      );

      var longitude = (event["longitude"] as num).toDouble();
      var latitude = (event["latitude"] as num).toDouble();

      //测试
      longitude = 120.12;
      latitude = 30.16;

      myLocation?.longitude = longitude;
      myLocation?.latitude = latitude;
      myLocation?.location = "$longitude,$latitude";

      _stopLocation();

      // 本地存储
      var jsonmap = myLocation!.toJson();
      var str = jsonEncode(jsonmap);
      MyStorage.saveString("location",str );

      if (_onGetLocation != null) {
        _onGetLocation!(true);
      }
    },
    onError: (Object _){
      _stopLocation();
      if (_onGetLocation != null) {
        _onGetLocation!(false);
      }
    }
    );
  }  

  @override
  void onClose() {
    super.onClose();
    _locationListener.cancel();
    _locationPlugin.destroy();
  }

  void startLoaction(OnLocation? onLocation) {
    _onGetLocation = onLocation;
    _locationPlugin.setLocationOption(MapConfig.genLocationOptionn());
    

    _locationPlugin.startLocation();
  }

  void _stopLocation() {
    _locationPlugin.stopLocation();
  }

  Future<void> loadLocation() async {
    var res = await MyStorage.getString("location");
    if (res.isEmpty) {
      return;
    }
    try {
      var map = jsonDecode(res);
      if (map != null) {
        myLocation = JsonAddressInfo.fromJson(map);
      }
    } catch (e) {
      logError(e.toString());
    }
  }
}