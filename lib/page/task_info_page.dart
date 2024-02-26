import 'package:bangbang/common/image_cache_manager.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/interest_task_control.dart';
import 'package:bangbang/page/control/join_control.dart';
import 'package:bangbang/page/control/message_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/report/report_task_page.dart';
import 'package:bangbang/page/task/share_task_page.dart';
import 'package:bangbang/page/task/share_task_user_page.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TaskInfoPage extends StatefulWidget {
  const TaskInfoPage({super.key});

  @override
  State<TaskInfoPage> createState() => _TaskInfoPageState();
}

class _TaskInfoPageState extends State<TaskInfoPage> {
  final UserControl _userControl = Get.find<UserControl>();
  final HomeControl _homeControl = Get.find<HomeControl>();
  final JoinControl _joinControl = Get.find<JoinControl>();

  final colorscheme = Get.theme.colorScheme;
  JsonTaskInfo _taskInfo = Get.arguments["task"];

  final RefreshController _refreshController = RefreshController();
  LoadState _loadState = LoadState.none;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();

    super.dispose();
  }

  Widget? getImage(){
    final images = _taskInfo.images;
    if (images != null) {
      List<String> urls = TaskUtil.getImageUrls(_taskInfo);
      if (urls.isNotEmpty) {
        List<Widget> images = [];
        for (var urlstr in urls) {
          images.add(
            CachedNetworkImage(
            imageUrl: urlstr,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) => Container(alignment: Alignment.center,),
            cacheManager: CustomCacheManager.instance,
          )
          );
        }
        return Container(
          constraints:const BoxConstraints(
            maxHeight: 300
          ),
          child: PageView(
            children: images,
          ),
        );
      }
    }
    return null;
  }

  String getEndTime() {
    var endtime = _taskInfo.endTime;
    if (endtime <= 0) {
      return "无";
    }else{
      var diff = endtime - DateTime.now().millisecondsSinceEpoch~/1000;
      if (diff <= 0) {
        return "已结束报名";
      }else{
        var day = diff~/86400;
        if (day > 0) {
          return "还有$day天";
        }
        var hour = (diff%86400)~/3600;
        if (hour > 0) {
          return "还有$hour时";
        }
        var min = (diff%3600)~/60;
        return "还有$min分";
      }
    }
  }

  String getLocationName() {
    var address = _taskInfo.address;
    if (address == null) {
      return "";
    }else{
      return address.name;
    }
  }

  Widget getLocationRow() {
    var address = getLocationName();
    if (address == "") {
      return const SizedBox();
    }else{
      return Row(
              children: [
                const Text("任务地点"),
                Expanded(
                      child: Container(
                        margin:const EdgeInsets.only(left: 10),
                        child: CupertinoButton(
                          onPressed: () {
                            
                          },
                          padding:const EdgeInsets.all(0),
                          minSize: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(child: Text(address,style: TextStyle(fontSize: 12,color: colorscheme.onSurface),)),//overflow: TextOverflow.ellipsis,
                              Icon(Icons.arrow_forward_ios,size: 14,color: colorscheme.onSurface,)
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            );
    }
  }

  Widget getInterestState() {
    return _userControl.isInterestTask(_taskInfo.id)? InkWell(
      onTap: () {
        Get.find<InterestControl>().pullTaskInterest(_taskInfo);
        setState(() {
        });
      },
      child: Icon(Icons.star_rate_rounded,color: colorscheme.primary,)):InkWell(
        onTap: () async {
          var res = await _userControl.pushTaskInterest(_taskInfo.id);
          if (res) {
            setState(() {
            });
          }
        },
        child: const Icon(Icons.star_border_rounded,));
  }

  Widget getEditButton() {
    if (_userControl.userInfo.cid != _taskInfo.cid) {
      return const SizedBox();
    }else{
      return TextButton(onPressed: () async {
        Get.toNamed(Routes.addtask,arguments: {"task":_taskInfo});
      }, child:const Text("编辑"));
    }
  }

  void deleteTask() {
    if (_taskInfo.cid != _userControl.userInfo.cid) {
      return;
    }
    apiDeleteTask(_taskInfo.id).then((value) {
      if (value) {
        showToastMsg("删除成功");
        // 删除本地数据
        final MessageControl messageControl = Get.find<MessageControl>();
        messageControl.removeTask(_taskInfo);
        _joinControl.removeTask(_taskInfo);
        _homeControl.removeTaskInfo(_taskInfo);
        Get.back();
      }
    });
  }

  Widget getOptButton() {
    var user = TaskUtil.getJoinByCid(_userControl.userInfo.cid, _taskInfo);
    if (user != null && user.state != FinishState.none.index) {
      return const ElevatedButton(
          onPressed: null,
          child:Text("已完成"));
    }
    if (TaskUtil.inJoin(_taskInfo, _userControl.userInfo.cid)) {
      return FilledButton(onPressed: () {
        apiQuitTask(_taskInfo.id).then((value) {
          if (value != null) {
            _taskInfo.join = value.join;
            _homeControl.updateAllTaskOne(_taskInfo);
            _joinControl.removeTask(_taskInfo);
            showToastMsg("已退出");
          }else{
            showToastMsg("服务器错误");
          }
        });              
      }, child:const Text("退出"));
    }else{
      if (TaskUtil.canJoin(_taskInfo, _userControl.userInfo.sex)) {
        return FilledButton(onPressed: () {
          apiJoinTask(_taskInfo.id).then((value) {
            if (value == null) {
              showToastMsg("报名出错请重试");
            }else{
              if (value.code == 0) {
                _taskInfo.join = value.data!.join;
                _joinControl.addTask(_taskInfo);
                showToastMsg("报名成功");
              }else{
                if (value.code == ErrorCode.errInBlackList) {
                  showToastMsg("无法加入该用户的任务");
                }
              }
            }
          });
        }, child:const Text("报名"));
      }else{
        return const ElevatedButton(
          onPressed: null,
          child:Text("已满"));
      }
    }
  }

  Widget buildOptButton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius:const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
        color: colorscheme.background,
      ),
      child: Container(
        margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _taskInfo.cid == _userControl.userInfo.cid? ToolCompnent.buildGridIconChild("取消",const Icon(Icons.delete_forever),() {
              
            },):const SizedBox(),
            ToolCompnent.buildGridIconChild("举报",const Icon(Icons.report_problem_rounded),() {
              Get.back();
              Get.to(()=> const ReportTaskPage(),arguments: {"taskid":_taskInfo.id});
            },),
          ],
        ),
      ),
    );
  }

  Widget buildShare() {
    return Container(
      height: 200,
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius:const BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
        color: colorscheme.background,
      ),
      child: Container(
        margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        child: ListView(
          children: [
            CupertinoButton(child:const Text("已报名"), onPressed: () {
              Get.to(()=>const ShareTaskPage<JoinControl>(),arguments: {"task":_taskInfo});
            },),
            CupertinoButton(child:const Text("我的发布"), onPressed: () {
              Get.to(()=>const ShareTaskPage<MessageControl>(),arguments: {"task":_taskInfo});
            },),
            CupertinoButton(child:const Text("私聊"), onPressed: () {
              Get.to(()=>const ShareTaskUserPage(),arguments: {"task":_taskInfo});
            },),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: colorscheme.primary,),
          onPressed: () {
            var cid = _userControl.userInfo.cid;
            if (_taskInfo.cid != cid && !TaskUtil.inJoin(_taskInfo, cid)) {
              Get.back(result: true);
            }else{
              Get.back();
            }
          },
        ),
        title: Row(
          children: [
            ToolCompnent.toUserPage(ToolCompnent.headIcon(_taskInfo.creatorIcon??""),_taskInfo.cid),
            Text(_taskInfo.creatorName)
          ],
        ),
        titleSpacing: 0,
        actions: [
          getInterestState(),
          getEditButton(),
          IconButton(
            // padding:const EdgeInsets.all(0),
            onPressed: () {
              //deleteTask();
              Get.bottomSheet(buildOptButton());
            },
            // minSize: 0,
            icon: Icon(Icons.more_horiz_rounded,color: colorscheme.primary,),
          )
        ],
      ),
      backgroundColor: colorscheme.surface,
      body: GetBuilder<HomeControl>(
        id: "task_${_taskInfo.id}",
        builder: (homeControl) {
          _taskInfo = homeControl.getTask(_taskInfo.id);
          return Column(
            children: [
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  header:const WaterDropHeader(),
                  onRefresh: () async {
                    if (_loadState != LoadState.none) {
                      return;
                    }
                    _loadState = LoadState.loading;
                    var res = await _homeControl.loadTask(_taskInfo.id);
                    if (res != null) {
                      _taskInfo = res;
                    }
                    _loadState = LoadState.none;
                    _refreshController.refreshCompleted();
                  },
                  child: ListView(
                    children: [
                      getImage() ?? const SizedBox(),
                      Container(
                        margin:const EdgeInsets.symmetric(
                          horizontal: 10
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          
                          children: [
                            Container(
                              margin:const EdgeInsets.only(top: 10),
                              child: Text(
                                _taskInfo.title,
                                softWrap: true,
                                style:const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),),
                            ),
                            Container(
                              margin:const EdgeInsets.only(top: 10,bottom: 10),
                              child: Text(_taskInfo.content,softWrap: true,)
                            ),
                            Divider(indent: 5,endIndent: 5,color: colorscheme.surfaceVariant,),
                            Row(
                              children: [
                                Text(_taskInfo.moneyType == taskMoneyTypeReward ? "可获得报酬" : "需要支付给发布者"),
                                const Expanded(child: SizedBox()),
                                Text(TaskUtil.getMoneyString(_taskInfo),style: TextStyle(
                                  color: colorscheme.primary,
                                  fontSize: 12
                                ),)
                              ],
                            ),
                            Row(
                              children: [
                                const Text("已报名"),
                                const Expanded(child: SizedBox()),
                                CupertinoButton(
                                  onPressed: () {
                                    Get.toNamed(Routes.taskMember,arguments: {"task":_taskInfo});
                                  },
                                  padding:const EdgeInsets.all(0),
                                  minSize: 0,
                                  child: Row(
                                    children: [
                                      Text(TaskUtil.getNumString(_taskInfo),style:const TextStyle(fontSize: 12),),
                                      const Icon(Icons.arrow_forward_ios_rounded,size: 14,)
                                    ],
                                  )
                                )
                              ],
                            ),
                            Row(
                              children: [
                                const Text("报名截止时间"),
                                const Expanded(child: SizedBox()),
                                Text(getEndTime(),style: TextStyle(fontSize: 12,color: colorscheme.primary)),
                              ],
                            ),
                            getLocationRow(),
                            Row(
                              children: [
                                const Text("发布时间"),
                                const Expanded(child: SizedBox()),
                                Text(_taskInfo.createAt ?? "",style: const TextStyle(fontSize: 12))
                              ],
                            )
                              
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: Container(
                  margin:const EdgeInsets.only(bottom: 10,left: 10,right: 10,top: 5),
                  child: Row(
                    children: [
                      IconButton(onPressed: () {
                        Get.bottomSheet(buildShare());
                      }, icon:const Icon(Icons.ios_share)),
                      Expanded(
                        child:getOptButton(),
                      ),
                    ]
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }
}