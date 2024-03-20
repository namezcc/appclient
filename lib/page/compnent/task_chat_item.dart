
import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/common/iconfont.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/scale_animation.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/chat_data_control.dart';
import 'package:bangbang/page/control/task_refresh_control.dart';
import 'package:bangbang/util/db_util.dart';
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
      var content = CommonUtil.getShortChatContent(chat.contentType,chat.content);
      return Text("${chat.sendername}:$content",style: TextStyle(overflow: TextOverflow.ellipsis,fontSize: 10,color: chatcolor),);
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
    if (taskInfo.state == TaskOpenState.incheck.index) {
      ts = TaskState.incheck;
    }else if (taskInfo.delete > 0) {
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
    
    if (ts == TaskState.incheck) {
      str = "审核中";
      color = colorscheme.primary;
    }else if (ts == TaskState.over) {
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
              ToolCompnent.iosDialog("彻底删除","删除后将接收不到消息","删除","取消",
                onConfirm: () {
                  if (taskInfo.cid == cid) {
                    apiDeleteTask(taskInfo.id);
                  }else{
                    apiDeleteUserJoin(taskInfo.id);
                  }
                  control.removeTask(taskInfo);
                  // 删除聊天
                  DbUtil.instance.deleteTaskChat(taskInfo.id);
                  Get.back();
                },
                onCancel: () => Get.back(),
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
                  ToolCompnent.headIcon(taskInfo.creatorIcon??""),
                  const SizedBox(width: 10,),
                  Text(taskInfo.creatorName,style:const TextStyle(fontSize: 12,)),
                  const Expanded(child: SizedBox()),
                  Text(TaskUtil.getNumString(taskInfo),style:const TextStyle(fontSize: 12),),
                ],
              ),
              const Divider(indent: 5,endIndent: 5,thickness: 0.5,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(taskInfo.title,style:const TextStyle(overflow: TextOverflow.ellipsis,)),//fontSize: 14,fontWeight: FontWeight.w500
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
                  Text(TaskUtil.getMoneyString(taskInfo),style: TextStyle(color: colorscheme.primary,fontSize: 10),),
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