import 'dart:async';
import 'dart:convert';

import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/net/net_pack.dart';
import 'package:bangbang/net/tcp_conn.dart';
import 'package:bangbang/page/control/chat_data_control.dart';

typedef OnHandleNetMsg = Function(NetPack);

void parseJson(NetPack p,Function(dynamic) f) {
  var json = p.readBufferString();
  //解析json
  try {
    var jmap = jsonDecode(json);
    f(jmap);
  } catch (e) {
    logError(e.toString());
  }
}

class TcpControl {
  TcpControl._(){
    initHandle();
    // initTimer();
  }

  static final TcpControl _instance = TcpControl._();
  static TcpControl get instance => _instance;
  static int maxPongOutTime = 30;

  TcpConn? conn;
  final List<OnHandleNetMsg?> _handle = List<OnHandleNetMsg?>.generate(NetSmMsgId.end.index, (index) => null);
  int pongOutTime = 0;

  void initHandle() {
    _handle[NetSmMsgId.pong.index] = onNetPing;
    _handle[NetSmMsgId.errCode.index] = _onNetError;
    _handle[NetSmMsgId.chatUpdate.index] = _onChatUpdate;
    _handle[NetSmMsgId.chatIndex.index] = _onChatIndex;
    _handle[NetSmMsgId.chatRead.index] = _onChatRead;
    
  }

  void initTimer() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (DateTime.now().millisecondsSinceEpoch~/1000 > pongOutTime) {
        conn?.reconnect();
      }
    });
  }

  void connectServer() {
    conn?.close();
    conn = TcpConn("192.168.0.77", 10001, onReadNetPack, () {
      pongOutTime = DateTime.now().millisecondsSinceEpoch~/1000 + maxPongOutTime;
      sendLoginData();
    });
    conn?.connect();
  }

  void onReadNetPack(int pid,NetPack p) {
    if(pid < 0 || pid >= _handle.length){
      return;
    }

    var handle = _handle[pid];
    if (handle != null) {
      handle(p);
    }
  }

  void sendNetPack(NetCMMsgId id,NetPack p) {
    conn?.sendNetPack(getIndex(id), p);
  }

  void sendJsonData(NetCMMsgId id,Map<String,dynamic> d) {
    var str = jsonEncode(d);
    var p = NetPack.newPack();
    p.writeBuffer(str);
    sendNetPack(id, p);
  }

  void sendLoginData() {
    var p = NetPack.newPack();
    p.writeBuffer(GlobalData.jwtToken);
    conn?.sendNetPack(getIndex(NetCMMsgId.login), p);
    sendPing();
  }

  int getIndex(NetCMMsgId id) {
    return id.index + 3000;
  }

  void sendPing() {
    Future.delayed(const Duration(seconds: 10),() {
      var p = NetPack.newPack();
      conn?.sendNetPack(getIndex(NetCMMsgId.ping), p);
    },);
  }

  void onNetPing(NetPack p) {
    sendPing();
    pongOutTime = DateTime.now().millisecondsSinceEpoch~/1000 + maxPongOutTime;
  }

  void _onNetError(NetPack p) {
  }

  void _onChatUpdate(NetPack p) {
    var json = p.readBufferString();
    //解析json
    try {
      var jmap = jsonDecode(json);
      var chat = JsonTaskChatInfo.fromJson(jmap);
      ChatDataControl.instance.updateTaskChat(chat);
    } catch (e) {
      logError(e.toString());
    }
  }

  void _onChatIndex(NetPack p) {
    parseJson(p,(jd) async {
      var d = jd as List<dynamic>;
      var control = ChatDataControl.instance;
      for (var e in d) {
        var chat = JsonTaskChatInfo.fromJson(e);
        control.setTaskChatIndex(chat.id, chat.index);
      }
      control.checkLoadTaskChat();
    },);
  }

  void _onChatRead(NetPack p) {
    parseJson(p,(jd) async {
      var d = jd as List<dynamic>;
      var control = ChatDataControl.instance;
      for (var e in d) {
        var read = JsonTaskChatRead.fromJson(e);
        control.setTaskChatRead(read.taskid, read.index);
      }
    });
  }
}