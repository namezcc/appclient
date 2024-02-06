import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/common/iconfont.dart';
import 'package:bangbang/common/image_cache_manager.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/emoji_text.dart';
import 'package:bangbang/page/compnent/scale_animation.dart';
import 'package:bangbang/page/compnent/special_textspan.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/compnent/toggle_button.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/chat_data_control.dart';
import 'package:bangbang/page/control/chat_page_control.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/image_view_page.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TaskTalkPage extends StatefulWidget {
  const TaskTalkPage({super.key});

  @override
  State<TaskTalkPage> createState() => _TaskTalkPageState();
}

class _TaskTalkPageState extends State<TaskTalkPage> {
  final colorscheme = Get.theme.colorScheme;
  final UserControl _userControl = Get.find<UserControl>();
  final HomeControl _homeControl = Get.find<HomeControl>();
  final ChatPageControl _chatPageControl = Get.find<ChatPageControl>();
  final JsonTaskInfo _taskInfo = Get.arguments["task"];

  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();

  // List<JsonChatInfo> _chatList = [];
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  bool get showCustomKeyBoard => _activeEmojiGird || _activeMoreGrid;
  bool _activeEmojiGird = false;
  bool _activeMoreGrid = false;
  // bool _activeSayingGrid = false;
  double _keyboardHeight = 0.0;
  double _pageWidth = 0;

  @override
  void initState() {
    super.initState();
    ChatDataControl.instance.setChatPageControl(_chatPageControl);
    _chatPageControl.initTaskChat(_taskInfo.id);

    _scrollController.addListener(_loadChat);
  }

  void _loadChat() {
    if (_scrollController.position.maxScrollExtent == _scrollController.position.pixels) {
      _chatPageControl.loadMoreChat();
      if (_chatPageControl.chatInfo.state == LoadState.noMore) {
        _scrollController.removeListener(_loadChat);
      }
    }
  }

  @override
  void dispose() {
    ChatDataControl.instance.setChatPageControl(null);
    _focusNode.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    // 设置已读
    ChatDataControl.instance.readTaskChat(_taskInfo.id);
    super.dispose();
  }

  void insertText(String text) {
    final TextEditingValue value = _textEditingController.value;
    final int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _textEditingController.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _textEditingController.value = TextEditingValue(
          text: text,
          selection:
          TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
  }

  void deleteText() {
    final TextEditingValue value = _textEditingController.value;
    int end = value.selection.extentOffset;
    if (value.selection.isValid && value.selection.isCollapsed) {
      if (end == 0) {
        return;
      }
      var str = value.text;
      if (str[end-1] == EmojiText.flagEnd) {
        var findindex = -1;
        for (var i = end-1; i >= 0; i--) {
          if (str[i] == EmojiText.flag) {
            findindex = i;
            break;
          }
        }
        if (findindex >= 0) {
          var emoji = str.substring(findindex,end);
          if (EmojiUitl.instance.emojiMap.containsKey(emoji)) {
            str = str.replaceRange(findindex, end, "");
            _textEditingController.value = value.copyWith(
              text: str,
              selection: value.selection.copyWith(
                  baseOffset: findindex, extentOffset: findindex));
            return;
          }
        }
      }
      _textEditingController.value = value.copyWith(
      text: str.replaceRange(end-1, end, ""),
      selection: value.selection.copyWith(
          baseOffset: end-1, extentOffset: end-1));
    }
  }

  void update(Function change) {
    if (showCustomKeyBoard) {
      change();
      if(!showCustomKeyBoard) {
        SystemChannels.textInput
            .invokeMethod<void>('TextInput.show')
            .whenComplete(() {
          Future<void>.delayed(const Duration(milliseconds: 200))
              .whenComplete(() {});
        });
      }
    }
    else {
      SystemChannels.textInput
          .invokeMethod<void>('TextInput.hide')
          .whenComplete(() {
        Future<void>.delayed(const Duration(milliseconds: 200))
            .whenComplete(() {
          change();
        });
      });
    }
  }

  void _sendMsg() {
    if (_textEditingController.text.isEmpty) {
      return;
    }
    _sendMessage(ChatContentType.text.index,_textEditingController.text);
    _textEditingController.text = "";
    setState(() {
    });
  }

  void _sendMessage(int ctype,String content) {
    var user = _userControl.userInfo;
    var now = DateTime.now().millisecondsSinceEpoch~/1000;
    var msg = JsonChatInfo(user.cid, user.name, user.icon, now, content, ctype);
    // _chatList.insert(0, msg);
    _chatPageControl.sendChatMsg(_taskInfo.id, msg);
  }

  _sendImg(String localurl, String imgwh, String imgurl) async {
    String msg = "|img: $imgurl#$imgwh|";
    // String localmsg = "|img: $localurl#$imgwh|";
    _sendMessage(ChatContentType.image.index,msg);
  }

  Future<void> loadAssets() async {
    List<AssetEntity>? resultList;
    try {
      resultList = await AssetPicker.pickAssets(
        context,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 9,
          requestType: RequestType.image
        )
      );
    } on Exception catch (e) {
      logError(e.toString());
    }

    if(resultList != null && resultList.isNotEmpty) {
      bool add = false;
      for (int i = 0; i < resultList.length; i++) {
          int width = resultList[i].orientatedWidth;
          int height = resultList[i].orientatedWidth;
          var img = await CommonUtil.multipartFileFromAssetEntity(resultList[i]);
          if (img != null) {
            Map<String,dynamic> data = {
              "file":img
            };
            String? url = await apiUploadOssImage(data);
            if (url != null && url.isNotEmpty) {
              url = TaskUtil.getImageUrlByName(url);
              _sendImg(url, "$width,$height", url);
              add = true;
            }
          }
      }
      if (add) {
        setState(() {
        });
      }
    }
  }

