import 'package:bangbang/define/define.dart';
import 'package:json_annotation/json_annotation.dart';

part 'json_class.g.dart';

@JsonSerializable()
class HttpData {
  
  HttpData(this.code,this.msg);

  int code;
  @JsonKey(defaultValue: "")
  String msg;

  factory HttpData.fromJson(Map<String,dynamic> json) => _$HttpDataFromJson(json);
  Map<String,dynamic> toJson() => _$HttpDataToJson(this);

}

@JsonSerializable()
class HttpDataString extends HttpData {
  
  HttpDataString(this.data) : super(0, '');

  @JsonKey(defaultValue: "")
  String data;

  factory HttpDataString.fromJson(Map<String,dynamic> json) => _$HttpDataStringFromJson(json);
  @override
  Map<String,dynamic> toJson() => _$HttpDataStringToJson(this);

}

@JsonSerializable()
class JsonUserInfo {

  @JsonKey(name: 'cid')
  int cid;

  @JsonKey(name: 'phone')
  String phone;

  @JsonKey(name: 'name')
  String name;

  int sex;
  String icon = "";
  String birth = "";
  int money = 0;

  JsonUserInfo(this.cid,this.phone,this.name,this.sex);

  factory JsonUserInfo.fromJson(Map<String, dynamic> srcJson) => _$JsonUserInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonUserInfoToJson(this);

}


@JsonSerializable()
class HttpDataUserInfo extends HttpData {
  
  JsonUserInfo data;

  HttpDataUserInfo(this.data) : super(0, '');


  factory HttpDataUserInfo.fromJson(Map<String,dynamic> json) => _$HttpDataUserInfoFromJson(json);
  @override
  Map<String,dynamic> toJson() => _$HttpDataUserInfoToJson(this);

}

@JsonSerializable()
class JsonHttpTaskResult extends HttpData {

  @JsonKey(name: 'data')
  JsonTaskResult data;

  JsonHttpTaskResult(this.data) : super(0, '');

  factory JsonHttpTaskResult.fromJson(Map<String, dynamic> srcJson) => _$JsonHttpTaskResultFromJson(srcJson);

  @override
  Map<String, dynamic> toJson() => _$JsonHttpTaskResultToJson(this);

}

  
@JsonSerializable()
class JsonTaskResult {

  @JsonKey(name: 'config')
  TaskConfig config;

  @JsonKey(name: 'data')
  List<JsonTaskInfo> data;

  JsonTaskResult(this.config,this.data,);

  factory JsonTaskResult.fromJson(Map<String, dynamic> srcJson) => _$JsonTaskResultFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonTaskResultToJson(this);

}

  
@JsonSerializable()
  class TaskConfig {

  @JsonKey(name: 'globel_limit')
  int globelLimit;

  @JsonKey(name: 'longitude')
  double longitude;

  @JsonKey(name: 'latitude')
  double latitude;

  @JsonKey(name: 'min_distance')
  int minDistance;

  @JsonKey(name: 'loc_limit')
  int locLimit;

  @JsonKey(name: 'globelMax')
  int globelMax;

  @JsonKey(name: 'locMax')
  int locMax;

  TaskConfig(this.globelLimit,this.longitude,this.latitude,this.minDistance,this.locLimit,this.globelMax,this.locMax,);

  factory TaskConfig.fromJson(Map<String, dynamic> srcJson) => _$TaskConfigFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TaskConfigToJson(this);

}

@JsonSerializable()
class JsonMapSearch {

  @JsonKey(name: 'infocode')
  String infocode;

  @JsonKey(name: 'pois',defaultValue: [])
  List<JsonAddressInfo> pois;

  @JsonKey(name: 'status')
  String status;

  @JsonKey(name: 'info')
  String info;

  JsonMapSearch(this.infocode,this.pois,this.status,this.info,);

  factory JsonMapSearch.fromJson(Map<String, dynamic> srcJson) => _$JsonMapSearchFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonMapSearchToJson(this);

}

  
@JsonSerializable()
class JsonAddressInfo {

  @JsonKey(name: 'address')
  String address;

  @JsonKey(name: 'pname',defaultValue: "")
  String pname;

  @JsonKey(name: 'cityname',defaultValue: "")
  String cityname;

