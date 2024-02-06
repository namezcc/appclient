import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/control/user_control.dart';
import 'package:flutter/material.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final codeController = TextEditingController();
  final phoneController = TextEditingController();
  final bool _noBack = Get.arguments??false;

  @override
  void dispose() {
    codeController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<HttpData?> _getPhoneCode() async {
    return apiGetPhoneCode(phoneController.text);
  }

  Future<HttpDataString?> _userLogin() async {
    var res = await apiUserLogin(phoneController.text,codeController.text);
    if (res != null) {
      // 获取用户数据
      var userControl = Get.find<UserControl>();
      await userControl.loadUserInfo();
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final colorscheme = Get.theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录"),
        centerTitle: true,
        leading: _noBack ? const SizedBox.shrink() : IconButton(
          icon: Icon(Icons.arrow_back_ios_new,color: colorscheme.primary,),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Container(
          color: colorscheme.onPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              Padding(
                padding:const  EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  decoration:const  InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '手机号',
                  ),
                  controller: phoneController,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding:const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration:const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '验证码',
                        ),
                        controller: codeController,
                      ),
                    ),
                    const SizedBox(width: 20,),
                    FilledButton(
                      onPressed: () async {
                        var res = _getPhoneCode();
                        res.then((value) {
                          var msg = value?.msg;
                          if (value?.code != 0 && msg != null) {
                            showDialog(
                              context: context, 
                              builder: (BuildContext context) => AlertDialog(
                                content:Text(msg),
                              ),
                            );
                          }
                        });
                        }
                      ,
                      style: ElevatedButton.styleFrom(
                        shape:const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        // minimumSize: Size.zero,
                        // padding:const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                      ), 
                      child:const Text("获取"),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 50),
              FilledButton(
                onPressed: () {
                  var res = _userLogin();
                  res.then((value) {
                    if (value?.code == 0) {
                      Get.back();
                    }else{
                      var msg = value?.msg ?? "";
                      showDialog(
                        context: context, 
                        builder: (BuildContext context) => AlertDialog(
                          content:Text(msg),
                        ),
                      );
                    }
                  });
                },
                child:const Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 30),
                  child: Text("登录"),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
  
}