  List<Widget> buildMsgContent(List<JsonChatInfo> chatList) {
    List<Widget> rows = [];
    var user = _userControl.userInfo;
    var now = DateTime.now();
    for (var i = 0; i < chatList.length; i++) {
      var msg = chatList[i];
      bool sameuser = false;
      bool showTime = false;
      if (i + 1 < chatList.length) {
        var nextmsg = chatList[i+1];
        sameuser = nextmsg.cid == user.cid;
        if (msg.sendTime > nextmsg.sendTime + 300) {
          showTime = true;
        }
      }else{
        showTime = true;
      }
      late Widget content;
      if (msg.cid == user.cid) {
        content = buildMyContent(msg, sameuser);
      }else {
        content = buildHerContent(msg, sameuser);
      }
      rows.add(Container(
        margin:const EdgeInsets.symmetric(vertical: 5),
        child: content,
      ));
      if (showTime) {
        rows.add(buildMsgTime(msg,now));
      }
    }
    return rows;
  }

  Widget buildMsgTime(JsonChatInfo i,DateTime now) {
    var val = CommonUtil.getTimeDiffString(i.sendTime, now);
    return Container(
      margin:const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: Text(val,style: TextStyle(fontSize: 10,color: colorscheme.onSurfaceVariant)),
    );
  }