  @JsonKey(name: 'adname',defaultValue: "")
  String adname;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'location')
  String location;

  @JsonKey(defaultValue: 0)
  double longitude = 0;
  @JsonKey(defaultValue: 0)
  double latitude = 0;

  void parseLocation() {
    var list = location.split(",");
    longitude = double.parse(list[0]);
    latitude = double.parse(list[1]);
  }

  JsonAddressInfo(this.address,this.pname,this.cityname,this.adname,this.name,this.location,);

  factory JsonAddressInfo.fromJson(Map<String, dynamic> srcJson) => _$JsonAddressInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonAddressInfoToJson(this);

}


@JsonSerializable()
class JsonTaskInfo {

  @JsonKey(name: 'id')
  String id = "";

  @JsonKey(name: 'createAt')
  String? createAt;

  @JsonKey(name: 'updateAt')
  String? updateAt;

  @JsonKey(name: 'cid')
  int cid;

  @JsonKey(name: 'creator_name')
  String creatorName;

  @JsonKey(name: 'creator_icon')
  String? creatorIcon;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'images')
  List<String>? images;

  @JsonKey(name: 'money_type')
  int moneyType;

  @JsonKey(name: 'money')
  int money;

  @JsonKey(name: 'womanMoney')
  int womanMoney;

  @JsonKey(name: 'people_num')
  int peopleNum;

  @JsonKey(name: 'man_num')
  int manNum;

  @JsonKey(name: 'end_time',defaultValue: 0)
  int endTime;

  @JsonKey(defaultValue: 0)
  int delete = 0;

  JsonAddressInfo? address;

  @JsonKey(fromJson: _taskJoin)
  JsonTaskJoin join = JsonTaskJoin();

  static JsonTaskJoin _taskJoin(Map<String, dynamic>? json) {
    if (json != null) {
      return JsonTaskJoin.fromJson(json);
    }else{
      return JsonTaskJoin();
    }
  }

  @JsonKey(defaultValue: 0)
  int state = 0;

  void copyFrom(JsonTaskInfo nj) {
    id = nj.id;
    createAt = nj.createAt;
    updateAt = nj.updateAt;
    cid = nj.cid;
    creatorName = nj.creatorName;
    creatorIcon = nj.creatorIcon;
    title = nj.title;
    content = nj.content;
    images = nj.images;
    moneyType = nj.moneyType;
    money = nj.money;
    womanMoney = nj.womanMoney;
    peopleNum = nj.peopleNum;
    manNum = nj.manNum;
    endTime = nj.endTime;
    delete = nj.delete;
    address = nj.address;
    join = nj.join;
    state = nj.state;
  }

  JsonTaskInfo(this.cid,this.creatorName,this.title,this.content,this.moneyType,this.money,this.womanMoney,this.peopleNum,this.manNum,this.endTime,);

  factory JsonTaskInfo.fromJson(Map<String, dynamic> srcJson) => _$JsonTaskInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonTaskInfoToJson(this);

}

@JsonSerializable()
class HttpJsonTaskInfo extends HttpData {
  HttpJsonTaskInfo(super.code, super.msg);

  JsonTaskInfo? data;

  factory HttpJsonTaskInfo.fromJson(Map<String,dynamic> json) => _$HttpJsonTaskInfoFromJson(json);
  @override
  Map<String,dynamic> toJson() => _$HttpJsonTaskInfoToJson(this); 
}

@JsonSerializable()
class HttpJsonTaskInfoList extends HttpData {
  HttpJsonTaskInfoList(super.code, super.msg);

  List<JsonTaskInfo>? data;

  factory HttpJsonTaskInfoList.fromJson(Map<String,dynamic> json) => _$HttpJsonTaskInfoListFromJson(json);
  @override
  Map<String,dynamic> toJson() => _$HttpJsonTaskInfoListToJson(this); 
}

@JsonSerializable()
class HttpUploadImageInfo extends HttpData {
  HttpUploadImageInfo(super.code, super.msg);

  List<List<String>>? data;

  factory HttpUploadImageInfo.fromJson(Map<String,dynamic> json) => _$HttpUploadImageInfoFromJson(json);
  @override
  Map<String,dynamic> toJson() => _$HttpUploadImageInfoToJson(this); 
}

