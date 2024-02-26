import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SingleSelectPage extends StatefulWidget {
  const SingleSelectPage({super.key});

  @override
  State<SingleSelectPage> createState() => _SingleSelectPageState();
}

class _SingleSelectPageState extends State<SingleSelectPage> {
  int _groupValue = Get.arguments["select"];
  final colorscheme = Get.theme.colorScheme;

  @override
  Widget build(BuildContext context) {
    var vals = Get.arguments["values"] as List<String>;
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title:const Text("选择"),
        centerTitle: true,
      ),
      backgroundColor: colorscheme.surface,
      body: Container(
        margin:const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => const Divider(height: 0,thickness: 0.5),
                itemCount: vals.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(vals[index]),
                    onTap: () {
                      _groupValue = index;
                      setState(() {
                      });
                    },
                    trailing: Radio(value: index, groupValue: _groupValue,onChanged: (value) {
                      _groupValue = index;
                      setState(() {
                      });
                    },),
                  );
              },),
            ),
            Container(
              margin:const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(onPressed: () {
                      Get.back(result: _groupValue);
                    }, child:const Text("确定")),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}