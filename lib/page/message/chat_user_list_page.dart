import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/chat_user_data_control.dart';
import 'package:bangbang/page/control/chat_user_list_control.dart';
import 'package:bangbang/page/message/chat_user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';

class ChatUserListPage extends StatefulWidget {
  const ChatUserListPage({super.key});

  @override
  State<ChatUserListPage> createState() => _ChatUserListPageState();
}

class _ChatUserListPageState extends State<ChatUserListPage> {
  final colorscheme = Get.theme.colorScheme;
  final ChatUserListControl _chatUserListControl = Get.find<ChatUserListControl>();

  @override
  void initState() {
    super.initState();

    ChatUserDataControl.instance.setChatUserListControl(_chatUserListControl);
    _chatUserListControl.initLoad();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // });
  }

  @override
  void dispose() {
    ChatUserDataControl.instance.setChatUserListControl(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatUserListControl>(
      builder: (_) {
        var userlist = ChatUserDataControl.instance.getChatList();
        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: userlist.length,
          itemBuilder: (context, index) {
            var chat = userlist[index];
            return SwipeActionCell(
              key: ValueKey(index),
              trailingActions: [
                SwipeAction(
                  color: Colors.red,
                  title: "删除",
                  onTap: (handler) {
                      ToolCompnent.bottomSheetDialog(
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("删除后聊天记录也会清除",style: TextStyle(fontSize: 10,color: colorscheme.tertiary),),
                        ),"确认删除","取消",
                      onConfirm: () {
                        _chatUserListControl.deleteChatUser(chat.keycid);
                        Get.back();
                      },onCancel: () {
                        Get.back();
                      },);
                },)
              ],
              child: InkWell(
                onTap: () {
                  var userinfo = JsonSimpleUserInfo(chat.keycid, chat.sendername, 0)..icon = chat.sendericon;
                  Get.to(()=>const ChatUserPage(),arguments:{"user":userinfo})?.then((value) {
                    setState(() {
                    });
                  });
                },
                child: Container(
                  padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  color: colorscheme.surface,
                  child: Row(
                    children: [
                      ToolCompnent.headIcon(chat.sendericon),
                      const SizedBox(width: 10,),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chat.sendername),
                          Text(CommonUtil.getShortChatContent(chat.contentType, chat.content),overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12,color: colorscheme.tertiary),)
                        ],
                      )),
                      Text(CommonUtil.getTimeDiffString(chat.sendTime, DateTime.now()),style: TextStyle(fontSize: 12,color: colorscheme.tertiary))
                    ],
                  ),
                ),
              ),
            );
          },);
      }
    );
  }
}