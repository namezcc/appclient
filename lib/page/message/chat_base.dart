import 'package:bangbang/common/common_util.dart';
import 'package:bangbang/common/image_cache_manager.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/emoji_text.dart';
import 'package:bangbang/page/compnent/special_textspan.dart';
import 'package:bangbang/page/compnent/task_util.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/home_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/page/image_view_page.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

mixin ChatBase {
  final colorscheme = Get.theme.colorScheme;
  final UserControl userControl = Get.find<UserControl>();

  final FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  bool get showCustomKeyBoard => activeEmojiGird || activeMoreGrid;
  bool activeEmojiGird = false;
  bool activeMoreGrid = false;
  double keyboardHeight = 0.0;
  double pageWidth = 0;
  
  void sendMessage(int ctype,String content);
  void mySetState();
  bool isUserChat();

  void insertText(String text) {
    final TextEditingValue value = textEditingController.value;
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

      textEditingController.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      textEditingController.value = TextEditingValue(
          text: text,
          selection:
          TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
  }

  void deleteText() {
    final TextEditingValue value = textEditingController.value;
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
            textEditingController.value = value.copyWith(
              text: str,
              selection: value.selection.copyWith(
                  baseOffset: findindex, extentOffset: findindex));
            return;
          }
        }
      }
      textEditingController.value = value.copyWith(
      text: str.replaceRange(end-1, end, ""),
      selection: value.selection.copyWith(
          baseOffset: end-1, extentOffset: end-1));
    }
  }

  void sendMsg() {
    if (textEditingController.text.isEmpty) {
      return;
    }
    sendMessage(ChatContentType.text.index,textEditingController.text);
    textEditingController.text = "";
    mySetState();
  }

  sendImg(String localurl, String imgwh, String imgurl) async {
    String msg = "|img: $imgurl#$imgwh|";
    // String localmsg = "|img: $localurl#$imgwh|";
    sendMessage(ChatContentType.image.index,msg);
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

  Future<void> loadAssets() async {
    List<AssetEntity>? resultList;
    try {
      resultList = await AssetPicker.pickAssets(
        Get.context!,
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
              sendImg(url, "$width,$height", url);
              add = true;
            }
          }
      }
      if (add) {
        mySetState();
      }
    }
  }

  List<Widget> buildMsgContent(List<JsonChatInfo> chatList) {
    List<Widget> rows = [];
    var user = userControl.userInfo;
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
    var icon = ToolCompnent.headIcon(i.sendericon);
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
          child:icon,
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
          child: ToolCompnent.toUserPage(ToolCompnent.headIcon(i.sendericon),i.cid,userchat: isUserChat()),
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
    }else if(i.contentType == ChatContentType.task.index) {
      String key = i.content.replaceAll('|task ', '').replaceAll('|', '');
      List<String> imginfo = key.split('#');
      String taskid = imginfo[0];
      String title = imginfo[1];

      return InkWell(
        onTap: () async {
          var res = await Get.find<HomeControl>().loadTask(taskid);
          if (res != null) {
            Get.toNamed(Routes.taskInfo,arguments: {"task":res});
          }
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("任务:$title",softWrap: true,),
                // const Divider(color: Colors.red,thickness: 2,endIndent: 0,indent: 0,),
                Text("点击查看详情",style: TextStyle(fontSize: 10,color: colorscheme.primary),)
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
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
                  mySetState();
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
                      sendMsg();
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

}