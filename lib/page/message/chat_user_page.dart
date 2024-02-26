import 'package:bangbang/common/iconfont.dart';
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/page/compnent/special_textspan.dart';
import 'package:bangbang/page/compnent/toggle_button.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/chat_user_data_control.dart';
import 'package:bangbang/page/control/chat_user_page_control.dart';
import 'package:bangbang/page/message/chat_base.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatUserPage extends StatefulWidget {
  const ChatUserPage({super.key});

  @override
  State<ChatUserPage> createState() => _ChatUserPageState();
}

class _ChatUserPageState extends State<ChatUserPage> with ChatBase {

  final JsonSimpleUserInfo _user = Get.arguments["user"];
  late final ChatUserPageControl _chatUserPageControl;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _chatUserPageControl = ChatUserPageControl();
    ChatUserDataControl.instance.setChatUserPageControl(_chatUserPageControl);
    Get.put(_chatUserPageControl);

    _scrollController.addListener(_loadChat);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatUserPageControl.initChat(_user.cid);
    });
  }

  @override
  void dispose() {
    
    focusNode.dispose();
    textEditingController.dispose();

    ChatUserDataControl.instance.setChatUserPageControl(null);
    _chatUserPageControl.dispose();
    super.dispose();
  }

  void _loadChat() {
    if (_scrollController.position.maxScrollExtent == _scrollController.position.pixels) {
      _chatUserPageControl.loadMoreChat(_user.cid);
      if (_chatUserPageControl.loadState == LoadState.noMore) {
        _scrollController.removeListener(_loadChat);
      }
    }
  }

   @override
  void mySetState() {
    setState(() {
    });
  }
  
  @override
  void sendMessage(int ctype, String content) {
    if (userControl.isInBlackList(_user.cid)) {
      showToastMsg("您以拉黑对方,无法发送");
      return;
    }
    var user = userControl.userInfo;
    var now = DateTime.now().millisecondsSinceEpoch~/1000;
    var msg = JsonChatUser(user.cid, user.name, user.icon, now, content, ctype);
    _chatUserPageControl.sendChatMsg(msg,_user);
  }

  @override
  bool isUserChat() {
    return true;
  }

  Widget buildMsgSendBtn(){
    var moregrid = ToggleButton(
      activeWidget: const Icon(
        IconFont.icon_guanbi1,
      ),
      unActiveWidget: const Icon(IconFont.icon_tianjiayuan),
      activeChanged: (bool active) {
        change() {
          setState(() {
            if (active) {
              activeEmojiGird = false;
            }else{
              FocusScope.of(context).requestFocus(focusNode);
            }
            activeMoreGrid = active;
          });
        }
        update(change);
      },
      active: activeMoreGrid,
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
                            activeEmojiGird = false;
                            activeMoreGrid =false;
                          });
                        },
                        style: const TextStyle(fontSize: 14),
                        specialTextSpanBuilder: MySpecialTextSpanBuilder(
                          showAtBackground: false,
                        ),
                        maxLength: 255,
                        controller: textEditingController,
                        focusNode: focusNode,
                        maxLines: null,
                        autofocus: false,
                        cursorColor: Colors.cyan,
                        onChanged: (val) {
                          setState(() {
                          });
                        },
                        textInputAction: TextInputAction.send,
                        onEditingComplete: () {
                          
                        },
                        onSubmitted: (value) {
                          sendMsg();
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
                      activeMoreGrid = false;
                    }else{
                      FocusScope.of(context).requestFocus(focusNode);
                    }
                    activeEmojiGird = active;
                  });
                }
                update(change);
              },
              active: activeEmojiGird,
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
    if (activeEmojiGird) {
      gridbutton = buildEmojiGird();
    }

    if (activeMoreGrid) {
      gridbutton = buildParGrid();
    }

    return Container(
      padding: const EdgeInsets.only(top: 10),
      color: Colors.grey.shade100,
      child: gridbutton,
    );
  }

  //显示相册、拍照、位置等
  Widget buildParGrid() {
    double ratio = 1.0;
    //ipad用
    if(((pageWidth / 4 - 50) / 70) > 1.1){
      ratio = ((pageWidth / 4 - 50) / 70);
    }

    var child = [
        buildGridIcon("相册",IconFont.icon_xiangce2,() async {
            loadAssets();
        }),
        buildGridIcon('拍摄',IconFont.icon_paizhao1,() async {
            // pickImage();
            // _chatPageControl.testDeleteChat();
        }),
    ];

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

  @override
  Widget build(BuildContext context) {
    pageWidth = MediaQuery.of(context).size.width - 20;
    keyboardHeight = showCustomKeyBoard ? 230 : 0;

    return WillPopScope(
      onWillPop: () async {
        if(!showCustomKeyBoard){
          return true;
        }
        activeEmojiGird = false;
        activeMoreGrid = false;
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: backButton(),
          title: Text(_user.name),
          centerTitle: true,
        ),
        body: InkWell(
          radius: 0,
          onTap: () {
                if (MediaQuery.of(context).viewInsets.bottom <= 0 && !showCustomKeyBoard) {
                  return;
                }
                setState(() {
                  activeMoreGrid = false;
                  activeEmojiGird = false;
                  focusNode.unfocus();
                });
              },
          child: Column(
            children: [
              Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: GetBuilder<ChatUserPageControl>(
                      builder: (_) {
                          var contentlist = buildMsgContent(_chatUserPageControl.showChatInfo);
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
                    height: keyboardHeight,//MediaQuery.of(context).viewInsets.bottom>0?MediaQuery.of(context).viewInsets.bottom:
                    child: buildCustomKeyBoard(),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
  
 
}