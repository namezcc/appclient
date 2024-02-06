
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/net/net_pack.dart';
import 'package:bangbang/page/control/chat_page_control.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/tcp_control.dart';
import 'package:bangbang/util/db_util.dart';

class ChatLoadIndex {
  ChatLoadIndex(this.taskid,this.lastIndex,this.newIndex);

  String taskid;
  int lastIndex;
  int newIndex;
}

class ChatDataControl {
  ChatDataControl._();
  static final ChatDataControl _instance = ChatDataControl._();
  static ChatDataControl get instance => _instance;

  static int chatLoadPerNum = 20;

  final Map<String,JsonTaskChatInfo> taskchat = {};
  final Map<String,int> taskchatIndex = {};
  final List<ChatLoadIndex> taskChatLoadList = [];
  final Map<String,int> taskchatRead = {};

  ChatPageControl? chatPageControl;
  HomeControl? _homeControl;

  void clear() {
    taskchat.clear();
    taskchatIndex.clear();
    taskChatLoadList.clear();
    taskchatRead.clear();
  }

  /// 从数据库加载聊天记录, < startIndex
  Future<int> loadChatFromDb(String taskid,int startIndex) async {
    var res = await DbUtil.instance.loadChat(taskid, startIndex, chatLoadPerNum);
    if (res != null) {
      var chat = getTaskChat(taskid)!;
      chat.data.addAll(res);
      return res.length;
    }
    return 0;
  }

  Future<void> updateTaskChat(JsonTaskChatInfo chat) async {
    if (chat.data.length > 1) {
      chat.data = chat.data.reversed.toList();
    }
    var local = getTaskChat(chat.id);
    if (local == null) {
      local = JsonTaskChatInfo(chat.id, []);
      taskchat[chat.id] = local;
    }
    local.index = chat.index;
    if (chat.data.isEmpty) {
      local.state = LoadState.noMore;
      return;
    }
    if (chat.count < 0) {
      // 往前加载的
      local.data.addAll(chat.data);
      if (local.getLastIndex() == 0) {
        local.state = LoadState.noMore;
      }else{
        local.state = LoadState.none;
        await checkLoadMore(local);
      }
    }else{
      // 新的聊天
      local.data.insertAll(0, chat.data);
      // 刷新
      _homeControl?.refreshTaskChatState(chat.id);
    }
    await chatPageControl?.onUpdateChat(local);
    // 存入数据库
    for (var e in chat.data) {
      await DbUtil.instance.insertChat(chat.id, e);
    }
    if (chat.count < 0) {
      loadTaskChat();
    }
  }

  Future<void> checkLoadMore(JsonTaskChatInfo chat) async {
    if (chat.data.length >= chatLoadPerNum) {
      return;
    }
    await loadMoreChat(chat,chatLoadPerNum - chat.data.length);
  }

  Future<void> loadMoreChat(JsonTaskChatInfo chat,int loadnum) async {
    chat.state = LoadState.loading;
    // 先看数据库最近一条index
    var lastIndex = chat.getLastIndex();
    var dbLastIndex = await DbUtil.instance.getChatLessIndex(chat.id, lastIndex);
    if (dbLastIndex == lastIndex - 1) {
      // 从db取
      var n = await loadChatFromDb(chat.id, lastIndex);
      loadnum -= n;
    }
    if (chat.getLastIndex() == 0) {
      // 已经没了
      chat.state = LoadState.noMore;
      return;
    }
    if (loadnum > 0) {
      // 还需要从网络获取
      lastIndex = chat.getLastIndex();
      loadTaskChatFromNet(chat.id, lastIndex - loadnum, lastIndex);
    }else{
      chat.state = LoadState.none;
    }
  }

  void setChatPageControl(ChatPageControl? c) {
    chatPageControl = c;
  }

  void setHomeControl(HomeControl? c) {
    _homeControl = c;
  }

  JsonTaskChatInfo? getTaskChat(String id) {
    return taskchat[id];
  }

