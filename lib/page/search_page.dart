import 'package:bangbang/page/compnent/task_list_title.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/search_control.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:bangbang/util/db_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final SearchControl _searchControl;
  final _userControl = Get.find<UserControl>();
  final RefreshController _refreshController = RefreshController();
  bool _searched = false;

  @override
  void dispose() {
    _textController.dispose();
    _searchControl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchControl = SearchControl();
    Get.put(_searchControl);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void loadMoreSearchTask() async {
    if (_searchControl.isSearchEmpty()) {
      return;
    }
    await _searchControl.loadMoreTask();
    _refreshController.loadComplete();
  }

  void searchRefresh() async {
    if (_searchControl.isSearchEmpty()) {
      return;
    }
    _searchControl.taskRefresh = false;
    await _searchControl.refreshTask();
    _refreshController.refreshCompleted(resetFooterState: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:backButton(),
        title: CupertinoSearchTextField(
          controller: _textController,
          focusNode: _focusNode,
          placeholder: "搜索任务",
          onSubmitted: (value) {
            if (value.isEmpty) {
              return;
            }
            _searched = true;
            _searchControl.resetSearchText(value);
            searchRefresh();
          },
        ),
        actions: [
          Container(
            margin:const EdgeInsets.only(right: 10),
            child: InkWell(onTap: () {
              Get.back();
            }, child: Text("取消",style: TextStyle(color: Colors.grey.shade700),),),
          )
        ],
      ),
      body: GetBuilder<SearchControl>(
        id: "searchList",
        builder: (_) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: false,
            enablePullUp: true,
            header:const WaterDropHeader(),
            footer: CustomFooter(builder: (context, mode) {
                  return GetBuilder<SearchControl>(
                    id: "searchloadState",
                    builder:(_) => Center(child: getLoadStateString(_searchControl.loadMyTaskState))
                  );
              },),
            // onRefresh: searchRefresh,
            onLoading: loadMoreSearchTask,
            child:(_searched && _searchControl.taskList.list.isEmpty)? Center(child:Text("未搜索到相关任务",style: TextStyle(color: Colors.grey.shade800),)) : ListView.builder(
                  itemCount: _searchControl.taskList.list.length,
                  itemBuilder: (context, index) {
                    return GetBuilder<SearchControl>(
                      id: "task_${_searchControl.taskList.list[index]}",
                      builder: (_) {
                        var task = _searchControl.getTask(index);
                        return Container(
                            margin:const EdgeInsets.only(top: 10,left: 5,right: 5),
                            child: TaskListTitle(
                              task,
                              onTap: () {
                                Get.toNamed(Routes.taskInfo ,arguments: {"task":task});
                                // 保存记录
                                if (_userControl.isLogin() && _userControl.userInfo.cid != task.cid) {
                                  DbUtil.instance.saveReadTask(task);
                                }
                              },
                            ),
                          );
                      }
                    );
                  },
              ),
          );
        }
      ),
    );
  }
}