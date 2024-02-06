
import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/common/iconfont.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/scale_animation.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/control/chat_data_control.dart';
import 'package:bangbang/page/control/task_refresh_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskChatItem extends StatelessWidget {

  final JsonTaskInfo taskInfo;
  final int cid;
  final void Function()? onTap;
  final TaskRefreshControl control;

  final colorscheme = Get.theme.colorScheme;

  TaskChatItem({
    super.key,
    required this.taskInfo,
    required this.cid,
    required this.control,
    this.onTap,
  });

  Widget getNewChat(JsonChatInfo? chat) {
    var chatcolor = ChatDataControl.instance.haveNewRead(taskInfo.id) ? colorscheme.primary:colorscheme.tertiary;
    if (chat != null) {
      if (chat.contentType == ChatContentType.image.index) {
        return Text("${chat.sendername}:[图片]",style: TextStyle(overflow: TextOverflow.ellipsis,fontSize: 10,color: chatcolor),);
      }
      return Text("${chat.sendername}:${chat.content}",style: TextStyle(overflow: TextOverflow.ellipsis,fontSize: 10,color: chatcolor),);
    }
    return const SizedBox();
  }

  Widget getChatTime(JsonChatInfo? chat) {
    if (chat != null) {
      var val = CommonUtil.getTimeDiffString(chat.sendTime, DateTime.now());
      return Text(" $val",style: TextStyle(fontSize: 10,color: colorscheme.tertiary),);
    }
    return const SizedBox();
  }

  Widget getRedPack() {
    var cangetmoney = TaskUtil.haveReward(taskInfo,cid);
    if (cangetmoney) {
      return ScaleAnimation(
        duration:const Duration(milliseconds: 500),
        child: Icon(IconFont.icon_hongbao2,color: colorscheme.primary,size: 18,),
      );
    }
    return const SizedBox();
  }

  Widget getTaskState() {
    var ts = TaskState.active;
    var str = "进行中";
    var colorOver = colorscheme.tertiary;
    Color? color = Colors.green;
    if (taskInfo.delete > 0) {
      ts = TaskState.delete;
    }else{
      if (cid == taskInfo.cid) {
        if (taskInfo.state > 0) {
          ts = TaskState.over;
        }else{
          if (taskInfo.moneyType == taskMoneyTypeCost) {
            if (TaskUtil.gethaveMoneyTotal(taskInfo) > 0) {
              ts = TaskState.reward;
            }else{
              if (TaskUtil.checkTaskDown(taskInfo,cid)) {
                ts = TaskState.over;
              }
            }
          }
        }
      }else{
        var join = TaskUtil.getJoinByCid(cid, taskInfo);
        if (join != null) {
          if (taskInfo.moneyType == taskMoneyTypeReward) {
            if (join.state == FinishState.haveMoney.index) {
              ts = TaskState.reward;
            }else if(join.state == FinishState.getMoney.index){
              ts = TaskState.over;
            }
          }else{
            if (join.state != FinishState.none.index) {
              ts = TaskState.over;
            }
          }
        }else{
          ts = TaskState.delete;
        }
      }
    }
    if (ts == TaskState.over) {
      str = "已完成";
      color = colorOver;
    }else if(ts == TaskState.reward){
      str = "可领取";
      color = colorscheme.primary;
    }else if(ts == TaskState.delete){
      str = "已结束";
      color = colorOver;
    }

    if (ts == TaskState.over || ts == TaskState.delete) {
      return Row(
        children: [
          Text(str,style: TextStyle(color: color,fontSize: 10),),
          CupertinoButton(
            minSize: 0,
            padding:const EdgeInsets.all(0),
            onPressed: () {
              Get.defaultDialog(
                title: "彻底删除",
                content:const Text("删除后将接收不到消息"),
                textConfirm: "删除",
                textCancel: "取消",
                onConfirm: () {
                  if (taskInfo.cid == cid) {
                    apiDeleteTask(taskInfo.id);
                  }else{
                    apiDeleteUserJoin(taskInfo.id);
                  }
                  control.removeTask(taskInfo);
                  Get.back();
                },
              );
          }, child:const Icon(Icons.close,color: Colors.grey,size: 16,)),
        ],
      );
    }
    return Text(str,style: TextStyle(color: color,fontSize: 10),);
  }
  
  @override
  Widget build(BuildContext context) {
    var chat = ChatDataControl.instance.getNewChat(taskInfo.id);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding:const EdgeInsets.all(5),
          // decoration: BoxDecoration(
          //     borderRadius:const BorderRadius.all(Radius.circular(5)),
          //     color: colorscheme.surface
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: colorscheme.secondary,),
                  const SizedBox(width: 10,),
                  Text(taskInfo.creatorName,),
                  const Expanded(child: SizedBox()),
                  Text(TaskUtil.getNumString(taskInfo),style:const TextStyle(fontSize: 12),),
                ],
              ),
              const Divider(indent: 5,endIndent: 5,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(taskInfo.title,style:const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis,),
                      getNewChat(chat)
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  Column(
                    children: [
                      getChatTime(chat),
                      getRedPack()
                    ],
                  )
                ],
              ),
              // const Divider(indent: 5,endIndent: 5,thickness: 1),
              const SizedBox(height: 5,),
              Row(
                children: [
                  Text(TaskUtil.getMoneyString(taskInfo),style: TextStyle(color: colorscheme.primary,fontSize: 12),),
                  const Expanded(child: SizedBox()),
                  getTaskState()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  
}