  // 获取最后一条聊天的index
  int getTaskLastIndex(String id) {
    var tc = getTaskChat(id);
    if (tc == null) {
      return -1;
    }
    if (tc.data.isEmpty) {
      return -1;
    }
    return tc.data[0].index;
  }

  void setTaskChatIndex(String id,int index) {
    if (index <= 0) {
      return;
    }
    var chat = getTaskChat(id);
    if (chat != null) {
      if (chat.index != index) {
        chat.index = index;
        chat.state = LoadState.none;
        chat.data.clear();
        taskchatIndex[id] = index;
      }
    }else{
      chat = JsonTaskChatInfo(id, []);
      chat.index = index;
      taskchat[id] = chat;
      taskchatIndex[id] = index;
    }
  }

  void checkLoadTaskChat() async {
    for (var e in taskchatIndex.entries) {
      // 从db获取最近的一条index
      var lastIndex = await DbUtil.instance.getChatLessIndex(e.key, e.value);
      lastIndex++;
      var chat = getTaskChat(e.key)!;
      if (lastIndex == e.value) {
        if (chat.data.isEmpty) {
          // 从db加载
          var dbn = await loadChatFromDb(e.key, e.value);
          if (dbn < chatLoadPerNum) {
            // 继续从网络加载
            var endIndex = chat.getLastIndex();
            if (endIndex > 0) {
              lastIndex = endIndex - (chatLoadPerNum - dbn);
              taskChatLoadList.add(ChatLoadIndex(e.key, lastIndex, endIndex));
              chat.state = LoadState.loading;
            }else{
              chat.state = LoadState.noMore;
            }
          }
        }
      }else{
        taskChatLoadList.add(ChatLoadIndex(e.key, lastIndex, e.value));
        chat.state = LoadState.loading;
      }
    }
    loadTaskChat();
  }

  void loadTaskChat() {
    if (taskChatLoadList.isEmpty) {
      return;
    }

    var info = taskChatLoadList.removeLast();
    var lastIndex = info.newIndex - chatLoadPerNum;
    if (info.lastIndex > lastIndex) {
      lastIndex = info.lastIndex;
    }

    loadTaskChatFromNet(info.taskid,lastIndex,info.newIndex);
  }

  //startIndex < endIndex
  void loadTaskChatFromNet(String taskid,int startIndex,int endIndex) {
    var chat = getTaskChat(taskid);
    if (chat == null) {
      return;
    }
    if (startIndex < 0) {
      startIndex = 0;
    }
    var num = endIndex - startIndex;
    var p = NetPack.newPack();
    p.writeString(taskid);
    p.writeInt32(startIndex - chat.index);
    p.writeInt32(num);
    TcpControl.instance.sendNetPack(NetCMMsgId.loadTaskChat, p);
  }

  void setTaskChatRead(String id,int index) {
    taskchatRead[id] = index;
  }

  bool isTaskChatRead(String id) {
    var rindex = taskchatRead[id];
    if (rindex == null) {
      return false;
    }
    var chat = getTaskChat(id);
    if (chat == null) {
      return false;
    }
    return chat.index >= rindex;
  }

  bool haveNewRead(String id) {
    var chat = getTaskChat(id);
    if (chat == null || chat.index <= 0) {
      return false;
    }
    var index = taskchatRead[id]??0;
    if (index >= chat.index) {
      return false;
    }
    return true;
  }

  void readTaskChat(String id) {
    var chat = getTaskChat(id);
    if (chat == null || chat.index <= 0) {
      return;
    }
    var index = taskchatRead[id]??0;
    if (index >= chat.index) {
      return;
    }

    taskchatRead[id] = chat.index;

    var p = NetPack.newPack();
    p.writeString(id);
    p.writeInt32(chat.index);
    TcpControl.instance.sendNetPack(NetCMMsgId.chatRead, p);
  }

  JsonChatInfo? getNewChat(String id) {
    var chat = getTaskChat(id);
    if (chat != null && chat.data.isNotEmpty) {
      return chat.data.first;
    }
    return null;
  }
}