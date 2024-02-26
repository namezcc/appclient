// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpData _$HttpDataFromJson(Map<String, dynamic> json) => HttpData(
      json['code'] as int,
      json['msg'] as String? ?? '',
    );

Map<String, dynamic> _$HttpDataToJson(HttpData instance) => <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
    };

HttpDataString _$HttpDataStringFromJson(Map<String, dynamic> json) =>
    HttpDataString(
      json['data'] as String? ?? '',
    )
      ..code = json['code'] as int
      ..msg = json['msg'] as String? ?? '';

Map<String, dynamic> _$HttpDataStringToJson(HttpDataString instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

JsonUserInfo _$JsonUserInfoFromJson(Map<String, dynamic> json) => JsonUserInfo(
      json['cid'] as int,
      json['phone'] as String,
      json['name'] as String,
      json['sex'] as int,
    )
      ..icon = json['icon'] as String
      ..birth = json['birth'] as String
      ..money = json['money'] as int;

Map<String, dynamic> _$JsonUserInfoToJson(JsonUserInfo instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'phone': instance.phone,
      'name': instance.name,
      'sex': instance.sex,
      'icon': instance.icon,
      'birth': instance.birth,
      'money': instance.money,
    };

HttpDataUserInfo _$HttpDataUserInfoFromJson(Map<String, dynamic> json) =>
    HttpDataUserInfo(
      JsonUserInfo.fromJson(json['data'] as Map<String, dynamic>),
    )
      ..code = json['code'] as int
      ..msg = json['msg'] as String? ?? '';

Map<String, dynamic> _$HttpDataUserInfoToJson(HttpDataUserInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

JsonHttpTaskResult _$JsonHttpTaskResultFromJson(Map<String, dynamic> json) =>
    JsonHttpTaskResult(
      JsonTaskResult.fromJson(json['data'] as Map<String, dynamic>),
    )
      ..code = json['code'] as int
      ..msg = json['msg'] as String? ?? '';

Map<String, dynamic> _$JsonHttpTaskResultToJson(JsonHttpTaskResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

JsonTaskResult _$JsonTaskResultFromJson(Map<String, dynamic> json) =>
    JsonTaskResult(
      TaskConfig.fromJson(json['config'] as Map<String, dynamic>),
      (json['data'] as List<dynamic>)
          .map((e) => JsonTaskInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JsonTaskResultToJson(JsonTaskResult instance) =>
    <String, dynamic>{
      'config': instance.config,
      'data': instance.data,
    };

TaskConfig _$TaskConfigFromJson(Map<String, dynamic> json) => TaskConfig(
      json['globel_limit'] as int,
      (json['longitude'] as num).toDouble(),
      (json['latitude'] as num).toDouble(),
      json['min_distance'] as int,
      json['loc_limit'] as int,
      json['globelMax'] as int,
      json['locMax'] as int,
    )..search = json['search'] as String? ?? '';

Map<String, dynamic> _$TaskConfigToJson(TaskConfig instance) =>
    <String, dynamic>{
      'globel_limit': instance.globelLimit,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'min_distance': instance.minDistance,
      'loc_limit': instance.locLimit,
      'globelMax': instance.globelMax,
      'locMax': instance.locMax,
      'search': instance.search,
    };

JsonMapSearch _$JsonMapSearchFromJson(Map<String, dynamic> json) =>
    JsonMapSearch(
      json['infocode'] as String,
      (json['pois'] as List<dynamic>?)
              ?.map((e) => JsonAddressInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      json['status'] as String,
      json['info'] as String,
    );

Map<String, dynamic> _$JsonMapSearchToJson(JsonMapSearch instance) =>
    <String, dynamic>{
      'infocode': instance.infocode,
      'pois': instance.pois,
      'status': instance.status,
      'info': instance.info,
    };

JsonAddressInfo _$JsonAddressInfoFromJson(Map<String, dynamic> json) =>
    JsonAddressInfo(
      json['address'] as String,
      json['pname'] as String? ?? '',
      json['cityname'] as String? ?? '',
      json['adname'] as String? ?? '',
      json['name'] as String,
      json['location'] as String,
    )
      ..longitude = (json['longitude'] as num?)?.toDouble() ?? 0
      ..latitude = (json['latitude'] as num?)?.toDouble() ?? 0;

Map<String, dynamic> _$JsonAddressInfoToJson(JsonAddressInfo instance) =>
    <String, dynamic>{
      'address': instance.address,
      'pname': instance.pname,
      'cityname': instance.cityname,
      'adname': instance.adname,
      'name': instance.name,
      'location': instance.location,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
    };

JsonTaskInfo _$JsonTaskInfoFromJson(Map<String, dynamic> json) => JsonTaskInfo(
      json['cid'] as int,
      json['creator_name'] as String,
      json['title'] as String,
      json['content'] as String,
      json['money_type'] as int,
      json['money'] as int,
      json['womanMoney'] as int,
      json['people_num'] as int,
      json['man_num'] as int,
      json['end_time'] as int? ?? 0,
    )
      ..id = json['id'] as String
      ..createAt = json['createAt'] as String?
      ..updateAt = json['updateAt'] as String?
      ..creatorIcon = json['creator_icon'] as String?
      ..images =
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList()
      ..delete = json['delete'] as int? ?? 0
      ..address = json['address'] == null
          ? null
          : JsonAddressInfo.fromJson(json['address'] as Map<String, dynamic>)
      ..join = JsonTaskInfo._taskJoin(json['join'] as Map<String, dynamic>?)
      ..state = json['state'] as int? ?? 0;

Map<String, dynamic> _$JsonTaskInfoToJson(JsonTaskInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createAt': instance.createAt,
      'updateAt': instance.updateAt,
      'cid': instance.cid,
      'creator_name': instance.creatorName,
      'creator_icon': instance.creatorIcon,
      'title': instance.title,
      'content': instance.content,
      'images': instance.images,
      'money_type': instance.moneyType,
      'money': instance.money,
      'womanMoney': instance.womanMoney,
      'people_num': instance.peopleNum,
      'man_num': instance.manNum,
      'end_time': instance.endTime,
      'delete': instance.delete,
      'address': instance.address,
      'join': instance.join,
      'state': instance.state,
    };

HttpJsonTaskInfo _$HttpJsonTaskInfoFromJson(Map<String, dynamic> json) =>
    HttpJsonTaskInfo(
      json['code'] as int,
      json['msg'] as String? ?? '',
    )..data = json['data'] == null
        ? null
        : JsonTaskInfo.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$HttpJsonTaskInfoToJson(HttpJsonTaskInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

HttpJsonTaskInfoList _$HttpJsonTaskInfoListFromJson(
        Map<String, dynamic> json) =>
    HttpJsonTaskInfoList(
      json['code'] as int,
      json['msg'] as String? ?? '',
    )..data = (json['data'] as List<dynamic>?)
        ?.map((e) => JsonTaskInfo.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$HttpJsonTaskInfoListToJson(
        HttpJsonTaskInfoList instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

HttpUploadImageInfo _$HttpUploadImageInfoFromJson(Map<String, dynamic> json) =>
    HttpUploadImageInfo(
      json['code'] as int,
      json['msg'] as String? ?? '',
    )..data = (json['data'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList();

Map<String, dynamic> _$HttpUploadImageInfoToJson(
        HttpUploadImageInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

JsonSimpleUserInfo _$JsonSimpleUserInfoFromJson(Map<String, dynamic> json) =>
    JsonSimpleUserInfo(
      json['cid'] as int,
      json['name'] as String,
      json['sex'] as int? ?? 0,
    )
      ..icon = json['icon'] as String? ?? ''
      ..state = json['state'] as int? ?? 0
      ..money = json['money'] as int? ?? 0;

Map<String, dynamic> _$JsonSimpleUserInfoToJson(JsonSimpleUserInfo instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'name': instance.name,
      'sex': instance.sex,
      'icon': instance.icon,
      'state': instance.state,
      'money': instance.money,
    };

JsonTaskJoin _$JsonTaskJoinFromJson(Map<String, dynamic> json) => JsonTaskJoin()
  ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => JsonSimpleUserInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];

Map<String, dynamic> _$JsonTaskJoinToJson(JsonTaskJoin instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

TaskNumChange _$TaskNumChangeFromJson(Map<String, dynamic> json) =>
    TaskNumChange(
      JsonTaskJoin.fromJson(json['join'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TaskNumChangeToJson(TaskNumChange instance) =>
    <String, dynamic>{
      'join': instance.join,
    };

HttpTaskNumChange _$HttpTaskNumChangeFromJson(Map<String, dynamic> json) =>
    HttpTaskNumChange(
      json['code'] as int,
      json['msg'] as String? ?? '',
    )..data = json['data'] == null
        ? null
        : TaskNumChange.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$HttpTaskNumChangeToJson(HttpTaskNumChange instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

JsonChatInfo _$JsonChatInfoFromJson(Map<String, dynamic> json) => JsonChatInfo(
      json['cid'] as int,
      json['sendername'] as String,
      json['sendericon'] as String? ?? '',
      json['send_time'] as int,
      json['content'] as String,
      json['content_type'] as int,
    )..index = json['index'] as int? ?? 0;

Map<String, dynamic> _$JsonChatInfoToJson(JsonChatInfo instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'sendername': instance.sendername,
      'sendericon': instance.sendericon,
      'send_time': instance.sendTime,
      'content': instance.content,
      'content_type': instance.contentType,
      'index': instance.index,
    };

JsonChatUser _$JsonChatUserFromJson(Map<String, dynamic> json) => JsonChatUser(
      json['cid'] as int,
      json['sendername'] as String,
      json['sendericon'] as String? ?? '',
      json['send_time'] as int,
      json['content'] as String,
      json['content_type'] as int,
    )
      ..index = json['index'] as int? ?? 0
      ..tocid = json['tocid'] as int? ?? 0
      ..chatid = json['chatid'] as int? ?? 0
      ..keycid = json['keycid'] as int? ?? 0;

Map<String, dynamic> _$JsonChatUserToJson(JsonChatUser instance) =>
    <String, dynamic>{
      'cid': instance.cid,
      'sendername': instance.sendername,
      'sendericon': instance.sendericon,
      'send_time': instance.sendTime,
      'content': instance.content,
      'content_type': instance.contentType,
      'index': instance.index,
      'tocid': instance.tocid,
      'chatid': instance.chatid,
      'keycid': instance.keycid,
    };

JsonTaskChatInfo _$JsonTaskChatInfoFromJson(Map<String, dynamic> json) =>
    JsonTaskChatInfo(
      json['id'] as String,
      (json['data'] as List<dynamic>?)
              ?.map((e) => JsonChatInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    )
      ..count = json['count'] as int
      ..index = json['index'] as int;

Map<String, dynamic> _$JsonTaskChatInfoToJson(JsonTaskChatInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'count': instance.count,
      'index': instance.index,
      'data': instance.data,
    };

JsonTaskChatList _$JsonTaskChatListFromJson(Map<String, dynamic> json) =>
    JsonTaskChatList(
      (json['data'] as List<dynamic>)
          .map((e) => JsonTaskChatInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JsonTaskChatListToJson(JsonTaskChatList instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

JsonTaskChatRead _$JsonTaskChatReadFromJson(Map<String, dynamic> json) =>
    JsonTaskChatRead(
      json['taskid'] as String,
      json['index'] as int,
    );

Map<String, dynamic> _$JsonTaskChatReadToJson(JsonTaskChatRead instance) =>
    <String, dynamic>{
      'taskid': instance.taskid,
      'index': instance.index,
    };

TaskFinishChange _$TaskFinishChangeFromJson(Map<String, dynamic> json) =>
    TaskFinishChange(
      json['money'] as int? ?? 0,
    )
      ..join = json['join'] == null
          ? null
          : JsonTaskJoin.fromJson(json['join'] as Map<String, dynamic>)
      ..getmoney = json['getmoney'] as int? ?? 0;

Map<String, dynamic> _$TaskFinishChangeToJson(TaskFinishChange instance) =>
    <String, dynamic>{
      'join': instance.join,
      'money': instance.money,
      'getmoney': instance.getmoney,
    };

HttpBlackList _$HttpBlackListFromJson(Map<String, dynamic> json) =>
    HttpBlackList(
      json['code'] as int,
      json['msg'] as String? ?? '',
    )..data =
        (json['data'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];

Map<String, dynamic> _$HttpBlackListToJson(HttpBlackList instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

HttpUserList _$HttpUserListFromJson(Map<String, dynamic> json) => HttpUserList(
      json['code'] as int,
      json['msg'] as String? ?? '',
    )..data = (json['data'] as List<dynamic>?)
            ?.map((e) => JsonSimpleUserInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

Map<String, dynamic> _$HttpUserListToJson(HttpUserList instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };

HttpUserInterest _$HttpUserInterestFromJson(Map<String, dynamic> json) =>
    HttpUserInterest(
      json['code'] as int,
      json['msg'] as String? ?? '',
    )..data = (json['data'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

Map<String, dynamic> _$HttpUserInterestToJson(HttpUserInterest instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
