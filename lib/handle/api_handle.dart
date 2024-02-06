
import 'package:bangbang/common/global_data.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/common/map.dart';
import 'package:bangbang/common/storage.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:dio/dio.dart';

final dio = Dio();

void initDio() {
  dio.options.baseUrl = GlobalData.hostBase;
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 300);

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response != null) {
          logError("status:${error.response?.statusCode} error:${error.toString()}");
          handler.resolve(error.response!);
          // if (GlobalData.runApp) {
          //   showSnackBarMsg("状态码错误:${error.response?.statusCode}");
          // }
        }else{
          showToastMsg("请检查网络");
          handler.next(error);
        }
      },
    )
  );
}

Future<HttpData?> apiGetPhoneCode(String phoneNum) async {
  if (phoneNum == "") {
    return HttpData.fromJson({"code":1,"msg":"手机号非法"});
  }
  // 检查号码格式
  final url = "${GlobalData.hostBase}/phoneCode?phoneNumber=$phoneNum";
  try {
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return HttpData.fromJson(response.data);
    }else{
      return HttpData.fromJson({"code":1,"msg":"${response.statusCode}"});
    }
  } catch (e) {
    logError(e.toString());
    return HttpData.fromJson({"code":1,"msg":"网络错误"});
  }
}

Future<HttpDataString?> apiUserLogin(String phoneNum,String code) async {
  if (phoneNum == "" || code == "") {
    return HttpDataString.fromJson({"code":1,"msg":"输入错误"});
  }

  final url = "${GlobalData.hostBase}/userlogin";
  try {
    final res = await dio.post(url,data: {
      "phone":phoneNum,
      "code":code,
    });
    if (res.statusCode == 200) {
      var rd = HttpDataString.fromJson(res.data);
      GlobalData.setJwtToken(rd.data);
      dio.options.headers = {"Authorization":rd.data};
      MyStorage.saveString(MyStorage.loginToken, rd.data);
      var timesec = DateTime.now().millisecondsSinceEpoch;
      MyStorage.saveInt(MyStorage.loginTokenTime, timesec);
      return rd;
    }else{
      return HttpDataString.fromJson({"code":1,"msg":"${res.statusCode}"});
    }
  } catch (e) {
    logError(e.toString());
    return HttpDataString.fromJson({"code":1,"msg":"网络错误"});
  }
}

Future<void> apiUserRefreshToken(String token) async {
  final url = "${GlobalData.hostBase}/userRefreshToken";
  try {
    final res = await dio.get(url,options: Options(headers: {
      "Authorization":token
    }));
    if (res.statusCode == 200) {
      var rd = HttpDataString.fromJson(res.data);
      GlobalData.setJwtToken(rd.data);
      dio.options.headers = {"Authorization":rd.data};
      MyStorage.saveString(MyStorage.loginToken, rd.data);
      var timesec = DateTime.now().millisecondsSinceEpoch;
      MyStorage.saveInt(MyStorage.loginTokenTime, timesec);
    }
  } catch (e) {
    logError(e.toString());
  }
}

Future<HttpDataUserInfo?> apiGetUserInfo() async {
  final url = "${GlobalData.hostBase}/getUserInfo";
  try {
    final res = await dio.get(url);
    if (res.statusCode == 200) {
      return HttpDataUserInfo.fromJson(res.data);
    }else{
      return null;
    }
  } catch (e) {
    logError(e.toString());
    return null;
  }
}

Future<JsonHttpTaskResult?> apiGetTaskInfo(TaskConfig config) async {
  try {
    final url = "${GlobalData.hostBase}/apiGetTaskInfo";
    final res = await dio.post(url,data: config.toJson());
    if (res.statusCode == 200) {
      return JsonHttpTaskResult.fromJson(res.data);
    }else{
      return null;
    }
  } catch (e) {
    logError(e.toString());
    return null;
  }
}

Future<JsonMapSearch?> apiGetMapLocation(Map<String, dynamic> param) async {
  try {
    final res = await Dio().get(MapConfig.geotolocationurl,queryParameters: param);
    if (res.statusCode == 200) {
      var regeo = res.data["regeocode"] as Map<String,dynamic>;
      var pois = regeo["pois"] as List<dynamic>?;
      if (pois != null && pois.isNotEmpty) {
        for (var e in pois) {
          var em = e as Map<String,dynamic>;
          if (em["address"] is List) {
            em["address"] = em["name"];
          }
        }
      }else{
        return null;
      }
      res.data["pois"] = pois;
      var jsdata = JsonMapSearch.fromJson(res.data);
      var comp = regeo["addressComponent"] as Map<String,dynamic>;
      var ctname = comp["city"] as String? ?? (comp["province"] as String);
      var name = regeo["formatted_address"] as String;
      var main = JsonAddressInfo(name, "", ctname, "", name, param["location"] as String);

      for (var element in jsdata.pois) {element.cityname = ctname;}

      jsdata.pois.insert(0, main);	  
      //   logInfo(res.data.toString());
      return jsdata;
    }else{
      logError("${res.statusMessage}");
    }
  } catch (e) {
    logError(e.toString());
  }
  return null;
}

