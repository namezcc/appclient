import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/setting/black_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  Widget settingTitle(String name,void Function() onTap) {
    return ToolCompnent.setTitle(Text(name),const Icon(Icons.keyboard_arrow_right_rounded,color: Colors.grey,),onTap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title:const Text("设置"),
        centerTitle: true,
      ),
      body: Container(
        margin:const EdgeInsets.all(10),
        child: ListView(
          children: [
            Container(
              padding:const EdgeInsets.only(left: 10,right: 5,top: 10,bottom: 10),
              decoration:const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white
              ),
              child: Column(
                children: [
                  settingTitle("黑名单", () { 
                    Get.to(()=>const BlackPage());
                  })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  
}