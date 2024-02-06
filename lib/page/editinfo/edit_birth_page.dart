import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditBirthPage extends StatefulWidget {
  const EditBirthPage({super.key,required this.birth});

  final String birth;

  @override
  State<EditBirthPage> createState() => _EditBirthPageState();
}

class _EditBirthPageState extends State<EditBirthPage> {

  late final String newBirth;

  @override
  void initState() {
    super.initState();

    newBirth = widget.birth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(),
        title:const Text("编辑生日"),
        centerTitle: true,
      ),
      body: Container(
        margin:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(child: Text(newBirth.isEmpty? "选择你的生日":newBirth), onPressed: () {
              showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now(),
              cancelText: "取消",
              confirmText: "选择",
              helpText: "选择日期",
              fieldHintText: "22",
              );
            },),
          ],
        ),
      ),
    );
  }
}