import 'dart:async';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:bangbang/common/loger.dart';
import 'package:bangbang/common/map.dart';
import 'package:bangbang/define/json_class.dart';
import 'package:bangbang/handle/api_handle.dart';
import 'package:bangbang/page/compnent/tool_compnent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GDMap extends StatefulWidget {
  const GDMap({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GDMap();
  }
  
}

class _GDMap extends State<GDMap> {
  late AMapController _mapController;
  final colorscheme = Get.theme.colorScheme;
  // Map<String, Object> _locationResult = {};
  late StreamSubscription<Map<String, Object>> _locationListener;
  int _positionIndex = 0;
  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
  List<JsonAddressInfo> _address = [];
  bool _isMoveByList = false;
  JsonAddressInfo? _myLocation;
  final JsonAddressInfo? _defaultLocation = Get.arguments;

  // Set<Marker> _markers = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
    _locationListener.cancel();
    _locationPlugin.destroy();
  }

  void startLoaction() {
    _locationListener = _locationPlugin.onLocationChanged().listen((event) { 
      logError(event.toString());
      // setState(() {
      //   _locationResult = event;
      // });
      _myLocation = JsonAddressInfo(
        event["address"] as String,
        "", 
        event["city"] as String,
        "", 
        event["address"] as String,""
      );

      var longitude = (event["longitude"] as num).toDouble();
      var latitude = (event["latitude"] as num).toDouble();

      //测试
      longitude = 120.12;
      latitude = 30.16;

      _myLocation?.longitude = longitude;
      _myLocation?.latitude = latitude;
      _myLocation?.location = "$longitude,$latitude";

      _stopLocation();

      // _mapController.moveCamera(CameraUpdate.newLatLng(LatLng(_locationResult["latitude"] as double, _locationResult["longitude"] as double)));
      if (_defaultLocation == null) {
        _mapController.moveCamera(CameraUpdate.newLatLngZoom(LatLng(latitude, longitude),17));
      }
      // _markers = {Marker(position: const LatLng(30.16, 120.12))};
    });

    _setLocationOption();
    _locationPlugin.startLocation();
  }

  void _stopLocation() {
    _locationPlugin.stopLocation();
  }

  ///设置定位参数
  void _setLocationOption() {
    ///将定位参数设置给定位插件
    _locationPlugin.setLocationOption(MapConfig.genLocationOptionn());
  }

  void getApprovalNumber() async {
    // _mapController.moveCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)))
    //普通地图审图号
    // String? mapContentApprovalNumber =
    //     await _mapController?.getMapContentApprovalNumber();
    // //卫星地图审图号
    // String? satelliteImageApprovalNumber =
    //     await _mapController?.getSatelliteImageApprovalNumber();
  }

  void onMapCreated(AMapController controller) {
    if (_defaultLocation != null) {
      controller.moveCamera(CameraUpdate.newLatLngZoom(LatLng(_defaultLocation!.latitude, _defaultLocation!.longitude),17));
    }
    startLoaction();
    setState(() {
      _mapController = controller;
    }); 
  }

  // void onCameraMove(CameraPosition cameraPosition) {
    // _markers = {Marker(position: cameraPosition.target)};
    // setState(() {
    //   _markers = _markers;
    // });
  // }

  void onCameraMoveEnd(CameraPosition cameraPosition) async {
    if (_isMoveByList) {
      _isMoveByList = false;
      return;
    }
    Map<String,Object> param = {};
    param["key"] = MapConfig.getMapWebKey();
    param["location"] = "${cameraPosition.target.longitude},${cameraPosition.target.latitude}";
    param["extensions"] = "all";
    var res = await apiGetMapLocation(param);
    if (res != null && res.pois.isNotEmpty) {
      onGetAddressList(res.pois);
    }
  }

  void onSearchMapLoaction(String msg) async {
    Map<String,Object> param = {};
    param["key"] = MapConfig.getMapWebKey();
    param["keywords"] = msg;
    param["city"] = "杭州市";
    var res = await apiSearchMapLoaction(param);
    if (res != null) {
      onGetAddressList(res.pois);
    }
  }

  void onGetAddressList(List<JsonAddressInfo> pois) {
      if (pois.isNotEmpty) {
        for (var e in pois) {
          e.parseLocation();
        }
        var addres = pois.first;
        _mapController.moveCamera(CameraUpdate.newLatLng(LatLng(addres.latitude, addres.longitude)));
      }

      _scrollController.jumpTo(0);
      setState(() {
        _positionIndex = 0;
        _address = pois;
      });
  }

  @override
  Widget build(BuildContext context) {
    final AMapWidget map = AMapWidget(
      apiKey: MapConfig.amapApiKeys,
      onMapCreated: onMapCreated,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      // markers: _markers,
      // onCameraMove: onCameraMove,
      onCameraMoveEnd: onCameraMoveEnd,
    );

    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     TextButton(onPressed: () {

      //     }, child:const Text("确定"))
      //   ],
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back_ios_new,color: colorscheme.primary,),
      //     onPressed: ()=> Get.back(),
      //   ),
      // ),
      body: Stack(
        children: [
          map,
          Center(
            child:Container(
              padding:const EdgeInsets.only(bottom: 25),
              child: Icon(Icons.location_pin,color: colorscheme.primary,)
            ),
          ),
          Column(
            children: [
              Container(
                padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 30),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new,color: colorscheme.primary,),
                      onPressed: ()=> Get.back(),
                    ),
                    const Expanded(child: SizedBox()),
                    ElevatedButton(onPressed: () {
                      Get.back(result: _address.isEmpty ? null : _address[_positionIndex]);
                    }, 
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        minimumSize: Size.zero
                      ),
                      child:const Text("确定"),
                    )
                  ],
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius:const BorderRadius.all(Radius.circular(5)),
                  color: colorscheme.onPrimary
                ),
                constraints:const BoxConstraints(
                  maxHeight: 250,
                ),
                child: Column(children: [
                  Container(
                    margin:const EdgeInsets.all(5),
                    child: TextField(
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          return;
                        }
                        onSearchMapLoaction(value);
                      },
                      style:const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        hintText: "搜索",
                        contentPadding:const EdgeInsets.symmetric(
                          vertical: 5
                        ),
                        fillColor: colorscheme.background,
                        filled: true,
                        border:const OutlineInputBorder(
                          borderSide: BorderSide.none
                        )
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      // separatorBuilder: (context, index) => Divider(
                      //   color: colorscheme.background,
                      //   thickness: 1,
                      // ),
                      controller: _scrollController,
                      itemCount: _address.length,
                      itemBuilder: (context, index) {
                        var addres = _address[index];
                        var dis = _myLocation == null ? "" : getDistanceAddress(addres,_myLocation!);
                        return Container(
                        decoration: BoxDecoration(
                          color: _positionIndex == index ? colorscheme.primaryContainer : null,
                        ),
                        child: ListTile(
                          title: Text(addres.name,overflow: TextOverflow.ellipsis),
						              subtitle: Text("$dis ${addres.address}",overflow: TextOverflow.ellipsis),
                          selected: _positionIndex == index,
                          selectedColor: colorscheme.primary,
                          onTap: () {
                            if (index == _positionIndex) {
                              return;
                            }
                            
                            _mapController.moveCamera(CameraUpdate.newLatLng(LatLng(addres.latitude, addres.longitude)));
                            setState(() {
                              _isMoveByList = true;
                              _positionIndex = index;
                            });
                          } ,
                        ),
                        );
                      }
                    ,),
                  )
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
}