import 'dart:convert';
import 'dart:typed_data';

import 'package:bangbang/common/loger.dart';
import 'package:flutter/foundation.dart';

class NetPack {
  static const int headSize = 8;

  NetPack(this._pack);

  late final List<int> _pack;
  late ByteData _reader;
  int offset = 0;

  static NetPack fromPack(List<int> p) {
    var pack = NetPack(p);
    pack._reader = ByteData.view(Uint8List.fromList(p).buffer);
    return pack;
  }

  static NetPack newPack() {
    var p = NetPack(List<int>.from(Uint8List(headSize)));
    return p;
  }

  int readInt32() {
    if (offset + 4 > _pack.length) {
      logError("read int32 pack len overflow");
      return 0;
    }
    var v = _reader.getInt32(offset,Endian.little);
    offset+=4;
    return v;
  }

  int readInt64() {
    if (offset + 8 > _pack.length) {
      logError("read int64 pack len overflow");
      return 0;
    }
    var v = _reader.getInt64(offset,Endian.little);
    offset += 8;
    return v;
  }

  String readString() {
    var len = readInt32();
    if (len == 0) {
      return "";
    }
    if (offset + len > _pack.length) {
      logError("read string pack len overflow");
      return "";
    }
    var strlist = _pack.sublist(offset,offset + len);
    offset += len;
    return utf8.decode(strlist);
  }

  String readBufferString() {
    var strlist = _pack.sublist(offset);
    offset = _pack.length;
    return utf8.decode(strlist);
  }

  Uint8List decode(int pid) {
    var packlen = _pack.length;
    var p = Uint8List.fromList(_pack);
    _reader = ByteData.view(p.buffer);
    _reader.setInt32(0, packlen,Endian.little);
    _reader.setInt32(4, pid,Endian.little);
    return p;
  }

  void writeInt32(int v) {
    var l = Uint8List(4);
    var b = ByteData.view(l.buffer);
    b.setInt32(0, v,Endian.little);
    _pack.addAll(l);
  }

  void writeInt64(int v) {
    var l = Uint8List(8);
    var b = ByteData.view(l.buffer);
    b.setInt64(0, v,Endian.little);
    _pack.addAll(l);
  }

  void writeString(String v) {
    writeInt32(v.length);
    var l = utf8.encode(v);
    _pack.addAll(l);
  }

  void writeBuffer(String v) {
    var l = utf8.encode(v);
    _pack.addAll(l);
  }
}