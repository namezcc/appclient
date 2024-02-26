import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/editinfo/edit_name_page.dart';
import 'package:bangbang/page/editinfo/edit_sex_page.dart';
import 'package:bangbang/page/editinfo/head_crop_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final colorscheme = Get.theme.colorScheme;
  final _userControl = Get.find<UserControl>();

  void pickHeadIcon() async {
    try {
      List<AssetEntity>? assets = await AssetPicker.pickAssets(Get.context!,pickerConfig:const AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.image,
      ));
      if (assets == null) {
        return;
      }
      var imgdata = await assets.first.originBytes;
      if (imgdata != null) {
        Get.to(()=> HeadCropPage(image: imgdata,entity: assets.first,));
      }else{
        showToastMsg("操作失败,请重试");
      }
    } catch (e) {
      logError(e.toString());
      showToastMsg("没有权限,请开启权限");
    }
  }

  Widget editButton(String name,String val,Function() onTap,{bool dev = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:const EdgeInsets.only(top: 5,left: 10,right: 10),
        color: colorscheme.surface,
        child: Column(
          children: [
            Row(
              children: [
                Text(name),
                const Expanded(child: SizedBox()),
                Text(val),
                const Icon(Icons.chevron_right,color: Colors.grey,)
              ],
            ),
            const SizedBox(height: 5,),
            dev ? const Divider(indent: 5,endIndent: 5,height: 0,thickness: 0.5,):const SizedBox()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserControl>(
        id: "userinfo",
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
                leading: backButton(),
                title:const Text("编辑资料"),
                centerTitle: true,
              ),
            body: ListView(
              children:[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      InkWell(
                        onTap: () {
                          pickHeadIcon();
                        },
                        child: ToolCompnent.headIcon(_.userInfo.icon,radius: 30)),
                      const Icon(Icons.camera_alt_rounded,color: Colors.white,)
                    ])),
                ),
                editButton("名字",_userControl.userInfo.name,(){
                  Get.to(()=> EditNamePage(value: _userControl.userInfo.name));
                }),
                editButton("性别",_userControl.userInfo.sex == sexMan ? "男":"女",(){
                  Get.to(()=>EditSexPage(sex: _userControl.userInfo.sex,));
                },dev: false),
            ],
          ),
      );}
    );
  }
}