  Widget buildMyContent(JsonChatInfo i,bool isshot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(i.sendername,style: TextStyle(color: colorscheme.onSurface,fontSize: 10),),
            buildContent(i,true)
          ],
        ),
        Container(
          width: 60,
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundColor: colorscheme.secondary,
          ),
        )
      ],
    );
  }

  Widget buildHerContent(JsonChatInfo i,bool isshot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundColor: colorscheme.secondary,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(i.sendername,style: TextStyle(color: colorscheme.onSurface,fontSize: 10)),
            buildContent(i,false)
          ],
        ),
      ],
    );
  }

  Widget buildContent(JsonChatInfo i,bool my) {
    if (i.contentType == ChatContentType.text.index) {
      return Container(
        padding:const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: my ? colorscheme.tertiaryContainer : colorscheme.surface
        ),
        constraints:const BoxConstraints(
          maxWidth: 200
        ),
        child: ExtendedText(i.content,style: TextStyle(
          color: my ? colorscheme.onTertiaryContainer : colorscheme.onSurface,
          // overflow: TextOverflow.ellipsis
        ),specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: false),)
      );
    }else if(i.contentType == ChatContentType.image.index) {
      String key = i.content.replaceAll('|img: ', '').replaceAll('|', '');
      List<String> imginfo = key.split('#');
      String imgurl = imginfo[0];
      // var wh = imginfo[1].split(",");

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5)
        ),
        constraints:const BoxConstraints(
          maxHeight: 100,
        ),
        child: InkWell(
          onTap: () {
            Get.to(()=> const ImageView(),arguments: {"url":imgurl});
          },
          child: CachedNetworkImage(
            imageUrl: imgurl,
            errorWidget: (context, url, error) => Container(color: colorscheme.surface,),
            cacheManager: CustomCacheManager.instance,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget buildMsgSendBtn(){
    var cangetmoney = TaskUtil.haveReward(_taskInfo,_userControl.userInfo.cid);

    var moregrid = ToggleButton(
      activeWidget: const Icon(
        IconFont.icon_guanbi1,
      ),
      unActiveWidget:cangetmoney? const Badge(child:Icon(
        IconFont.icon_tianjiayuan,
      ),) : const Icon(IconFont.icon_tianjiayuan),
      activeChanged: (bool active) {
        change() {
          setState(() {
            if (active) {
              _activeEmojiGird = false;
              // _activeSayingGrid = false;
            }else{
              FocusScope.of(context).requestFocus(_focusNode);
            }
            _activeMoreGrid = active;
          });
        }
        update(change);
      },
      active: _activeMoreGrid,
    );

    return Container(// !important
        color: Colors.grey.shade50,
        width: double.infinity,
        child: Row(
          crossAxisAlignment:   CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Container(
                  height: 39,
                  padding: const EdgeInsets.only(left: 5),
                  margin: const EdgeInsets.only(bottom: 5, top: 5, left: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black26, width: 0.1),
                        borderRadius: BorderRadius.circular((5.0))
                    ),
                    child: ExtendedTextField(
                        onTap: (){
                          setState(() {
                            // _activeSayingGrid = false;
                            _activeEmojiGird = false;
                            _activeMoreGrid =false;
                          });
                        },
                        style: const TextStyle(fontSize: 14),
                        specialTextSpanBuilder: MySpecialTextSpanBuilder(
                          showAtBackground: false,
                        ),
                        maxLength: 255,
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        maxLines: null,
                        autofocus: false,
                        cursorColor: Colors.cyan,
                        onChanged: (val) {
                          // if(val == '@' && _groupRelation.relationtype != 2){
                          //   selectMember();
                          // }
                          setState(() {

                          });
                        },
                        textInputAction: TextInputAction.send,
                        onEditingComplete: () {
                          
                        },
                        onSubmitted: (value) {
                          // logInfo("send $value");
                          _sendMsg();
                        },
                        decoration: const InputDecoration(
                          labelStyle: TextStyle(fontSize: 14),
                          hintStyle: TextStyle(fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white,
                          counterText: '',
                          hintText: '输入新消息',
                        )
                    ),
                )
            ),
            ToggleButton(
              activeWidget: const Icon(
                IconFont.icon_jianpan2,
              ),
              unActiveWidget: const Icon(IconFont.icon_biaoqing),
              activeChanged: (bool active) {
                change() {
                  setState(() {
                    if (active) {
                      _activeMoreGrid = false;
                      // _activeSayingGrid = false;
                    }else{
                      FocusScope.of(context).requestFocus(_focusNode);
                    }
                    _activeEmojiGird = active;
                  });
                }
                update(change);
              },
              active: _activeEmojiGird,
            ),
            moregrid,
          ],
        )
    );
  }

  Widget buildCustomKeyBoard() {
    Widget gridbutton = const SizedBox.shrink();
    // if (_activeSayingGrid) {
    //   gridbutton = buildSayGrid();
    // }
    // else{
    //   if(_recorder.isRecording) {
    //     stopRecorder();
    //   }
    // }

    // if (!showCustomKeyBoard) {
    //   gridbutton = Container();
    // }
    if (_activeEmojiGird) {
      gridbutton = buildEmojiGird();
    }

    if (_activeMoreGrid) {
      gridbutton = buildParGrid();
    }

    return Container(
      padding: const EdgeInsets.only(top: 10),
      color: Colors.grey.shade100,
      child: gridbutton,
    );
  }

  //显示表情图标
  Widget buildEmojiGird() {
    return Stack(
      children: [
          Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, crossAxisSpacing: 20.0, mainAxisSpacing: 15.0),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                // behavior: HitTestBehavior.translucent,
                onTap: () {
                  insertText('[${index + 1}]');
                  setState(() {

                  });
                },
                child: Image.asset(EmojiUitl.instance.emojiMap['[${index + 1}]']??""),
              );
            },
            itemCount: EmojiUitl.instance.emojiMap.length,
            padding: const EdgeInsets.all(5.0),
          ),
        ),
        Column(
          children: [
            const Expanded(child: SizedBox()),
            Container(
              margin:const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 40,
                    width: 50,
                    child: ElevatedButton(onPressed: () {
                      deleteText();
                    }, 
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding:const EdgeInsets.symmetric(horizontal: 10,),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      )
                    ),
                    child:const Icon(Icons.backspace_outlined)),
                  ),
                  const SizedBox(width: 10,),
                  SizedBox(
                    height: 40,
                    width: 50,
                    child: ElevatedButton(onPressed: () {
                      _sendMsg();
                    }, 
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding:const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      )
                    ),
                    child:const Text("发送")),
                  ),
                  const SizedBox(width: 20,),
                ],
              ),
            ),
          ]
        )
      ]
    );
  }

  Widget buildGridIcon(String name,IconData icon,Function()? onTap) {
    return buildGridIconChild(name,Icon(icon),onTap);
  }

  Widget buildGridIconChild(String name,Widget child,Function()? onTap) {
    return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: Column(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:  BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: child
              ),
              const SizedBox(height: 10,),
              Align(
                child: Text(name, style:const TextStyle(color: Colors.black54, fontSize: 13),),
              ),
            ],
          ),
        );
  }

  //显示相册、拍照、位置等
  Widget buildParGrid() {
    double ratio = 1.0;
    //ipad用
    if(((_pageWidth / 4 - 50) / 70) > 1.1){
      ratio = ((_pageWidth / 4 - 50) / 70);
    }

    var child = [
        buildGridIcon("相册",IconFont.icon_xiangce2,() async {
            loadAssets();
        }),
        buildGridIcon('拍摄',IconFont.icon_paizhao1,() async {
            // pickImage();
            _chatPageControl.testDeleteChat();
        }),
        //buildGridIcon('位置',IconFont.icon_weizhi1,null),
        buildGridIcon('成员',IconFont.icon_haoyou,() async {
            Get.toNamed(Routes.taskMember,arguments: {"task":_taskInfo});
        }),
    ];

    if (_userControl.userInfo.cid == _taskInfo.cid) {
      child.add(buildGridIcon('完成任务',IconFont.icon_pintu_huabanfuben,() async {
        Get.bottomSheet(buildFinishTask());
      }),);
      if (_taskInfo.moneyType == taskMoneyTypeCost) {
        var haveMoney = TaskUtil.gethaveMoneyTotal(_taskInfo);
        if (haveMoney > 0) {
          child.add(buildGridIconChild('领取奖励',ScaleAnimation(
                duration:const Duration(milliseconds: 500),
                child: Icon(IconFont.icon_hongbao2,color: colorscheme.primary,),
              ),() async {
            Get.bottomSheet(buildGetPayCost(haveMoney));
          }),);
        }else{
          child.add(buildGridIcon('领取奖励',IconFont.icon_hongbao2,() async {
            Get.bottomSheet(buildGetPayCost(haveMoney));
          }),);
        }
      }
    }else{
      if (_taskInfo.moneyType == taskMoneyTypeCost) {
        child.add(buildGridIcon('支付费用',IconFont.icon_pintu_huabanfuben,() async {
          Get.bottomSheet(buildPayCost());
        }),);
      }else{
        // 领取雇主的奖励
        var user = TaskUtil.getJoinByCid(_userControl.userInfo.cid, _taskInfo);
        if (user!=null && user.money > 0) {
          var icon = user.state == FinishState.haveMoney.index ? ScaleAnimation(
                duration:const Duration(milliseconds: 500),
                child: Icon(IconFont.icon_hongbao2,color: colorscheme.primary,),
              ) : const Icon(IconFont.icon_hongbao2);
          child.add(buildGridIconChild(user.state == FinishState.haveMoney.index? '领取奖励':"已领取",Stack(
            alignment: Alignment.center,
            children: [
              icon,
              Container(
                alignment: Alignment.bottomCenter,
                child: Text("￥${user.money}",style:const TextStyle(color: Colors.red,fontSize: 10),))
            ],
          ),() async {
            if (user.state != FinishState.haveMoney.index) {
              return;
            }

            var res = await apiGetTaskReward(_taskInfo.id);
            if (res == null) {
              showToastMsg("服务器错误");
              return;
            }
            showGetMoney(res.getmoney);
            user.state = FinishState.getMoney.index;
            _homeControl.refreshTaskState(_taskInfo.id);
            setState(() {
            });
          }),);
        }
      }
    }

    return GridView(
      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: ratio,
        crossAxisCount: 4,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0),
      padding: const EdgeInsets.all(1.0),
      children: child,
    );
  }

  
  Widget buildFinishTask() {
    List<JsonSimpleUserInfo> user = _chatPageControl.getFinishTaskUser(_taskInfo);
    int paynum = 0;
    if (_taskInfo.money > 0 && _taskInfo.moneyType == taskMoneyTypeReward) {
      paynum = _taskInfo.money;
    }
    return GetBuilder<ChatPageControl>(
      id: "finishTask",
      builder: (_) {
        var paymoney = _chatPageControl.getFinishChooseNum()*paynum;
        return Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius:const BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
            color: colorscheme.surface,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  itemCount: user.length,
                  itemBuilder: (context, index) {
                    var p = _chatPageControl.finishTask[index];
                    return GestureDetector(
                      onTap: () {
                        if (p.value2 < 0) {
                          // 已完成
                          return;
                        }
                        _chatPageControl.finishTaskChoose(index);
                      },
                      child: Container(
                        padding:const EdgeInsets.symmetric(vertical: 5),
                        color: p.value2 < 0 ? colorscheme.background: colorscheme.surface,
                        child: Row(
                          children: [
                            Container(
                              margin:const EdgeInsets.only(left: 10,right: 10),
                              width: 30,
                              child:p.value2 >= 0 ? Icon(p.value2 > 0 ? Icons.check_box : Icons.check_box_outline_blank,color: p.value2 > 0 ? colorscheme.primary:null,):null,
                            ),
                            CircleAvatar(backgroundColor: colorscheme.secondary,),
                            const SizedBox(width: 5,),
                            Text(user[index].name),
                            const Expanded(child: SizedBox()),
                            p.value2 >= 0 ? const SizedBox():Text("已完成",style: TextStyle(color: colorscheme.secondary),),
                            const SizedBox(width: 20,)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Container(
                    margin:const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        const Text("全选"),
                        Checkbox(value: _chatPageControl.isAllCheck(), onChanged: (value) {
                          _chatPageControl.setFinishTaskChoose(value);
                        },
                        splashRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(onPressed: () async {
                      if (_userControl.userInfo.money < paymoney) {
                        showToastMsg("金额不足");
                        return;
                      }
                      await _chatPageControl.sendFinishTask(_taskInfo);
                      Get.back();
                    }, child:const Text("完成任务")),
                  ),
                  Container(
                    margin:const EdgeInsets.symmetric(horizontal: 5),
                    constraints:const BoxConstraints(
                      minWidth: 50
                    ),
                    child: paynum > 0 ? Text("支付: $paymoney 元",style: TextStyle(color: colorscheme.primary),) : const SizedBox.shrink(),
                  )
                ],
              )
            ],
          ),
        );
      }
    );
  }

  Widget buildGetPayCost(int getMoney) {
    return Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius:const BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
            color: colorscheme.surface,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _taskInfo.join.data.length,
                  itemBuilder: (context, index) {
                    var user = _taskInfo.join.data[index];
                    return Container(
                      margin:const EdgeInsets.only(top: 5,left: 10,right: 10),
                      padding:const EdgeInsets.symmetric(vertical: 10),
                      color: user.state == FinishState.getMoney.index ? colorscheme.background: colorscheme.surface,
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: colorscheme.secondary,),
                          const SizedBox(width: 5,),
                          Text(user.name),
                          const Expanded(child: SizedBox()),
                          user.state == FinishState.none.index ? const SizedBox():Text(
                          user.state == FinishState.haveMoney.index ? "已支付:${user.money}":"已领取:${user.money}",
                          style: TextStyle(color: colorscheme.secondary),),
                        ],
                      ),
                    );
                  },
                )
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                    margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    child: ElevatedButton(onPressed: () async {
                      if (getMoney <= 0) {
                        showToastMsg("都领取完了");
                        Get.back();
                        return;
                      }
                      var res = await apiGetTaskCost(_taskInfo.id);
                      if (res == null) {
                        showToastMsg("服务器错误");
                        return;
                      }
                      Get.back();
                      showGetMoney(res.getmoney);
                      if (res.join != null) {
                        _taskInfo.join = res.join!;
                        _homeControl.refreshTaskState(_taskInfo.id);
                      }
                      _userControl.userInfo.money = res.money;
                      setState(() {
                      });
                    }, child:const Text("领取")),
                    ),
                  )
                ]
              )
            ],
          )
    );
  }

  Widget buildPayCost() {
    var myjoin = TaskUtil.getJoinByCid(_userControl.userInfo.cid, _taskInfo);
    bool ispay = myjoin?.state != FinishState.none.index;
    var paymoney = _userControl.userInfo.sex == sexMan ? _taskInfo.money : _taskInfo.womanMoney;
    List<Widget> child = [];
    if (paymoney <= 0) {
      child.add(Center(child:Text("无需支付",style: TextStyle(color: colorscheme.secondary,fontSize: 24))));
    }else{
      if (ispay) {
        child.add(Center(child:Text("已支付",style: TextStyle(color: colorscheme.secondary,fontSize: 24))));
      }else{
        child = [
            ListTile(
              selected: true,
              title:Text("余额:${_userControl.userInfo.money}"),
              trailing:const Icon(Icons.check),
            ),
            const Expanded(child: SizedBox()),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (paymoney > _userControl.userInfo.money) {
                          showToastMsg("余额不足");
                          return;
                        }
                        var res = await apiPayTaskCost(_taskInfo.id);
                        if (res != null) {
                          myjoin?.state = FinishState.haveMoney.index;
                          _userControl.userInfo.money = res.money;
                          showToastMsg("支付成功");
                          Get.back();
                        }else{
                          showToastMsg("服务器错误");
                        }
                      },
                      child: Text("支付: $paymoney 元",)),
                  )
                ),
              ],
            )
          ];
      }
    }
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius:const BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
        color: colorscheme.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: child,
      )
    );
  }

  void showGetMoney(int num) {
    Get.defaultDialog(title: "获得",
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(IconFont.icon_qian,color: Colors.red,size: 30,),
          Text("$num",style: TextStyle(color: colorscheme.primary,fontSize: 24),),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // _chatList = _chatPageControl.chatInfo.data;
    _pageWidth = MediaQuery.of(context).size.width - 20;
    // if(MediaQuery.of(context).viewInsets.bottom>0) {
    //   if (_keyboardHeight > 0) {
    //     _keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    //   }
    //   // _keyboardHeight = 0;
    //   // if(_initkeyboardHeight != MediaQuery.of(context).viewInsets.bottom){
    //   //   _initkeyboardHeight = MediaQuery
    //   //       .of(context)
    //   //       .viewInsets
    //   //       .bottom;
    //   //   saveKeyBoardHeight(_initkeyboardHeight);
    //   // }
    // }
    // else{
    // }
    _keyboardHeight = showCustomKeyBoard ? 230 : 0;
    // _fixChatBoxHeight();

    return WillPopScope(
      onWillPop: ()async{
        if(!showCustomKeyBoard){
          return true;
        }
        _activeEmojiGird = false;
        _activeMoreGrid = false;
        // _activeSayingGrid = false;
        // setState(() {
        // });
        return false;
      },
      child: GetBuilder<HomeControl>(
        id: "task_${_taskInfo.id}",
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,color: colorscheme.primary,),
                onPressed: ()=> Get.back(),
              ),
              title: Text(_taskInfo.title,overflow: TextOverflow.ellipsis,style:const TextStyle(fontSize: 14),),
              centerTitle: true,
              actions: [
                TextButton(onPressed: () {
                  Get.toNamed(Routes.taskInfo,arguments: {"task":_taskInfo})?.then((value) {
                    if (value == true) {
                      Get.back();
                    }
                  });
                }, child:const Icon(Icons.more_horiz_rounded))
              ],
            ),
            body: InkWell(
              radius: 0,
              onTap: () {
                if (MediaQuery.of(context).viewInsets.bottom <= 0 && !showCustomKeyBoard) {
                  return;
                }
                setState(() {
                  _activeMoreGrid = false;
                  // _activeSayingGrid = false;
                  _activeEmojiGird = false;
                  _focusNode.unfocus();
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: GetBuilder<ChatPageControl>(
                        builder: (_) {
                            var contentlist = buildMsgContent(_chatPageControl.showChatInfo);
                            return ListView(
                              reverse: true,
                              shrinkWrap: true,
                              controller: _scrollController,
                              // physics:const AlwaysScrollableScrollPhysics(),
                              // clipBehavior: Clip.none,
                              children: contentlist,  
                          );
                        }
                      ),
                    ),
                  ),
                  buildMsgSendBtn(),
                  AnimatedSize(
                      // vsync: this,
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        height: _keyboardHeight,//MediaQuery.of(context).viewInsets.bottom>0?MediaQuery.of(context).viewInsets.bottom:
                        child: buildCustomKeyBoard(),
                      )
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}