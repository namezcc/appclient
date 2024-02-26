import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/control/chat_user_list_control.dart';
import 'package:bangbang/page/control/chat_user_page_control.dart';
import 'package:bangbang/page/control/tcp_control.dart';
import 'package:bangbang/util/db_util.dart';

class ChatUserDataControl {
  ChatUserDataControl._();
  static final ChatUserDataControl _instance = ChatUserDataControl._();
  static ChatUserDataControl get instance => _instance;

  final Map<int,JsonChatUser> chatUserList = {};
  ChatUserPageControl? _chatUserPageControl;
  ChatUserListControl? _chatUserListControl;
  LoadState _loadState = LoadState.none;
  int chatid = CommonUtil.getNowMillSecond();

  // 别人给我发的
  void onGetChatUser(List<JsonChatUser> chatlist) {
    if (chatlist.length > 1) {
      chatlist.sort((a, b) {
        var c = a.cid.compareTo(b.cid);
        if (c == 0) {
          return b.chatid.compareTo(a.chatid);
        }
        return c;
      },);
    }

    var lastcid = 0;
    var lowid = chatlist.first.chatid;
    var heiid = 0;
    for (var chat in chatlist) {
      chat.keycid = chat.cid;
      // 存入数据库
      DbUtil.instance.saveChatUser(chat,toList: chat.cid != lastcid);
      if (chat.cid != lastcid) {
        chatUserList[chat.keycid] = chat;
        lastcid = chat.cid;
      }
      if (chat.chatid < lowid) {
        lowid = chat.chatid;
      }
      if (chat.chatid > heiid) {
        heiid = chat.chatid;
      }
      _chatUserPageControl?.onGetNetChat(chat);
      if (_chatUserPageControl == null) {
        _chatUserListControl?.update();
      }
    }
    TcpControl.instance.sendGetUserChat(lowid, heiid);
  }

  // 发给别人消息成功发送
  void onChatUserSended(int cid,int mycid,int oldid,int newid) {
    DbUtil.instance.setChatUserSended(cid,mycid, oldid, newid);
  }

  void setChatUserPageControl(ChatUserPageControl? c) {
    _chatUserPageControl = c;
  }

  void setChatUserListControl(ChatUserListControl? c) {
    _chatUserListControl = c;
  }

  Future<bool> loadChatUserList() async {
    if (_loadState == LoadState.noMore) {
      return false;
    }
    var skip = chatUserList.length;
    var res = await DbUtil.instance.loadChatUserList(skip);

    for (var e in res) {
      chatUserList[e.keycid] = e;
    }
    if (res.length < 20) {
      _loadState = LoadState.noMore;
    }
    return res.isNotEmpty;
  }

  List<JsonChatUser> getChatList() {
    List<JsonChatUser> res = [];

    chatUserList.forEach((key, value) {
      res.add(value);
    });

    res.sort((a, b) {
      return a.sendTime - b.sendTime;
    },);
    return res;
  }

  void selfChatToList(JsonChatUser c) {
    chatUserList[c.keycid] = c;
  }

  void deleteChatUser(int cid) async {
    chatUserList.remove(cid);
    await DbUtil.instance.deleteChatUserList(cid);
  }

  void sendChatMsg(JsonChatUser chat,JsonSimpleUserInfo touser) {
    chatid++;
    chat.tocid = touser.cid;
    chat.chatid = chatid;
    chat.keycid = touser.cid;
    TcpControl.instance.sendJsonData(NetCMMsgId.chatUser, chat.toJson());
    // 插入数据库
    DbUtil.instance.saveSelfChatUser(chat,touser);
    // 插入chat list
    selfChatToList(chat);
    _chatUserPageControl?.update();
  }

}