import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/common/image_cache_manager.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/message_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPage();  
}

class _AddTaskPage extends State<AddTaskPage> {
  final colorscheme = Get.theme.colorScheme;
  var _numSelect = [true,false];
  var _moneySelect = [true,false];
  final _textTitle = TextEditingController();
  final _textContent = TextEditingController();
  final _textManNum = TextEditingController(text: "1");
  final _textWomanNum = TextEditingController(text: "0");
  final _textManMoney = TextEditingController(text: "0");
  final _textWomanMoney = TextEditingController(text: "0");
  var _selectedDay = 0;
  var _selectedHour = 0;
  var _selectedMin = 0;
  var _timeValue = "请选择日期";
  var _addressName = "线下任务请选择";
  JsonAddressInfo? _location;
  static const maxPickture = 9;
  final _userControler = Get.find<UserControl>();
  final JsonTaskInfo? _editTask = Get.arguments != null ? Get.arguments["task"] : null;
  JsonTaskInfo? updatedTask;

  final minList = List.generate(60, (index) => index < 10 ? "0${index.toString()}":index.toString());
  final hourList = List.generate(24, (index) => index < 10 ? "0${index.toString()}":index.toString());
  final now = DateTime.now();
  late List<String> dayList;
  // late List<XFile> _imageList;
  late List<AssetEntity> _imageListWe;
  late List<String> _netImage = [];

  @override
  void initState() {
    super.initState();
    
    dayList = List.generate(30, (index) {
      DateFormat df = DateFormat("yyyy-MM-dd");
      final day = now.add(Duration(days: index));
      return df.format(day);
    });

    // _imageList = [];
    _imageListWe = [];

    initEditTask();
  }


  void initEditTask() {
    final editTask = _editTask;
    if (editTask == null) {
      return;
    }
    _textTitle.text = editTask.title;
    _textContent.text = editTask.content;
    _textManMoney.text = editTask.money.toString();
    _textWomanMoney.text = editTask.womanMoney.toString();
    if (editTask.manNum < 0) {
      _textManNum.text = editTask.peopleNum.toString();
    }else{
      var womann = editTask.peopleNum - editTask.manNum;
      _textManNum.text = editTask.manNum.toString();
      _textWomanNum.text = womann.toString();
      _numSelect = [false,true];
    }
    
    if (editTask.moneyType == taskMoneyTypeCost) {
      _moneySelect = [false,true];
    }
    _location = editTask.address;
    if (editTask.address != null) {
      _addressName = editTask.address!.name;
    }
    if (editTask.endTime > 0) {
      DateFormat df = DateFormat("yyyy-MM-dd hh:mm:ss");
      var endtime = DateTime.fromMillisecondsSinceEpoch(editTask.endTime*1000);
      _timeValue = df.format(endtime);
    }

    if (editTask.images != null) {
      _netImage = TaskUtil.getImageUrls(editTask);
    }
  }

  @override
  void dispose() {
    _textManNum.dispose();
    _textWomanNum.dispose();
    _textManMoney.dispose();
    _textWomanMoney.dispose();
    super.dispose();
  }

  void changePeopleNum(index) {
    var nselect = [false,false];
    nselect[index] = true;
    setState(() {
      _numSelect = nselect;
    });
  }



  void changeMoneyType(index) {
    var nselect = [false,false];
    nselect[index] = true;
    setState(() {
      _moneySelect = nselect;
    });
  }

  bool editCheck() {
    if (_textTitle.text.isEmpty) {
      showToastMsg("标题不能为空");
      return false;
    }
    if (_textContent.text.isEmpty) {
      showToastMsg("内容不能为空");
      return false;
    }

    try {
      var endtime = DateTime.parse(_timeValue);
      if (endtime.compareTo(DateTime.now()) <= 0) {
        showToastMsg("截止时间不能小于现在");
        return false;
      }
    } catch (e) {
      showToastMsg("请选择截止时间");
      return false;
    }

    var total = int.parse(_textManNum.text) + int.parse(_textWomanNum.text);
    if (total <= 0 || total > 100) {
      showToastMsg("总人数需在 1~100 之间");
    }
    return true;
  }

  void submitTask() {
    if (!editCheck()) {
      return;
    }

    uploadTask();
  }

  void submitEditTask() {
    if (!editCheck()) {
      return;
    }
    updateTask();
  }

  String getTimeValue() {
    return "${dayList[_selectedDay]} ${hourList[_selectedHour]}:${minList[_selectedMin]}:00";
  }

