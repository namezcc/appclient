import 'package:bangbang/define/define.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/editinfo/edit_name_page.dart';
import 'package:bangbang/page/editinfo/edit_sex_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditPage extends StatelessWidget {
  EditPage({super.key});

  final colorscheme = Get.theme.colorScheme;
  final _userControl = Get.find<UserControl>();

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
                const Icon(Icons.chevron_right)
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
    return Scaffold(
      appBar: AppBar(
          leading: backButton(),
          title:const Text("编辑资料"),
          centerTitle: true,
        ),
      body: GetBuilder<UserControl>(
        id: "userinfo",
        builder: (_) {
          return ListView(
            children: [
              Container(
                padding:const EdgeInsets.symmetric(vertical: 10),
                child: CircleAvatar(backgroundColor: colorscheme.secondary,)
              ),
              editButton("名字",_userControl.userInfo.name,(){
                Get.to(()=> EditNamePage(value: _userControl.userInfo.name));
              }),
              editButton("性别",_userControl.userInfo.sex == sexMan ? "男":"女",(){
                Get.to(()=>EditSexPage(sex: _userControl.userInfo.sex,));
              }),
              // editButton("生日","选择生日",(){
              //   Get.to(()=> EditBirthPage(birth: _userControl.userInfo.birth));
              // },dev: false),
            ],
          );
        }
      ),
    );
  }
  
}