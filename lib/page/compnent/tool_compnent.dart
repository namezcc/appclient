

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

void showSnackBarMsg(String msg) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      content: Center(child: Text(msg)),
      // margin: const EdgeInsets.symmetric(
      //   horizontal: 100.0, // Inner padding for SnackBar content.
      //   vertical: 100.0
      // ),
      duration: const Duration(milliseconds: 1500),
      padding: const EdgeInsets.symmetric(
        horizontal: 1.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
      shape:const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
    ),
  );
}

void showToastMsg(String msg) {
  if (!GlobalData.runApp) {
    logInfo(msg);
    return;
  }
  var colorScheme = Get.theme.colorScheme;
  showToast(msg,
    duration:const Duration(seconds: 2),
    position: ToastPosition.center,
    backgroundColor: colorScheme.onSurface,
    radius: 3,
    textStyle: TextStyle(color: colorScheme.surface)
  );
}

Widget getLoadStateString(LoadState state) {
  switch (state) {
    case LoadState.none:
      return const Text("上拉加载");
    case LoadState.loading:
      return const CupertinoActivityIndicator();
    case LoadState.noMore:
      return const Text("没有更多数据");
    case LoadState.error:
      return const Text("出错啦");
  }
}

Widget getChatLoadStateString(LoadState state) {
  switch (state) {
    case LoadState.none:
      return const Text("加载");
    case LoadState.loading:
      return const CupertinoActivityIndicator();
    case LoadState.noMore:
      return const Text("到顶了");
    case LoadState.error:
      return const Text("出错啦");
  }
}

String getDistanceAddress(JsonAddressInfo ad1,JsonAddressInfo ad2) {
    var res = AMapTools.distanceBetween(LatLng(ad1.latitude, ad1.longitude), 
      LatLng(ad2.latitude, ad2.longitude)
    );
    if (res >= 1000) {
      return "${(res/1000).toStringAsFixed(1)}km";
    }
    return "${res.toInt().toString()}m";
  }

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  double offsetX;    // X方向的偏移量
  double offsetY;    // Y方向的偏移量
  CustomFloatingActionButtonLocation(this.location, this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}

Widget backButton() {
  var colorScheme = Get.theme.colorScheme;
  return IconButton(
    onPressed: (){
      Get.back();
    },
  icon: Icon(Icons.arrow_back_ios_new,color: colorScheme.primary));
}

class ToolCompnent {
  
}