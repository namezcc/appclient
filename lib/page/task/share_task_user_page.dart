import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/chat_user_data_control.dart';
import 'package:bangbang/page/control/chat_user_list_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShareTaskUserPage extends StatefulWidget {
  const ShareTaskUserPage({super.key});

  @override
  State<ShareTaskUserPage> createState() => _ShareTaskUserPageState();
}

class _ShareTaskUserPageState extends State<ShareTaskUserPage> {
  final colorscheme = Get.theme.colorScheme;
  final ChatUserListControl _chatUserListControl = Get.find<ChatUserListControl>();
  final JsonTaskInfo _taskInfo = Get.arguments["task"];
  final UserControl _userControl = Get.find<UserControl>();

  @override
  void initState() {
    super.initState();
    _chatUserListControl.initLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title:const Text("分享"),
        centerTitle: true,
      ),
      body: GetBuilder<ChatUserListControl>(
      builder: (_) {
        var userlist = ChatUserDataControl.instance.getChatList();
        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: userlist.length,
          itemBuilder: (context, index) {
            var chat = userlist[index];
            return InkWell(
                onTap: () {
                   ToolCompnent.bottomSheetDialog(const Text("分享"), "确定", "取消",onCancel: () {
                      Get.back();
                    },onConfirm: () {
                      var msg = ToolCompnent.buildTaskChatUser(_taskInfo,_userControl.userInfo);
                      var userinfo = JsonSimpleUserInfo(chat.keycid, chat.sendername, 0)..icon = chat.sendericon;
                      ChatUserDataControl.instance.sendChatMsg(msg, userinfo);

                      showToastMsg("已发送");
                      Get.back();
                    },);
                },
                child: Container(
                  padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  color: colorscheme.surface,
                  child: Row(
                    children: [
                      ToolCompnent.headIcon(chat.sendericon),
                      const SizedBox(width: 10,),
                      Text(chat.sendername),
                      // Expanded(child: Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text(chat.sendername),
                      //     Text(CommonUtil.getShortChatContent(chat.contentType, chat.content),overflow: TextOverflow.ellipsis,
                      //     style: TextStyle(fontSize: 12,color: colorscheme.tertiary),)
                      //   ],
                      // )),
                      // Text(CommonUtil.getTimeDiffString(chat.sendTime, DateTime.now()),style: TextStyle(fontSize: 12,color: colorscheme.tertiary))
                    ],
                  ),
                ),
              );
          },);
      }
    )
    );
  }
}