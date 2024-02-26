import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/control/chat_user_data_control.dart';
import 'package:bangbang/util/db_util.dart';
import 'package:get/get.dart';

class ChatUserPageControl extends GetxController {
  int chatid = CommonUtil.getNowMillSecond();
  List<JsonChatUser> showChatInfo = [];
  LoadState loadState = LoadState.none;
  int _cid = 0;

  Future<void> initChat(int cid) async {
    _cid = cid;
    await loadMoreChat(cid);
  }

  void sendChatMsg(JsonChatUser chat,JsonSimpleUserInfo touser) {
    ChatUserDataControl.instance.sendChatMsg(chat, touser);
    showChatInfo.insert(0, chat);
    update();
  }

  Future<void> loadMoreChat(int cid) async {
    if (loadState == LoadState.noMore) {
      return;
    }
    var res = await DbUtil.instance.loadChatUser(cid, 0);
    if (res.length < 20) {
      loadState = LoadState.noMore;
    }
    if (res.isNotEmpty) {
      showChatInfo.addAll(res);
      update();
    }
  }

  void onGetNetChat(JsonChatUser c) {
    if (_cid != c.cid) {
      return;
    }
    showChatInfo.insert(0, c);
    DbUtil.instance.setChatUserRead(_cid,c.chatid);
    update();
  }
}