  TextField createNumberInput(TextEditingController textEditingController) {
    return TextField(
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'^0')),
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
          ],
          controller: textEditingController,
          style:const TextStyle(
            fontSize: 10,
          ),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding:const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:const BorderSide(width: 1),
            )
          ),
        );
  }

  List<Widget> buildPeopleNum() {
    if (_numSelect[1]) {
       return [
                  const Text("男"),
                  SizedBox(
                    width: 50,
                    child: createNumberInput(_textManNum),
                  ),
                  const Text("人"),
                  const SizedBox(width: 10),
                  const Text("女"),
                  SizedBox(
                    width: 50,
                    child: createNumberInput(_textWomanNum),
                  ),
                  const Text("人"),
                ];
    }
    return [
            SizedBox(
              width: 50,
              child: createNumberInput(_textManNum),
            ),
            const Text("人"),
          ];
  }

  List<Widget> buildMoneyNum() {
    if (_moneySelect[1]) {
       return [
                    const Text("男"),
                    SizedBox(
                      width: 50,
                      child: createNumberInput(_textManMoney),
                    ),
                    const Text("元"),
                    const SizedBox(width: 10),
                    const Text("女"),
                    SizedBox(
                      width: 50,
                      child: createNumberInput(_textWomanMoney),
                    ),
                    const Text("元"),
                ];
    }
    return [
            SizedBox(
              width: 50,
              child: createNumberInput(_textManMoney),
            ),
            const Text("元"),
          ];
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: Get.context!,
      builder: (BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius:const BorderRadius.vertical(top: Radius.circular(5)),
          color: colorscheme.surface,
        ),
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  Expanded createPicker(List<Widget> items,int selected,Function(int) onChanged,{bool loop = false}) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 32,
        magnification: 1.22,
        squeeze: 1.2,
        useMagnifier: true,
        looping: loop,
        // This sets the initial item.
        scrollController: FixedExtentScrollController(
          initialItem: selected,
        ),
        // This is called when selected item is changed.
        onSelectedItemChanged: onChanged,
        children: items,
      ),
    );
  }

  void showDateTimePicker() {
    _showDialog(
      Row(
        children: [
          createPicker(List<Widget>.generate(dayList.length, (int index) {
            return Center(child: Text(dayList[index]));
          }),_selectedDay,
            (int selectedItem) {
              setState(() { 
                _selectedDay = selectedItem;
                _timeValue = getTimeValue();
              });
            }
          ),
          createPicker(List<Widget>.generate(hourList.length, (int index) {
            return Center(child: Text(hourList[index]));
          }),_selectedHour,
            (int selectedItem) {
              setState(() { 
                _selectedHour = selectedItem;
                _timeValue = getTimeValue();
              });
            },
            loop: true
          ),
          createPicker(List<Widget>.generate(minList.length, (int index) {
            return Center(child: Text(minList[index]));
          }),_selectedMin,
            (int selectedItem) {
              setState(() { 
                _selectedMin = selectedItem;
                _timeValue = getTimeValue();
              });
            },
            loop: true
          )
        ],
      )
    );
    setState(() { 
      _timeValue = getTimeValue();
    });
  }

  void cancelImage(int index) {
    if (_netImage.isNotEmpty) {
      if (index < _netImage.length) {
        _editTask!.images!.removeAt(index);
        _netImage.removeAt(index);
      }else{
        index = index - _netImage.length;
        _imageListWe.removeAt(index);  
      }
    }else{
      _imageListWe.removeAt(index);
    }
    setState(() {
    });
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
    var listnet = List<Widget>.generate(_netImage.length, (index) {
        return getImageContaner(CachedNetworkImage(
            imageUrl: _netImage[index],
            fit: BoxFit.fitHeight,
            width: 70,
            height: 70,
            errorWidget: (context, url, error) => Container(alignment: Alignment.center,),
            cacheManager: CustomCacheManager.instance,
        ),index);
      }
    );
    var list = List<Widget>.generate(_imageListWe.length, (index) => 
      getImageContaner(AssetEntityImage(_imageListWe[index],
              width: 70,
              height: 70,
            ),listnet.length + index)
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
    listnet.addAll(list);
    return listnet;
  }

  // void pickImages() async {
  //   final picker = ImagePicker();
  //   try {
  //     final pickedFiles = await picker.pickMultiImage(imageQuality: 0);
  //     _imageList.addAll(pickedFiles);
  //     setState(() {
  //       _imageList = _imageList;
  //     });
  //   } catch (e) {
  //     logError(e.toString());
  //     showToastMsg("没有权限,请开启权限");
  //   }
  // }

  void pickImages2() async {
    try {
      var maxnum = maxPickture - _netImage.length;
      List<AssetEntity>? assets = await AssetPicker.pickAssets(Get.context!,pickerConfig: AssetPickerConfig(
        selectedAssets: _imageListWe,
        maxAssets: maxnum,
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

  void toChooseLocation() {
    Get.toNamed(Routes.showmap,arguments: _location)?.then((value) {
      if (value == null) {
        return;
      }
      var addres = value as JsonAddressInfo;
      // logError(addres.address);
      _location = addres;
      setState(() {
        _addressName = addres.name;
      });
    });
  }

  JsonTaskInfo genTaskInfo() {
    var userinfo = _userControler.userInfo;
    var mann = int.parse(_textManNum.text);
    var womann = int.parse(_textWomanNum.text);
    var total = 0;
    if (_numSelect[0]) {
      // 不分性别
      total = mann;
      mann = -1;
    }else{
      total = mann + womann;
    }

    var endtime = DateTime.parse(_timeValue);
    JsonTaskInfo info;
    if (_editTask != null) {
      info = _editTask!;
      info.title = _textTitle.text;
      info.content = _textContent.text;
      info.moneyType = _moneySelect[0] ? 0 : 1;
      info.money = int.parse(_textManMoney.text);
      info.womanMoney = int.parse(_textWomanMoney.text);
      info.peopleNum = total;
      info.manNum = mann;
      info.endTime = endtime.millisecondsSinceEpoch~/1000;
    }else{
      info = JsonTaskInfo(userinfo.cid, userinfo.name,
        _textTitle.text, 
        _textContent.text, 
        _moneySelect[0] ? 0 : 1, 
        int.parse(_textManMoney.text),
        int.parse(_textWomanMoney.text), 
        total, mann, 
        endtime.millisecondsSinceEpoch~/1000);
    }

    if (_imageListWe.isNotEmpty) {
      info.images ??= [];
      info.images!.addAll(List<String>.generate(_imageListWe.length, (index) => "0"));
    }
    info.address = _location;
    return info;
  }

  void uploadTask() {
    apiUploadTask(genTaskInfo()).then((value) {
      if (value == null) {
        showToastMsg("发布失败");
      }else{
        if (value.images != null) {
          showToastMsg("开始上传照片");
          uploadTaskImages(value);
        }else{
          uploadComplete(value);
        }
      }
    });
  }

  void updateTask() {
    // 检查是否改变,是否需要更新

    apiUpdateTask(genTaskInfo()).then((value) {
      if (value == null) {
        showToastMsg("更新失败");
      }else{
        if (_imageListWe.isNotEmpty) {
          showToastMsg("开始上传照片");
          uploadTaskImages(value);
        }else{
          uploadComplete(value);
        }
      }
    });
  }

  void uploadTaskImages(JsonTaskInfo task) async {
    Map<String,dynamic> data = {};
    data["id"] = task.id;
    List<String> upname = [];
    for (var i = 0; i < _imageListWe.length; i++) {
      var index = _netImage.length + i;
      if (task.images![index] == "0") {
        var img = await CommonUtil.multipartFileFromAssetEntity(_imageListWe[i]);
        if (img != null) {
          data["$index"] = img;
          upname.add("$index");
        }
      }
    }
    if (upname.isEmpty) {
      return;
    }
    data["upname"] = upname;

    var res = await apiUploadTaskImage(data);
    if (res == null || res.code != 0) {
        Get.defaultDialog(
        title: "上传失败",
        middleText: "点击重新上传",
        barrierDismissible: false,
        confirm: CupertinoButton(child:const Text("重新上传"), onPressed: () {
          Get.back();
          uploadTaskImages(task);
        },)
      );
    }else{
      for (var e in res.data!) {
        var index = int.parse(e[0]);
        if (index >= 0 && index < task.images!.length) {
          task.images![index] = e[1];
        }
      }
      uploadComplete(task);
    }
  }

  void uploadComplete(JsonTaskInfo task) {
    if (_editTask != null) {
      // 更新本地数据
      updatedTask = task;
      HomeControl homeControl = Get.find<HomeControl>();
      homeControl.updateAllTaskOne(task);
    }else{
      MessageControl messageControl = Get.find<MessageControl>();
      messageControl.addTask(task);
    }

    showToastMsg(_editTask == null ? "发布成功" : "更新成功");
    Get.back();

    // Get.defaultDialog(onConfirm: () {
    //       Get.back();
    //     },
    //     title: "",
    //     titlePadding:const EdgeInsets.all(0),
    //     middleText: _editTask == null ? "发布成功" : "更新成功",
    //     barrierDismissible: false,
    //     textConfirm: "确定"
    //   ).then((value) => Get.back());
  }

  Widget getSubmitButton() {
    if (_editTask == null) {
      return FilledButton(
                onPressed: submitTask,
                child:const Text("发布任务")
              );
    }else{
      return FilledButton(
                onPressed: submitEditTask,
                child:const Text("修改")
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title:const Text("add task"),
        // centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: colorscheme.primary,),
          onPressed: ()=> Get.back(),
        ),
      ),
      backgroundColor: colorscheme.background,
      body: Container(
        margin:const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10
        ),
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: colorscheme.onPrimary,
              ),
              child: TextField(
                maxLength: 20,
                textAlign: TextAlign.center,
                controller: _textTitle,
                textAlignVertical: TextAlignVertical.center,
                style:const TextStyle(
                  fontSize: 14,
                ),
                decoration:const InputDecoration(
                  isCollapsed: true,
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5
                  ),
                  hintText: "任务标题",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    // gapPadding: 0,
                  )
                ),
              ),
            ),
            Container(
              margin:const EdgeInsets.only(
                top: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: colorscheme.onPrimary,
              ),
              child:Column(
                children: [
                  Container(
                    margin:const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    child: TextField(
                        maxLength: 500,
                        maxLines: 7,
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
                          hintText: "任务内容...",
                          border: OutlineInputBorder(
                            // borderSide: BorderSide(width: 1),
                            borderSide:BorderSide.none
                          )
                        ),
                    ),
                  ),
                  Container(
                    padding:const EdgeInsets.symmetric(
                      horizontal: 5,
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
                  // Divider(color: colorscheme.background,thickness: 2,indent: 5,endIndent: 5,),
                  Container(
                    // color: Colors.amber,
                    padding:const EdgeInsets.symmetric(
                      horizontal: 5,
                      // vertical: 5,
                    ),
                    child: Row(
                      children: [
                        ToggleButtons(
                          onPressed: changePeopleNum,
                          isSelected: _numSelect,
                          fillColor: colorscheme.primary,
                          borderColor: colorscheme.primary,
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          constraints:const BoxConstraints(minHeight: 25,minWidth: 55),
                          selectedColor: colorscheme.onPrimary,
                          color: colorscheme.primary,
                          textStyle:const TextStyle(fontSize: 12,),
                          children: const [
                            Text("任务人数"),
                            Text("男女人数")
                          ],
                        ),
                         Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: buildPeopleNum(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider(color: colorscheme.background,thickness: 2,indent: 5,endIndent: 5,),
                  Container(
                    // color: Colors.amber,
                    padding:const EdgeInsets.symmetric(
                      horizontal: 5,
                      // vertical: 5,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ToggleButtons(
                              onPressed: changeMoneyType,
                              isSelected: _moneySelect,
                              fillColor: colorscheme.primary,
                              borderColor: colorscheme.primary,
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              constraints:const BoxConstraints(minHeight: 25,minWidth: 55),
                              selectedColor: colorscheme.onPrimary,
                              color: colorscheme.primary,
                              textStyle:const TextStyle(fontSize: 12,),
                              children: const [
                                Text("任务奖励"),
                                Text("任务收费")
                              ],
                            ),
                             Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: buildMoneyNum(),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin:const EdgeInsets.only(left: 5),
                          child: Text(_moneySelect[0] ? "*你支付给别人的报酬" : "*别人支付给你的费用",
                            style: TextStyle(fontSize: 10,color: colorscheme.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin:const EdgeInsets.symmetric(
                      horizontal: 5
                    ),
                    padding:const EdgeInsets.all(0),
                    child: Row(
                      children: [
                        const Text("报名截止时间"),
                        const Expanded(child: SizedBox(),),
                        CupertinoButton(
                          onPressed: showDateTimePicker,
                          padding:const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10
                          ),
                          child: Text(_timeValue,style:const TextStyle(fontSize: 14)),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin:const EdgeInsets.symmetric(
                      horizontal: 5
                    ),
                    child: Row(
                      children: [
                        const Text("任务地点"),
                        _location == null ? const SizedBox() : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // const Expanded(child: SizedBox()),
                            CupertinoButton(
                              padding:const EdgeInsets.all(0),
                              minSize: 0,
                              child: Icon(Icons.cancel,size: 18,color: colorscheme.onSurface,)
                            , onPressed: (){
                              setState(() {
                                _location = null;
                                _addressName = "线下任务请选择";
                              });
                            }),
                          ],
                        ),
                        Expanded(
                          child: CupertinoButton(
                            onPressed: toChooseLocation,
                            padding:const EdgeInsets.all(0),
                            // minSize: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(child: Text(_addressName,style: TextStyle(fontSize: 12,color: colorscheme.onSurface),overflow: TextOverflow.ellipsis,)),
                                Icon(Icons.location_on,size: 18,color: colorscheme.onSurface,)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin:const EdgeInsets.all(5),
              child: getSubmitButton(),
            )
          ],
        ),
      ),
    );
  }
  
}