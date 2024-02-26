import 'package:bangbang/page/control/chat_user_data_control.dart';
import 'package:get/get.dart';

class ChatUserListControl extends GetxController {
  bool _initLoad = false;
  

  void initLoad() {
    if (_initLoad) {
      return;
    }
    ChatUserDataControl.instance.loadChatUserList().then((value) {
      if (value) {
        update();
      }
    });
    _initLoad = true;
  }

  void deleteChatUser(int cid) {
    ChatUserDataControl.instance.deleteChatUser(cid);
    update();
  }
  
}