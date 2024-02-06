import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/routes/app_page.dart';

class TaskUtil {
  static String getNumString(JsonTaskInfo task) {
    var str = "";
    var num = getJoinNum(task);
    var mann = num[sexMan];
    var woman = num[sexWoman];
    if (task.manNum < 0) {
      // 不分性别
      str = "人数 ${mann+woman}/${task.peopleNum}";
    }else{
      if (task.manNum == 0) {
        str = "限女生 $woman/${task.peopleNum}";
      }else if(task.manNum == task.peopleNum){
        str = "限男生 $mann/${task.peopleNum}";
      }else {
        var wn = task.peopleNum-task.manNum;
        str = "男 $mann/${task.manNum} 女 $woman/$wn";
      }
    }
    return str;
  }

  static String getImageUrlByName(String s) {
    return "${GlobalData.hostBase}/static/$s";
  }

  static List<String> getImageUrls(JsonTaskInfo task) {
    List<String> urls = [];
    final images = task.images;
    if (images != null) {
      for (var i = 0; i < images.length; i++) {
        urls.add("${GlobalData.hostBase}/static/${images[i]}");
      }
    }
    return urls;
  }

  static String getMoneyString(JsonTaskInfo task) {
    if (task.moneyType == taskMoneyTypeReward) {
      return "赏金 ￥${task.money}";
    }else{
      return "费用 男￥${task.money} 女￥${task.womanMoney}";
    }
  }

  static bool inJoin(JsonTaskInfo t,int cid) {
    var idx = t.join.data.indexWhere((element) => element.cid == cid);
    return idx >= 0;
  }

  static JsonTaskInfo empttTask = JsonTaskInfo(0, "", "", "", 0, 0, 0, 0, 0, 0);

  static String getTaskToPage(JsonTaskInfo t,int cid) {
    if (t.cid == cid || inJoin(t, cid)) {
      return Routes.taskTalk;
    }else{
      return Routes.taskInfo;
    }
  }

  static List<int> getJoinNum(JsonTaskInfo t) {
    var res = [0,0];
    for (var e in t.join.data) {
      res[e.sex]++;
    }
      return res;
  }

  static bool canJoin(JsonTaskInfo t,int sex) {
    if (t.manNum < 0) {
      var num = t.join.data.length;
      return (t.peopleNum - num) > 0;
    }else{
      var num = getJoinNum(t)[sex];
      if (sex == sexWoman) {
        return (t.peopleNum - t.manNum - num) > 0;
      }else{
        return (t.manNum - num) > 0;
      }
    }
  }

  static JsonSimpleUserInfo? getJoinByCid(int cid,JsonTaskInfo t) {
    for (var e in t.join.data) {
      if (e.cid == cid) {
        return e;
      }
    }
    return null;
  }

  static int gethaveMoneyTotal(JsonTaskInfo t) {
    var num = 0;
    for (var e in t.join.data) {
      if (e.state == FinishState.haveMoney.index) {
        num += e.money;
      }
    }
    return num;
  }

  static bool haveReward(JsonTaskInfo t,int cid) {
    var cangetmoney = false;
    if (t.cid == cid) {
      if (t.moneyType == taskMoneyTypeCost && gethaveMoneyTotal(t) > 0) {
        cangetmoney = true;
      }
    }else {
      if (t.moneyType == taskMoneyTypeReward) {
        var join = getJoinByCid(cid, t);
        if (join != null && join.state == FinishState.haveMoney.index) {
          cangetmoney = true;
        }
      }
    }
    return cangetmoney;
  }

  static bool checkTaskDown(JsonTaskInfo t,int cid) {
    var join = getJoinByCid(cid, t);
    if (t.moneyType == taskMoneyTypeReward) {
      if (t.cid == cid) {
        return t.state > 0;
      }else{
        return join?.state != FinishState.none.index;
      }
    }else{
      if (t.cid == cid) {
        for (var e in t.join.data) {
          if (e.state == FinishState.none.index) {
            return false;
          }
        }
        return true;
      }else{
        return join == null || join.state != FinishState.none.index;
      }
    }
  }

}