
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

const List<Tab> tabs = <Tab>[
  Tab(text: 'Zeroth'),
  Tab(text: 'First'),
];

class TestTabbar extends StatelessWidget {
  const TestTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      // The Builder widget is used to have a different BuildContext to access
      // closest DefaultTabController.
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            children: [
              const Text("1111"),
              _TestListView()
            ],
          ),
        );
      }),
    );
  }
}

class _TestListView extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() {
    return TestListView();
  }
  
}

class TestListView extends State<_TestListView> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          enablePullDown: true,
          // scrollController: _controller,
          header:const WaterDropHeader(),
          footer: CustomFooter(builder: (context, mode) {
              return const Text("加载");
          },),
          onRefresh: () async {
            // _messageControl.myTaskRefresh = false;
            // await _messageControl.refreshTask();
            _refreshController.refreshCompleted(resetFooterState: false);
          },
          onLoading: () async {
            // await _messageControl.loadMoreTask();
            _refreshController.loadComplete();
          },
          physics:const AlwaysScrollableScrollPhysics(),
          child: ListView.builder(
            itemCount: 10,
            // physics:const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            itemBuilder: (context, index) {
              // var task = _messageControl.myTaskList[index];
              return Container(
                height: 70,
                margin:const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 5
                ),
                child:const Text("111"),
              );
            },
          ),
        );
  }
  
}