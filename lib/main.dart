import 'dart:convert';

import 'package:bangbang/common/loger.dart';
import 'package:bangbang/common/map.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/logic/login_logic.dart';
import 'package:bangbang/page/binding/manager_binding.dart';
// import 'package:bangbang/page/control/map_location_control.dart';
import 'package:bangbang/routes/app_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'common/global_data.dart';
import 'package:oktoast/oktoast.dart';

void readConfig() async {
  // final file = File("packages/bangbang/assets/json/config.yaml");
  // final data = file.readAsStringSync();
  // final parseData = jsonDecode(data);

  final parseData = await rootBundle.loadString('assets/json/config.json');
  final jsdata = jsonDecode(parseData);
  GlobalData.setHostBase(jsdata["hostbase"]);
  MapConfig.geotolocationurl = jsdata["geotolocationurl"];
}

// String _extractErrorInformation(FlutterErrorDetails details) {
//   return 'Error: ${details.exception}\n'
//       'Stack Trace: ${details.stack}\n'
//       'Context: ${details.context}\n';
// }

Future<void> main() async {

  // FlutterError.onError =(details) async {
  //   final info = _extractErrorInformation(details);
  //   if (kDebugMode) {
  //     logError(info);
  //   }else{
  //     await apiAppCrash(info);
  //     exit(1);
  //   }
  // };


  WidgetsFlutterBinding.ensureInitialized();
  readConfig();
  initDio();
  LoginLogic.refreshLoginToken().then((value) => runApp(const MyApp()));
}

final List<Permission> needPermissionList = [
  Permission.location,
  Permission.storage,
  // Permission.phone,
];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void reassemble() {
    super.reassemble();
    _checkPermissions();
  }

  void _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await needPermissionList.request();
    statuses.forEach((key, value) {
      logDebug('$key premissionStatus is $value');
    });
    // MapLocationControl mapLocationControl = Get.find<MapLocationControl>();
    // mapLocationControl.startLoaction((p0) => logError("location down"));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(
            seedColor:const Color(0xFFD32F2F),
            background: Colors.grey.shade100,
            surface: Colors.white,
            surfaceTint:Colors.white,
            tertiary:Colors.grey.shade700
            
          ),
          platform: TargetPlatform.iOS,
          appBarTheme:const AppBarTheme(scrolledUnderElevation: 0),
          useMaterial3: true,
        ),
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),
        // home: const LoginPage(),
        initialBinding: ManagerBinding(),
        initialRoute: AppPages.inital,
        getPages: AppPages.routs,
        onReady: () => GlobalData.setRunApp(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
