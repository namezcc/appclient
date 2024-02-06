import 'package:bangbang/define/define.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditSexPage extends StatefulWidget {
  const EditSexPage({super.key,required this.sex});

  final int sex;

  @override
  State<EditSexPage> createState() => _EditSexPageState();
}

class _EditSexPageState extends State<EditSexPage> {

  late int newsex;
  final colorscheme = Get.theme.colorScheme;

  @override
  void initState() {
    super.initState();

    newsex = widget.sex;
  }

  void saveSex(int sex) {
    newsex = sex;
    // 保存
    apiEditSex(newsex);
    Get.find<UserControl>().updateSex(newsex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title:const Text("编辑性别"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              children: [
                GestureDetector(
                onTap: () {
                  if (newsex != sexMan) {
                    saveSex(sexMan);
                  }
                },
                child:Container(
                  margin:const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  color: colorscheme.surface,
                  height: 25,
                  child: Row(
                    children: [
                      const Text("男"),
                      const Expanded(child: SizedBox()),
                      newsex == sexMan ? Icon(Icons.check,color: colorscheme.primary,):const SizedBox()
                    ],
                  ),
                ),
              ),
              const Divider(indent: 5,endIndent: 5,thickness: 0.5,height: 0),
              GestureDetector(
                onTap: () {
                  if (newsex != sexWoman) {
                    saveSex(sexWoman);
                  }
                },
                child:Container(
                  margin:const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  color: colorscheme.surface,
                  height: 25,
                  child: Row(
                    children: [
                      const Text("女"),
                      const Expanded(child: SizedBox()),
                      newsex == sexWoman ? Icon(Icons.check,color: colorscheme.primary):const SizedBox()
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}