Future<JsonMapSearch?> apiSearchMapLoaction(Map<String, dynamic> param) async {
  try {
    final res = await Dio().get(MapConfig.mapSearchUrl,queryParameters: param);
    if (res.statusCode == 200) {
    //   logInfo(res.data.toString());
	  return JsonMapSearch.fromJson(res.data);
    }else{
      logError("${res.statusMessage}");
	  return null;
    }
  } catch (e) {
    logError(e.toString());
	return null;
  }
}

Future<JsonTaskInfo?> apiUploadTask(JsonTaskInfo task) async {
  try {
    final url = "${GlobalData.hostBase}/apiCreateTask";
    final res = await dio.post(url,data: task.toJson());
    if (res.statusCode == 200) {
      return HttpJsonTaskInfo.fromJson(res.data).data;
    }
  } catch (e) {
    logError(e.toString());
  }
	return null;
}

Future<JsonTaskInfo?> apiUpdateTask(JsonTaskInfo task) async {
  try {
    final url = "${GlobalData.hostBase}/apiUpdateTask";
    final res = await dio.post(url,data: task.toJson());
    if (res.statusCode == 200) {
      return HttpJsonTaskInfo.fromJson(res.data).data;
    }
  } catch (e) {
    logError(e.toString());
  }
	return null;
}

Future<HttpUploadImageInfo?> apiUploadTaskImage(Map<String, dynamic> param) async {
  try {
    final url = "${GlobalData.hostBase}/uploadTaskImage";
    final res = await dio.post(url,data: FormData.fromMap(param));
    if (res.statusCode == 200) {
      return HttpUploadImageInfo.fromJson(res.data);
    }
  } catch (e) {
    logError(e.toString());
  }
  return null;
}

Future<String?> apiUploadOssImage(Map<String, dynamic> param) async {
  try {
    final url = "${GlobalData.hostBase}/apiUploadOssImage";
    final res = await Dio().post(url,data: FormData.fromMap(param));
    if (res.statusCode == 200) {
      return HttpDataString.fromJson(res.data).data;
    }
  } catch (e) {
    logError(e.toString());
  }
  return null;
}

Future<List<JsonTaskInfo>?> apiLoadMyTaskList(int skip) async {
  try {
    final url = "${GlobalData.hostBase}/apiLoadMyTaskInfo";
    final res = await dio.get(url,queryParameters: {"skip":skip});
    if (res.statusCode == 200) {
      var jsdata = HttpJsonTaskInfoList.fromJson(res.data);
      if (jsdata.data == null && jsdata.code == 0) {
        return [];
      }
	    return jsdata.data;
    }else{
      logError("${res.statusMessage}");
    }
  } catch (e) {
    logError(e.toString());
  }
  return null;
}

Future<bool> apiDeleteTask(String taskid) async {
  try {
    final url = "${GlobalData.hostBase}/apiDeleteMyTaskInfo";
    final res = await dio.get(url,queryParameters: {"taskid":taskid});
    if (res.statusCode == 200) {
      var httpdata = HttpData.fromJson(res.data);
	    return httpdata.code == 0;
    }else{
      logError("${res.statusMessage}");
    }
  } catch (e) {
    logError(e.toString());
  }
  return false;
}

Future<List<JsonTaskInfo>?> apiLoadJoinTaskList(int skip) async {
  try {
    final url = "${GlobalData.hostBase}/apiLoadMyJoinTaskInfo";
    final res = await dio.get(url,queryParameters: {"skip":skip});
    if (res.statusCode == 200) {
      var jsdata = HttpJsonTaskInfoList.fromJson(res.data);
      if (jsdata.data == null && jsdata.code == 0) {
        return [];
      }
	    return jsdata.data;
    }else{
      logError("${res.statusMessage}");
    }
  } catch (e) {
    logError(e.toString());
  }
  return null;
}

Future<TaskNumChange?> apiJoinTask(String id) async {
  try {
    final url = "${GlobalData.hostBase}/apiJoinTask";
    final res = await dio.get(url,queryParameters: {"taskid":id});
    if (res.statusCode == 200) {
      var jsdata = HttpTaskNumChange.fromJson(res.data);
	    return jsdata.data;
    }else{
      logError("${res.statusMessage}");
    }
  } catch (e) {
    logError(e.toString());
  }
  return null;
}

