import 'package:bangbang/common/image_cache_manager.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/map_location_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskListTitle extends StatelessWidget {
  TaskListTitle(this._taskInfo,{Key? key,
    this.onTap,
  }):super(key: key);

  final JsonTaskInfo _taskInfo;
  final void Function()? onTap;

  final colorscheme = Get.theme.colorScheme;
  final MapLocationControl _mapLocationControl = Get.find<MapLocationControl>();

  Widget getNumInfo() {
    var str = TaskUtil.getNumString(_taskInfo);
    return Text(str,style:const TextStyle(fontSize: 12),);
  }

  Widget getDistance() {
    if (_taskInfo.address == null) {
      return const SizedBox();
    }else{
      if (_mapLocationControl.myLocation == null) {
        if (_taskInfo.address!.cityname == "") {
          return const SizedBox();
        }
        return Row(
          children: [
            const Icon(Icons.location_on,size: 12,),
            Text(_taskInfo.address!.cityname,style:const TextStyle(fontSize: 12),)
          ],
        );
      }else{
        var dis = getDistanceAddress(_taskInfo.address!, _mapLocationControl.myLocation!);
        return Row(
          children: [
            const Icon(Icons.location_on,size: 12,),
            Text(dis,style:const TextStyle(fontSize: 12),)
          ],
        );
      }
    }
  }

  Widget getImage(){
    final images = _taskInfo.images;
    if (images != null) {
      List<String> urls = TaskUtil.getImageUrls(_taskInfo);
      if (urls.isNotEmpty) {
        return SizedBox(
          height: 75,
          width: 75,
          child: CachedNetworkImage(
            imageUrl: urls[0],
            fit: BoxFit.fitHeight,
            errorWidget: (context, url, error) => Container(alignment: Alignment.center,),
            cacheManager: CustomCacheManager.instance,
          ),
        );
      }
    }
    return const SizedBox();
  }

  Widget getMoneyInfo() {
    var style = TextStyle(color: colorscheme.primary,fontSize: 10);//
    return Text(TaskUtil.getMoneyString(_taskInfo),style: style,);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // color: colorscheme.surface,
        // surfaceTintColor: colorscheme.surface,
        child: Container(
          padding:const EdgeInsets.symmetric(horizontal: 5),
          // decoration: BoxDecoration(
          //   // borderRadius:const BorderRadius.all(Radius.circular(5)),
          //   color: colorscheme.surface
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    margin:const EdgeInsets.only(top: 4,right: 3),
                    child:ToolCompnent.headIcon(_taskInfo.creatorIcon??""),
                  ),
                  Text(_taskInfo.creatorName,style:const TextStyle(fontSize: 12,)),
                  const Expanded(child: SizedBox()),
                  getNumInfo(),
                ],
              ),
              Divider(indent: 5,endIndent: 5,color: colorscheme.surfaceVariant,thickness: 0.5,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_taskInfo.title,),//style:const TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                  const Expanded(child: SizedBox()),
                  getImage()
                ],
              ),
              Container(
                margin:const EdgeInsets.only(top: 5,bottom: 5),
                child: Row(
                  children: [
                    getMoneyInfo(),
                    const Expanded(child: SizedBox()),
                    getDistance()
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }
  
}