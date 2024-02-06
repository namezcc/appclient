
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/chat_data_control.dart';
import 'package:bangbang/page/control/tcp_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/util/db_util.dart';
import 'package:get/get.dart';

class ChatPageControl extends GetxController {
  JsonTaskChatInfo emptyChat = JsonTaskChatInfo("", [])..state=LoadState.noMore;
  JsonTaskChatInfo chatInfo = JsonTaskChatInfo("", []);
  List<JsonChatInfo> showChatInfo = [];
  int cid = Get.find<UserControl>().userInfo.cid;
  final List<IntPair> finishTask = [];

  void initTaskChat(String id) {
    var info = ChatDataControl.instance.getTaskChat(id);
    chatInfo = info ?? emptyChat;
    chatInfo.id = id;
    showChatInfo.clear();
    showChatInfo.addAll(chatInfo.data);

    // 设置已读
    ChatDataControl.instance.readTaskChat(id);
  }

  void sendChatMsg(String taskid,JsonChatInfo chat) {
    chat.index = -1;
    showChatInfo.insert(0, chat);
    var tc = JsonTaskChatInfo(taskid,[chat]);
    TcpControl.instance.sendJsonData(NetCMMsgId.taskChat, tc.toJson());
  }

  void _updateChat(JsonTaskChatInfo chat) {
    int lastChatIndex = -1;
    int cashnum = 0;
    int selfchatNum = 0;
    for (var i = 0; i < showChatInfo.length; i++) {
      if (showChatInfo[i].index >= 0 ) {
        lastChatIndex = showChatInfo[i].index;
        break;
      }else{
        cashnum++;
      }
    }

    for (var i = 0; i < chat.data.length; i++) {
      if (chat.data[i].index == lastChatIndex) {
        break;
      }
      if (chat.data[i].cid == cid) {
        selfchatNum++;
      }
    }
    if (selfchatNum > 0) {
      showChatInfo.replaceRange(cashnum-selfchatNum, cashnum, chat.data.sublist(0,selfchatNum));
    }
    // 加载的更新
    int lastIndex = 0;
    int starti = 0;
    if (showChatInfo.isNotEmpty) {
      lastIndex = showChatInfo.last.index;
    }
    if (chat.data.last.index != lastIndex) {
      for (var i = chat.data.length - 1; i >= 0; i--) {
        if (chat.data[i].index != lastIndex) {
          starti = i;
        }else{
          break;
        }
      }
      showChatInfo.addAll(chat.data.sublist(starti));
    }
  }

  Future<void> onUpdateChat(JsonTaskChatInfo chat) async {
    if (chatInfo.id != chat.id) {
      return;
    }

    _updateChat(chat);

    chatInfo = chat;
    update();
  }

  Future<void> loadMoreChat() async {
    if (chatInfo.state == LoadState.noMore || chatInfo.state == LoadState.loading) {
      return;
    }
    chatInfo.state = LoadState.loading;
    logInfo("loadmore chat");
    await ChatDataControl.instance.loadMoreChat(chatInfo,ChatDataControl.chatLoadPerNum);
    await onUpdateChat(chatInfo);
  }

  void testDeleteChat() async {
    var n = await DbUtil.instance.deleteChat(chatInfo.id, 0, 10);
    logInfo("delete chat $n");
  }

  bool isAllCheck() {
    bool res = true;
    for (var e in finishTask) {
      if (e.value2 == 0) {
        res = false;
        break;
      }
    }
    return res;
  }

  List<JsonSimpleUserInfo> getFinishTaskUser(JsonTaskInfo taskInfo) {
    List<JsonSimpleUserInfo> user = [];
    finishTask.clear();
    for (var i = 0; i < taskInfo.join.data.length; i++) {
      var e = taskInfo.join.data[i];
      if (e.cid != taskInfo.cid) {
        user.add(e);
        var state = e.state == FinishState.none.index ? 1 : -1;
        finishTask.add(IntPair(i,state));
      }
    }
    return user;
  }

  void setFinishTaskChoose(bool? v) {
    for (var e in finishTask) {
      if (e.value2 >= 0) {
        e.value2 = v == true ? 1:0;
      }
    }
    update(["finishTask"]);
  }

  void finishTaskChoose(int index) {
    var old = finishTask[index].value2;
    finishTask[index].value2 = old == 0 ? 1: 0;
    update(["finishTask"]);
  }

  int getFinishChooseNum() {
    int num = 0;
    for (var e in finishTask) {
      if (e.value2 > 0) {
        num++;
      }
    }
    return num;
  }

  Future<void> sendFinishTask(JsonTaskInfo t) async {
    List<int> pos = [];
    List<int> cids = [];
    for (var e in finishTask) {
      if (e.value2 > 0) {
        pos.add(e.value1);
        var join = t.join.data[e.value1];
        cids.add(join.cid);
      }
    }
    if (cids.isEmpty) {
      showToastMsg("未选择");
      return;
    }

    var jsdata = <String,dynamic>{
      "id":t.id,
      "pos":pos,
      "cid":cids
    };
    var res = await apiFinishTask(jsdata);
    if (res == null) {
      showToastMsg("操作失败");
    }else{
      if (res.join != null) {
        t.join = res.join!;
        t.state = 1;
      }
      Get.find<UserControl>().userInfo.money = res.money;     
    }
  }
}