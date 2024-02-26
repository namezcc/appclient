import 'dart:typed_data';

import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class HeadCropPage extends StatelessWidget {
  HeadCropPage({
    super.key,
    required this.image,
    required this.entity,
  });

  final Uint8List image;
  final AssetEntity entity;
  final _controller = CropController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Crop(
              controller: _controller,
              // withCircleUi: true,
              interactive: true,
              initialSize:0.8,
              // initialRectBuilder: (viewportRect, imageRect) {
              //   return const Rect.fromLTRB(200,200,200,200);
              //   // return Rect.fromLTRB(
              //   //   viewportRect.left + 24,
              //   //   viewportRect.top,// + 50,
              //   //   viewportRect.right - 24,
              //   //   viewportRect.bottom,// - 50,
              //   // );
              // },
              fixCropRect:true,
              cornerDotBuilder: (size, edgeAlignment) => const SizedBox(),
              image: image, onCropped: (value) async {
                var img = await CommonUtil.multipartFileFromByteData(entity,value);
                if (img != null) {
                  Map<String,dynamic> data = {
                    "file":img
                  };
                  String? url = await apiUploadOssImage(data);
                  if (url != null && url.isNotEmpty) {
                    url = TaskUtil.getImageUrlByName(url);
                    var res = await apiSetUserIcon(url);
                    if (res) {
                      showToastMsg("头像设置成功");
                      Get.find<UserControl>().updateIcon(url);
                    }else{
                      showToastMsg("图片上传失败");
                    }
                  }else{
                    showToastMsg("图片上传失败");
                  }
                }else{
                  showToastMsg("上传失败");
                }
                Get.back();
            },),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                TextButton(onPressed: () {
                  Get.back();
                }, child:const Text("取消")),
                const Expanded(child: SizedBox()),
                FilledButton(onPressed: () {
                  _controller.crop();
                  // _controller.cropCircle();
                }, child:const Text("确定")),
              ],
            ),
          )
        ],
      ),
    );
  }
  
}