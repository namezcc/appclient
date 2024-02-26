
import 'package:bangbang/define/define.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BlackPage extends StatefulWidget {
  const BlackPage({super.key});

  @override
  State<BlackPage> createState() => _BlackPageState();
}

class _BlackPageState extends State<BlackPage> {
  final colorscheme = Get.theme.colorScheme;
  LoadState _loadState = LoadState.none;
  final _userControl = Get.find<UserControl>();
  final RefreshController _refreshController = RefreshController();
  final List<JsonSimpleUserInfo> _users = [];

  

  Future<void> loadUser() async {
    var start = _users.length;
    if (start >= _userControl.blackList.length) {
      _loadState = LoadState.noMore;
      return;
    }

    var endi = start + 20;
    if (endi > _userControl.blackList.length) {
      endi = _userControl.blackList.length;
    }

    var cids = _userControl.blackList.sublist(start,endi);
    _loadState = LoadState.loading;
    var res = await apiGetUserList(cids);
    if (res != null) {
      _users.addAll(res.data);
    }
    if (_users.length == _userControl.blackList.length) {
      _loadState = LoadState.noMore;
    }else{
      _loadState = LoadState.none;
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var oldlen = _userControl.blackList.length;
    return FutureBuilder(future:loadUser(),builder: (context, snapshot) {
      return Scaffold(
        appBar: AppBar(
          leading: backButton(),
          title:const Text("黑名单"),
          centerTitle: true,
        ),
        body: _users.isEmpty? const Center(child: Text("空空的",style: TextStyle(color: Colors.grey),),) : Container(
          margin:const EdgeInsets.only(top: 10),
          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: false,
            enablePullUp: true,
            footer: CustomFooter(builder: (context, mode) {
                return Center(child: getLoadStateString(_loadState));
            },),
            onLoading: () async {
              await loadUser();
              _refreshController.loadComplete();
            },
            child: ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (context, index) => const Divider(thickness: 0.5,height: 0,),
              itemBuilder: (context, index) {
                var user = _users[index];
                return ToolCompnent.toUserPage(ListTile(
                  tileColor: colorscheme.surface,
                  leading:ToolCompnent.headIcon(user.icon),
                  title: Text(user.name),
                ),user.cid,backFunc: () {
                  if (oldlen != _userControl.blackList.length) {
                    _users.clear();
                    setState(() {
                    });
                  }
                },);
              },
            ),
          ),
        ),
      );
      }
    );
  }
}