
import 'dart:convert';

import 'package:bangbang/common/common_util.dart';
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
    // logInfo("db create ");
    var batch = db.batch();
    batch.execute(_drop(TableUtil.tabChat));
    batch.execute(TableUtil.createChat);
    batch.execute(TableUtil.createChatUser);
    batch.execute(TableUtil.createChatUserList);
    await batch.commit();
  }

  void _onOpen(Database db) async {
    var batch = db.batch();
    batch.execute(TableUtil.createReadHistory);
    // batch.execute(_drop(TableUtil.tabChatUser));
    batch.execute(TableUtil.createChatUser);
    // batch.execute(_drop(TableUtil.tabChatUserList));
    batch.execute(TableUtil.createChatUserList);
    batch.execute(TableUtil.createBlackList);
    batch.execute(TableUtil.createInterestTask);
    batch.execute(TableUtil.createUserState);

    await batch.commit();
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

  Future<int> deleteTaskChat(String taskid) async {
    int n = await db.rawDelete('DELETE FROM ${TableUtil.tabChat} WHERE taskid=?;',[taskid]);
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

  void saveChatUser(JsonChatUser c,{bool toList = false}) async {
    var val = {
      "keycid":c.cid,
      "cid":c.cid,
      "chatid":c.chatid,
      "sendername":c.sendername,
      "sendericon":c.sendericon,
      "send_time":c.sendTime,
      "content":c.content,
      "content_type":c.contentType,
    };
    await db.insert(TableUtil.tabChatUser, val,conflictAlgorithm: ConflictAlgorithm.replace);
    if (toList) {
      val["read_chat_id"] = 0;
      await db.insert(TableUtil.tabChatUserList, val,conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  void saveSelfChatUser(JsonChatUser c,JsonSimpleUserInfo touser) async {
    var val = {
      "keycid":c.keycid,
      "cid":c.cid,
      "chatid":c.chatid,
      "sendername":c.sendername,
      "sendericon":c.sendericon,
      "send_time":c.sendTime,
      "content":c.content,
      "content_type":c.contentType,
    };
    await db.insert(TableUtil.tabChatUser, val,conflictAlgorithm: ConflictAlgorithm.replace);

    // list
    val["read_chat_id"] = 1;
    val["sendername"] = touser.name;
    val["sendericon"] = touser.icon;
    await db.insert(TableUtil.tabChatUserList, val,conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void setChatUserRead(int cid,int readid) async {
    await db.update(TableUtil.tabChatUserList,{"read_chat_id":readid},where: "keycid = ?",whereArgs: [cid],conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void setChatUserSended(int keycid,int cid,int oldred,int newread) async {
    await db.update(TableUtil.tabChatUser,{"chatid":newread,"issend":1},where: "keycid = ? AND chatid = ? AND cid = ?",whereArgs: [keycid,oldred,cid],conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<JsonChatUser>> loadChatUser(int cid,int chatid) async {
    List<JsonChatUser> res = [];

    late List<Map<String, Object?>> qres;
    if (chatid > 0) {
      qres = await db.rawQuery("SELECT * FROM ${TableUtil.tabChatUser} WHERE keycid = ? AND chatid < ? ORDER BY chatid DESC LIMIT 20",[cid,chatid]);
    }else{
      qres = await db.rawQuery("SELECT * FROM ${TableUtil.tabChatUser} WHERE keycid = ? ORDER BY chatid DESC LIMIT 20",[cid]);
    }

    for (var e in qres) {
      res.add(JsonChatUser.fromJson(e));
    }
    return res;
  }

  Future<List<JsonChatUser>> loadChatUserList(int skip) async {
    List<JsonChatUser> res = [];
    var qres = await db.query(TableUtil.tabChatUserList,orderBy: "send_time DESC",limit: 20,offset: skip);

    for (var e in qres) {
      res.add(JsonChatUser.fromJson(e));
    }
    return res;
  }

  Future<void> deleteChatUserList(int keycid) async {
    db.delete(TableUtil.tabChatUserList,where: "keycid = ?",whereArgs: [keycid]);
    db.delete(TableUtil.tabChatUser,where: "keycid = ?",whereArgs: [keycid]);
  }

  Future<int> getUserState(int id) async {
    var res = await db.query(TableUtil.tabUserState,where: "id = ?",whereArgs: [id]);
    if (res.isNotEmpty) {
      return res.first["value"] as int;
    }
    return 0;
  }

  void setUserState(int id,int value) async {
    await db.insert(TableUtil.tabUserState, {"id":id,"value":value},conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<int>> loadBlackList() async {
    List<int> res = [];
    
    var qres = await db.query(TableUtil.tabBlackList);
    for (var e in qres) {
      res.add(e["cid"] as int);
    }
    return res;
  }

  void insertBlackList(int cid) async {
    await db.insert(TableUtil.tabBlackList, {"cid":cid},conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void deleteBlackList(int cid) async {
    await db.delete(TableUtil.tabBlackList,where: "cid = ?",whereArgs: [cid]);
  }

  Future<List<String>> loadInterestTask() async {
    List<String> res = [];
    
    var qres = await db.query(TableUtil.tabInterestTask);
    for (var e in qres) {
      res.add(e["taskid"] as String);
    }
    return res;
  }

  void insertInterestTask(String taskid) async {
    await db.insert(TableUtil.tabInterestTask, {"taskid":taskid},conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void deleteInterestTask(String taskid) async {
    await db.delete(TableUtil.tabInterestTask,where: "taskid = ?",whereArgs: [taskid]);
  }
}