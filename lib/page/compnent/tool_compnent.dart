
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/common/image_cache_manager.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/other_user_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  static void showWaiting() {
    if (Get.isDialogOpen == true) {
      return;
    }
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            height: 50,
            width: 50,
            decoration:const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              // color: Color.fromARGB(100, 255, 255, 255)
            ),
            child:const CupertinoActivityIndicator(),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void closeWaiting() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  static Widget buildGridIconChild(String name,Widget child,Function()? onTap) {
    return Container(
        margin:const EdgeInsets.only(right: 10),
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: Column(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:  BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: child
                ),
                const SizedBox(height: 10,),
                Align(
                  child: Text(name, style:const TextStyle(color: Colors.black54, fontSize: 13),),
                ),
              ],
            ),
          ),
    );
  }

  static Widget toUserPage(Widget child,int cid,{bool userchat=false,void Function()? backFunc}) {
    return GestureDetector(
            onTap: () {
              Get.to(()=> const OtherUserPage(),arguments: {"cid":cid,"userchat":userchat})?.then((value) {
                if (backFunc != null) {
                  backFunc();
                }
              });
            },
            child: child,
          );
  }

  static void iosDialog(String title,String? content,String textConfirm,String textCancel,{void Function()? onConfirm,void Function()? onCancel,bool barrierDismissible=false}) {
    showCupertinoDialog(context: Get.context!,barrierDismissible: barrierDismissible,builder: (context) {
    return CupertinoAlertDialog(
    title: Text(title),
    content: content ==null?null:Text(content),
    actions: <Widget>[
      CupertinoDialogAction(
        onPressed: onCancel,
        child: Text(textCancel,style:const TextStyle(color: Colors.blue),),
      ),
      CupertinoDialogAction(
        onPressed: onConfirm,
        child: Text(textConfirm),
      ),
    ],
  );
},);
  }

  static void bottomSheetDialog(Widget tip,String textConfirm,String textCancel,{void Function()? onConfirm,void Function()? onCancel,void Function(dynamic)? onBack}) {
    Get.bottomSheet(
      Container(
        height: 150,
        constraints:const BoxConstraints(
          minHeight: 100,
        ),
        decoration:const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            tip,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: onConfirm,
                child: Text(textConfirm,style:const TextStyle(color: Colors.red),),
              ),
            ),
            Container(height: 5,color: Colors.grey.shade200,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: onCancel,
                child: Text(textCancel),
              ),
            ),
            const Expanded(child: SizedBox())
          ],
        ),
      )
    ).then((value) {
      if (onBack != null) {
        onBack(value);
      }
    });
  }

  static Widget setTitle(Widget head,Widget tail,void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(children: [
        head,
        const Expanded(child: SizedBox()),
        tail,
      ],),
    );
  }

  static Widget headIcon(String icon,{double? radius}) {
    if (icon.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey,
        radius: radius,
        backgroundImage:const AssetImage("assets/image/icon/head_0_h.png"),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.grey,
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(
        icon,
        cacheManager: CustomCacheManager.instance,
      )
    );
  }

  static JsonChatInfo buildTaskChat(JsonTaskInfo t,JsonUserInfo user) {
    String content = "|task ${t.id}#${t.title}|";
    var now = DateTime.now().millisecondsSinceEpoch~/1000;
    var msg = JsonChatInfo(user.cid, user.name, user.icon, now, content, ChatContentType.task.index);
    return msg;
  }

  static JsonChatUser buildTaskChatUser(JsonTaskInfo t,JsonUserInfo user) {
    String content = "|task ${t.id}#${t.title}|";
    var now = DateTime.now().millisecondsSinceEpoch~/1000;
    var msg = JsonChatUser(user.cid, user.name, user.icon, now, content, ChatContentType.task.index);
    return msg;
  }
}