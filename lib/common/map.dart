import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_location_option.dart';


class MapConfig {

  static const androidKey = '0572e6a68fa64468f224940d61ce0197';
  static const iosKey = '';
  static const webKey = "9e8fdcbc4a05322d28de3c0490c1fe54";
  static late final String geotolocationurl;
  static const String mapSearchUrl = "https://restapi.amap.com/v3/place/text";

  static const AMapApiKey amapApiKeys = AMapApiKey(
    androidKey: androidKey,
    iosKey: iosKey);

  static const AMapPrivacyStatement amapPrivacyStatement =
  AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);

  static String getMapWebKey() {
    return webKey;
  }

  static AMapLocationOption genLocationOptionn() {
    AMapLocationOption locationOption = AMapLocationOption();

    ///是否单次定位
    locationOption.onceLocation = true;

    ///是否需要返回逆地理信息
    locationOption.needAddress = true;

    ///逆地理信息的语言类型
    locationOption.geoLanguage = GeoLanguage.ZH;

    locationOption.desiredLocationAccuracyAuthorizationMode =
        AMapLocationAccuracyAuthorizationMode.FullAndReduceAccuracy;

    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    ///设置Android端连续定位的定位间隔
    locationOption.locationInterval = 1000;

    ///设置Android端的定位模式<br>
    ///可选值：<br>
    ///<li>[AMapLocationMode.Battery_Saving]</li>
    ///<li>[AMapLocationMode.Device_Sensors]</li>
    ///<li>[AMapLocationMode.Hight_Accuracy]</li>
    locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

    ///设置iOS端的定位最小更新距离<br>
    locationOption.distanceFilter = -1;

    ///设置iOS端期望的定位精度
    /// 可选值：<br>
    /// <li>[DesiredAccuracy.Best] 最高精度</li>
    /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
    /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
    /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
    /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
    locationOption.desiredAccuracy = DesiredAccuracy.Best;

    ///设置iOS端是否允许系统暂停定位
    locationOption.pausesLocationUpdatesAutomatically = false;
    return locationOption;
  }

}