Future<TaskNumChange?> apiQuitTask(String id) async {
  try {
    final url = "${GlobalData.hostBase}/apiQuitTask";
    final res = await dio.get(url,queryParameters: {"taskid":id});
    if (res.statusCode == 200) {
      var jsdata = HttpTaskNumChange.fromJson(res.data);
	    return jsdata.data;
    }else{
      logError("${res.statusMessage}");
    }
  } catch (e) {
    logError(e.toString());
  }
  return null;
}

Future<TaskNumChange?> apiKickTask(String id,int cid) async {
  try {
    final url = "${GlobalData.hostBase}/apiKickTask";
    final res = await dio.get(url,queryParameters: {"taskid":id,"kickcid":cid});
    if (res.statusCode == 200) {
      var jsdata = HttpTaskNumChange.fromJson(res.data);
	    return jsdata.data;
    }else{
      logError("${res.statusMessage}");
    }
  } catch (e) {
    logError(e.toString());
  }
  return null;
}

Future<TaskFinishChange?> apiFinishTask(Map<String, dynamic> param) async {
  try {
    final url = "${GlobalData.hostBase}/apiFinishTask";
    final res = await dio.post(url,data: param);
    if (res.statusCode == 200) {
      var jsmap = res.data["data"];
      if (jsmap != null) {
        return TaskFinishChange.fromJson(jsmap);
      }
    }
  } catch (e) {
    logError(e.toString());
  }
	return null;
}

Future<JsonTaskInfo?> apiUpdateOneTask(String id) async {
  try {
    final url = "${GlobalData.hostBase}/apiGetOneTaskInfo";
    final res = await dio.get(url,queryParameters: {"taskid":id});
    if (res.statusCode == 200) {
      return HttpJsonTaskInfo.fromJson(res.data).data;
    }
  } catch (e) {
    logError(e.toString());
  }
	return null;
}

Future<TaskFinishChange?> apiGetTaskReward(String id) async {
  try {
    final url = "${GlobalData.hostBase}/apiGetTaskReward";
    final res = await dio.get(url,queryParameters: {"taskid":id});
    if (res.statusCode == 200) {
      var jsmap = res.data["data"];
      if (jsmap != null) {
        return TaskFinishChange.fromJson(jsmap);
      }
    }
  } catch (e) {
    logError(e.toString());
  }
	return null;
}

Future<TaskFinishChange?> apiPayTaskCost(String id) async {
  try {
    final url = "${GlobalData.hostBase}/apiPayTaskCost";
    final res = await dio.get(url,queryParameters: {"taskid":id});
    if (res.statusCode == 200) {
      var jsmap = res.data["data"];
      if (jsmap != null) {
        return TaskFinishChange.fromJson(jsmap);
      }
    }
  } catch (e) {
    logError(e.toString());
  }
	return null;
}

Future<TaskFinishChange?> apiGetTaskCost(String id) async {
  try {
    final url = "${GlobalData.hostBase}/apiGetTaskCost";
    final res = await dio.get(url,queryParameters: {"taskid":id});
    if (res.statusCode == 200) {
      var jsmap = res.data["data"];
      if (jsmap != null) {
        return TaskFinishChange.fromJson(jsmap);
      }
    }
  } catch (e) {
    logError(e.toString());
  }
	return null;
}

Future<void> apiDeleteUserJoin(String id) async {
  try {
    final url = "${GlobalData.hostBase}/apiDeleteUserJoin";
    await dio.get(url,queryParameters: {"taskid":id});
    // if (res.statusCode == 200) {
    //   var jsmap = res.data["data"];
    //   if (jsmap != null) {
    //     return TaskFinishChange.fromJson(jsmap);
    //   }
    // }
  } catch (e) {
    logError(e.toString());
  }
	// return null;
}

Future<bool> apiEditName(String name) async {
  try {
    final url = "${GlobalData.hostBase}/apiEditName";
    var res = await dio.get(url,queryParameters: {"name":name});
    if (res.statusCode == 200) {
      return HttpData.fromJson(res.data).code == 0;
    }
  } catch (e) {
    logError(e.toString());
  }
	return false;
}

Future<bool> apiEditSex(int sex) async {
  try {
    final url = "${GlobalData.hostBase}/apiEditSex";
    var res = await dio.get(url,queryParameters: {"sex":sex});
    if (res.statusCode == 200) {
      return HttpData.fromJson(res.data).code == 0;
    }
  } catch (e) {
    logError(e.toString());
  }
	return false;
}