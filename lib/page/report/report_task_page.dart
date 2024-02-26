import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/report/single_select_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ReportTaskPage extends StatefulWidget {
  const ReportTaskPage({super.key});

  @override
  State<ReportTaskPage> createState() => _ReportTaskPageState();
}

class _ReportTaskPageState extends State<ReportTaskPage> {
  final colorscheme = Get.theme.colorScheme;
  int _taskType = ReportTaskType.fanzui.index;
  final _textContent = TextEditingController();
  List<AssetEntity> _imageListWe = [];
  static const maxPickture = 3;

  void pickImages2() async {
    try {
      List<AssetEntity>? assets = await AssetPicker.pickAssets(Get.context!,pickerConfig: AssetPickerConfig(
        selectedAssets: _imageListWe,
        maxAssets: maxPickture,
        requestType: RequestType.image,
      ));
      if (assets == null) {
        return;
      }
      setState(() {
        _imageListWe = assets;
      });
    } catch (e) {
      logError(e.toString());
      showToastMsg("没有权限,请开启权限");
    }
  }

  void cancelImage(int index) {
    Get.bottomSheet(
      Container(
        height: 150,
        color:const Color.fromARGB(0, 0, 0, 0),
        margin:const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(children: [Expanded(
              child: CupertinoButton(
                onPressed: () {
                  Get.back();
                  _imageListWe.removeAt(index);
                  setState(() {
                  });
                },
                color: colorscheme.surface,
                child: Text("删除",style: TextStyle(color: Colors.blue.shade800),),
              ),
            )],),
            const SizedBox(height: 10,),
            Row(children: [
              Expanded(
              child: CupertinoButton(onPressed: () {
                Get.back();
              }, 
              color: Colors.white,
              child: Text("取消",style: TextStyle(color: Colors.blue.shade800))),
            )],)
          ],
        ),
      ));
  }

  Widget getImageContaner(Widget image,index) {
    return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5)
        ),
        margin:const EdgeInsets.all(5),
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: [
            image,
            SizedBox(
              height: 25,
              width: 25,
              child: IconButton(onPressed: () {
                  cancelImage(index);
                }, 
                style: IconButton.styleFrom(
                  padding:const EdgeInsets.all(0),
                  minimumSize:const Size(20, 20),
                ),
                icon:Icon(Icons.cancel,color: colorscheme.secondary),
              ),
            )
          ]
        ),
      );
  }

  List<Widget> getImageList() {
    var list = List<Widget>.generate(_imageListWe.length, (index) => 
      getImageContaner(AssetEntityImage(_imageListWe[index],
              width: 70,
              height: 70,
            ),index)
      );
    list.add(
      CupertinoButton(
        onPressed: () {
          pickImages2();
        },
        borderRadius: BorderRadius.circular(5),
        alignment: Alignment.center,
        color: colorscheme.background,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 70,
          height: 70,
          child: Icon(
              Icons.add,
              color: colorscheme.onSurface,
            ),
        ),
      )
    );
    return list;
  }

  void submitReport() async {
    if (_textContent.text.isEmpty) {
      showToastMsg("描述内容为空");
      return;
    }

    // 上传图片
    List<String> ossimages = [];

    for (int i = 0; i < _imageListWe.length; i++) {
      var img = await CommonUtil.multipartFileFromAssetEntity(_imageListWe[i]);
      if (img != null) {
        Map<String,dynamic> data = {
          "file":img
        };
        String? url = await apiUploadOssImage(data);
        if (url != null && url.isNotEmpty) {
          url = TaskUtil.getImageUrlByName(url);
          ossimages.add(url);
        }else{
          showToastMsg("图片上传失败,请重试");
          return;
        }
      }else{
        showToastMsg("图片上传失败,请重试");
        return;
      }
    }

    Map<String,dynamic> updata = {
      "taskid":Get.arguments["taskid"],
      "type":_taskType,
      "content":_textContent.text,
      "images":ossimages
    };
    ToolCompnent.showWaiting();
    final res = await apiReportTask(updata);
    ToolCompnent.closeWaiting();
    if (res == true) {
      showToastMsg("举报成功");
      Get.back();
    }else{
      showToastMsg("网络问题,请重试");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("举报任务"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: colorscheme.primary,),
          onPressed: ()=>Get.back(),
        ),
      ),
      backgroundColor: colorscheme.surface,
      body: Container(
        margin:const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      const Text("举报理由"),
                      const Expanded(child: SizedBox()),
                      CupertinoButton(
                        minSize: 0,
                        padding:const EdgeInsets.all(0),
                        child:Row(
                          children: [
                            Text(ReportName.nameTask[_taskType],style:const TextStyle(fontSize: 16),),
                            const Icon(Icons.keyboard_arrow_right_rounded)
                          ],
                        ),
                        onPressed: () {
                          Get.to(()=> const SingleSelectPage(),arguments: {"values":ReportName.nameTask,"select":_taskType})?.then((value) {
                            if (value != null) {
                              _taskType = value;
                              setState(() {
                              });
                            }
                          });
                      },)
                    ],
                  ),
                  const SizedBox(height: 10,),
                  const Text("举报描述"),
                  Container(
                    margin:const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: colorscheme.background,
                    ),
                    child: TextField(
                      maxLength: 200,
                      maxLines: 4,
                      controller: _textContent,
                      style:const TextStyle(
                            fontSize: 12,
                          ),
                      decoration:const InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                      hintText: "详细描述举报原因",
                      border: OutlineInputBorder(
                        // borderSide: BorderSide(width: 1),
                        borderSide:BorderSide.none
                      )
                    ),
                  
                    ),
                  ),
                  const Text("图片证据"),
                  Container(
                    padding:const EdgeInsets.symmetric(
                      // horizontal: 5,
                      vertical: 5,
                    ),
                    child: SizedBox(
                      height: 70,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics:const AlwaysScrollableScrollPhysics(),
                        children: getImageList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin:const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        submitReport();
                      },
                      child:const Text("提交"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}