@JsonSerializable()
class JsonSimpleUserInfo {
  @JsonKey(name: 'cid')
  int cid;

  @JsonKey(name: 'name')
  String name;

  int sex;
  String icon = "";
  int state = 0;
  int money = 0;

  JsonSimpleUserInfo(this.cid,this.name,this.sex);

  factory JsonSimpleUserInfo.fromJson(Map<String, dynamic> srcJson) => _$JsonSimpleUserInfoFromJson(srcJson);
  Map<String, dynamic> toJson() => _$JsonSimpleUserInfoToJson(this);
}

@JsonSerializable()
class JsonTaskJoin {
  @JsonKey(name: 'data',defaultValue: [])
  List<JsonSimpleUserInfo> data = [];

  JsonTaskJoin();

  factory JsonTaskJoin.fromJson(Map<String, dynamic> srcJson) => _$JsonTaskJoinFromJson(srcJson);
  Map<String, dynamic> toJson() => _$JsonTaskJoinToJson(this);
}

@JsonSerializable()
class TaskNumChange {
  JsonTaskJoin join;

  TaskNumChange(this.join);

  factory TaskNumChange.fromJson(Map<String, dynamic> srcJson) => _$TaskNumChangeFromJson(srcJson);
  Map<String, dynamic> toJson() => _$TaskNumChangeToJson(this);
}

@JsonSerializable()
class HttpTaskNumChange extends HttpData {
  HttpTaskNumChange(super.code, super.msg);

  TaskNumChange? data;

  factory HttpTaskNumChange.fromJson(Map<String,dynamic> json) => _$HttpTaskNumChangeFromJson(json);
  @override
  Map<String,dynamic> toJson() => _$HttpTaskNumChangeToJson(this);  

}

@JsonSerializable()
class JsonChatInfo extends Object {

  @JsonKey(name: 'cid')
  int cid;

  @JsonKey(name: 'sendername')
  String sendername;

  @JsonKey(name: 'sendericon',defaultValue: "")
  String sendericon;

  @JsonKey(name: 'send_time')
  int sendTime;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'content_type')
  int contentType;

  @JsonKey(name: 'index')
  int index = 0;

  JsonChatInfo(this.cid,this.sendername,this.sendericon,this.sendTime,this.content,this.contentType,);

  factory JsonChatInfo.fromJson(Map<String, dynamic> srcJson) => _$JsonChatInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonChatInfoToJson(this);

}

@JsonSerializable()
class JsonTaskChatInfo extends Object {
  String id;
  int count = 0;
  int index = 0;

  @JsonKey(defaultValue: [])
  List<JsonChatInfo> data;

  @JsonKey(includeFromJson: false,includeToJson: false)
  LoadState state = LoadState.none;

  // 获取最后一条index
  int getLastIndex() {
    if (data.isEmpty) {
      return index;
    }
    return data.last.index;
  }

  JsonTaskChatInfo(this.id,this.data);

  factory JsonTaskChatInfo.fromJson(Map<String, dynamic> srcJson) => _$JsonTaskChatInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonTaskChatInfoToJson(this);
}

@JsonSerializable()
class JsonTaskChatList extends Object {
  List<JsonTaskChatInfo> data;

  JsonTaskChatList(this.data);

  factory JsonTaskChatList.fromJson(Map<String, dynamic> srcJson) => _$JsonTaskChatListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonTaskChatListToJson(this);
}

@JsonSerializable()
class JsonTaskChatRead extends Object {
  String taskid;
  int index;

  JsonTaskChatRead(this.taskid,this.index);

  factory JsonTaskChatRead.fromJson(Map<String, dynamic> srcJson) => _$JsonTaskChatReadFromJson(srcJson);

  Map<String, dynamic> toJson() => _$JsonTaskChatReadToJson(this);
}

@JsonSerializable()
class TaskFinishChange {
  JsonTaskJoin? join;
  @JsonKey(defaultValue: 0)
  int money;
  @JsonKey(defaultValue: 0)
  int getmoney = 0;

  TaskFinishChange(this.money);

  factory TaskFinishChange.fromJson(Map<String, dynamic> srcJson) => _$TaskFinishChangeFromJson(srcJson);
  Map<String, dynamic> toJson() => _$TaskFinishChangeToJson(this);
}