
import 'dart:convert';

import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/define/table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbUtil {
  DbUtil._();
  static final DbUtil _instance = DbUtil._();
  static DbUtil get instance => _instance;

  Database? _db;

  Database get db => _db!;
  int _cid=0;
  Set<String> taskSave = {};

  Future<void> initDb(int cid) async {
    if (_cid == cid) {
      return;
    }
    _cid = cid;
    var basepath = await getDatabasesPath();
    var path = join(basepath,"bang_$cid.db");
    _db = await openDatabase(path,version: 2,onCreate: _onCreate,onOpen: _onOpen);
  }

  String _drop(String tab) {
    return "DROP TABLE IF EXISTS $tab";
  }

  void _onCreate(Database db, int newVersion) async{
    logInfo("db create ");
    var batch = db.batch();
    batch.execute(_drop(TableUtil.tabChat));
    batch.execute(TableUtil.createChat);
    await batch.commit();
  }

  void _onOpen(Database db) async {
    await db.execute(TableUtil.createReadHistory);
    deleteReadTask(db);
  }

  Future<void> insertChat(String taskid,JsonChatInfo c) async {
    var amap = c.toJson();
    amap["taskid"] = taskid;
    await db.insert(TableUtil.tabChat, amap,conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  ///获取 headIndex = lastIndex - n ~ lastIndex
  Future<List<JsonChatInfo>?> loadChat(String taskid,int lastIndex,int n) async {
    var res = await db.rawQuery('SELECT * FROM ${TableUtil.tabChat} WHERE taskid=? AND "index">=${lastIndex - n} AND "index"<$lastIndex ORDER BY "index" DESC',[taskid]);
    if (res.isEmpty) {
      return null;
    }

    List<JsonChatInfo> vec = [];
    for (var e in res) {
      vec.add(JsonChatInfo.fromJson(e));
    }
    return vec;
  }
  /// 获取 < index 最近的一条记录
  Future<int> getChatLessIndex(String taskid,int index) async {
    var res = await db.rawQuery('SELECT * FROM ${TableUtil.tabChat} WHERE taskid=? AND "index"<$index ORDER BY "index" DESC LIMIT 1',[taskid]);
    if (res.isEmpty) {
      return 0;
    }
    return JsonChatInfo.fromJson(res[0]).index;
  }

  ///delete [start,endi]
  Future<int> deleteChat(String taskid,int starti,int endi) async {
    int n = await db.rawDelete('DELETE FROM ${TableUtil.tabChat} WHERE taskid=? AND "index">=$starti AND "index"<=$endi',[taskid]);
    return n;
  }

  Future<void> saveReadTask(JsonTaskInfo t) async {
    if (taskSave.contains(t.id)) {
      return;
    }
    var taskstr = jsonEncode(t.toJson());
    await db.insert(TableUtil.tabReadhistory, {"taskid":t.id,"updateTime":CommonUtil.getNowSecond(),"task":taskstr},conflictAlgorithm: ConflictAlgorithm.replace);
    taskSave.add(t.id);
  }

  // 删除100条之前的记录
  Future<void> deleteReadTask(Database db) async {
    await db.rawDelete("DELETE FROM ${TableUtil.tabReadhistory} WHERE updateTime NOT IN (SELECT updateTime FROM ${TableUtil.tabReadhistory} ORDER BY updateTime DESC LIMIT 100);");
  }

  Future<List<JsonTaskInfo>> loadReadTask(int offset) async {
    List<JsonTaskInfo> data = [];
    var res = await db.rawQuery("SELECT * FROM ${TableUtil.tabReadhistory} ORDER BY updateTime DESC LIMIT 20 OFFSET ?;",[offset]);
    if (res.isNotEmpty) {
      for (var e in res) {
        var jmap = jsonDecode(e["task"] as String);
        data.add(JsonTaskInfo.fromJson(jmap));
      }
    }
    return data;
  }
}