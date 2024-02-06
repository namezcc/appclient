import 'package:bangbang/common/loger.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CommonUtil {
  static Future<dio.MultipartFile?> multipartFileFromAssetEntity(AssetEntity entity) async {
    dio.MultipartFile mf;
    // Using the file path.
    final file = await entity.file;
    if (file == null) {
      logError('Unable to obtain file of the entity ${entity.id}.');
      return null;
    }
    // mf = await dio.MultipartFile.fromFile(file.path);
    // Using the bytes.
    final bytes = await entity.originBytes;
    if (bytes == null) {
      logError('Unable to obtain bytes of the entity ${entity.id}.');
      return null;
    }
    final combytes = await FlutterImageCompress.compressWithList(bytes,
        minHeight: entity.height,
        minWidth: entity.width,
        quality: 80,
        format: entity.mimeType!.contains("png") ? CompressFormat.png:CompressFormat.jpeg
      );
    mf = dio.MultipartFile.fromBytes(combytes,
      filename: entity.title
    );
    return mf;
  }

  static String getTimeDiffString(int timeStamp,DateTime now) {
    DateTime dateTimeA = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);

    if (dateTimeA.year == now.year) {
      if (dateTimeA.month == now.month && dateTimeA.day == now.day) {
        return DateFormat('HH:mm').format(dateTimeA);  // 同一天
      } else {
        return DateFormat('M月d日 HH:mm').format(dateTimeA);  // 同一年
      }
    } else {
      return DateFormat('yyyy年M月d日 HH:mm').format(dateTimeA);  // 不同年
    }
  }

  static int getNowSecond() {
    return DateTime.now().millisecondsSinceEpoch~/1000;
  }
}