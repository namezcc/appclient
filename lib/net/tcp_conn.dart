
import 'dart:io';
import 'dart:typed_data';

import 'package:bangbang/common/loger.dart';
import 'package:bangbang/net/net_pack.dart';

typedef OnReadNetPack = Function(int pid,NetPack p);
typedef OnConnected = Function();

class TcpConn {
  TcpConn(this.host,this.port,this.onReadNetPack,this.onConnected,[
    this._reconnectInterval = 10,
  ]);

  String host;
  int port;
  OnReadNetPack onReadNetPack;
  OnConnected onConnected;

  Socket? _socket;
  final List<int> _readData = [];
  bool _closeBySelf = false;
  final int _reconnectInterval;
  bool _inReconnect = false;

  
  void connect() async {
    try {
      var socket = await Socket.connect(host, port,timeout:const Duration(seconds: 5));
      _socket = socket;
      _readData.clear();
      _socket?.listen(onReciveMsg,onError: (err){
        logError("conn on err", err: err);
        reconnect();
      },onDone: () {
        logError("tcp conn down");
        reconnect();
      },);
      onConnected();
    } catch (e) {
      logError("conn catch err ${e.toString()}");
      reconnect();
    }
  }

  void onReciveMsg(Uint8List data) {
    _readData.addAll(data);
    var offset = 0;
    while (_readData.length - offset >= NetPack.headSize) {
      var bdata = ByteData.sublistView(Uint8List.fromList(_readData.sublist(offset,offset+NetPack.headSize)));
      var packlen = bdata.getInt32(0,Endian.little);
      if (packlen > _readData.length - offset) {
        break;
      }
      var pid = bdata.getInt32(4,Endian.little);
      if (packlen > 655350) {
        logError("get pack size error $packlen pid:$pid");
        break;
      }

      List<int> sublist;
      if (packlen-NetPack.headSize > 0) {
        sublist = _readData.sublist(offset+NetPack.headSize,offset + packlen);
      }else{
        sublist = [];
      }
      onReadNetPack(pid,NetPack.fromPack(sublist));
      offset += packlen;
    }

    if (offset > 0) {
      _readData.removeRange(0, offset);
    }
  }

  void close() {
    if (_socket != null) {
      _socket?.close();
      _socket = null;
    }
    _closeBySelf = true;
  }

  void reconnect() async {
    if (_closeBySelf == true) {
      logInfo("reconnect fail");
      return;
    }
    if (_inReconnect) {
      return;
    }

    _socket?.close();
    _socket = null;
    _inReconnect = true;
    Future.delayed(Duration(seconds: _reconnectInterval),() {
      _inReconnect = false;
      if (_closeBySelf == false) {
        connect();
      }
    },);
  }

  void sendNetPack(int pid,NetPack p) {
    if (_socket == null) {
      logError("socket closed");
      return;
    }
    _socket!.add(p.decode(pid));
  }
}