import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/message/chat_user_page.dart';
import 'package:bangbang/page/report/report_user_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtherUserPage extends StatefulWidget {
  const OtherUserPage({super.key});

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  final colorscheme = Get.theme.colorScheme;
  final _userControl = Get.find<UserControl>();
  final _cid = Get.arguments["cid"];
  final bool _userchat = Get.arguments["userchat"];

  late JsonUserInfo _user;

  Widget buildOptButton() {
    List<Widget> child = [
      ToolCompnent.buildGridIconChild("举报",const Icon(Icons.report_problem_rounded),() {
              Get.back();
              Get.to(()=> const ReportUserPage(),arguments: {"cid":_cid});
      },)
    ];

    if (_cid != _userControl.userInfo.cid) {
      if (_userControl.isInBlackList(_cid)) {
        child.add(ToolCompnent.buildGridIconChild("取消拉黑",const Icon(Icons.block_flipped),() {
          Get.back();
          ToolCompnent.iosDialog('将“${_user.name}”解除拉黑',null, "确定", "取消",onCancel: () {
            Get.back();
          },onConfirm: () {
            _userControl.removeBlackList(_cid);
            Get.back();
          },);
        },));
      }else{
        child.add(ToolCompnent.buildGridIconChild("拉黑",const Icon(Icons.block_flipped),() {
          Get.back();
          ToolCompnent.iosDialog('将“${_user.name}”拉黑','对方将无法加入你的任务,对方不会收到拉黑通知.', "拉黑", "取消",onCancel: () {
            Get.back();
          },onConfirm: () {
            _userControl.pushBlackList(_cid);
            Get.back();
          },);
        },));
      }
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius:const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
        color: colorscheme.background,
      ),
      child: Container(
        margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: apiGetUserInfo(cid:_cid), builder: (context, snapshot) {
      if (snapshot.data == null) {
        return Scaffold(
          appBar: AppBar(leading: backButton(),),
          body:const Center(child: Text("加载中...")),
        );
      }
      var user = snapshot.data!.data;
      _user = user;
      return Scaffold(
        appBar: AppBar(
          leading: backButton(),
          actions: [
            IconButton(onPressed: () {
              Get.bottomSheet(buildOptButton());
            }, icon: Icon(Icons.more_horiz,color: colorscheme.primary,))
          ],
        ),
        body: Column(
          children: [
            Container(
              margin:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: Row(
                children: [
                  ToolCompnent.headIcon(_user.icon,radius: 30),
                  const SizedBox(width: 10,),
                  Text(user.name)
                ],
              ),
            ),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                OutlinedButton(
                  onPressed: _userControl.isInBlackList(_user.cid) ? null : () {
                  if (_userchat) {
                    Get.back();
                    return;
                  }
                  var userinfo = JsonSimpleUserInfo(_user.cid, _user.name, _user.sex);
                  Get.to(()=>const ChatUserPage(),arguments: {"user":userinfo});
                }, child:const Text("私聊"),)
              ],
            ),
            const SizedBox(height: 200,),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                  color: colorscheme.surface
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("发布任务"),
                    Expanded(
                      child: ListView(
                        
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    },);
  }
}