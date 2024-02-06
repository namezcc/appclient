import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditNamePage extends StatefulWidget {
  const EditNamePage({super.key,required this.value});

  final String value;

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void saveName() async {
    if (_controller.text.isEmpty || _controller.text.length <= 2) {
      return;
    }
    if (_controller.text != widget.value) {
      // 检查名字
      var res = await apiEditName(_controller.text);
      if (res) {
        Get.find<UserControl>().updateName(_controller.text);
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title:const Text("编辑名字"),
        centerTitle: true,
        actions: [
          FilledButton(onPressed: saveName, child:const Text("保存"))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
            padding:const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white
            ),
            child:TextField(
              controller: _controller,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 \u4e00-\u9fa5]'))],
              maxLength: 15,
              decoration:const InputDecoration(
                counterText: "",
                contentPadding: EdgeInsets.all(0),
                border: OutlineInputBorder(borderSide: BorderSide.none)
              ),
            ),
          ),
          Container(
            margin:const EdgeInsets.symmetric(horizontal: 15),
            child: Text("2-15个字符",style: TextStyle(fontSize: 14,color: Colors.grey.shade700),)
          )
        ],
      ),
    );
  }
}