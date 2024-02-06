
import 'package:logger/logger.dart';

var _logger = Logger();

void _log(Level lv,String? msg,dynamic err,StackTrace? stackTrace) {
  _logger.log(lv, msg,error: err,stackTrace: stackTrace);
}

void logError(String s,{
  dynamic err,
  StackTrace? stackTrace
}) {
  _log(Level.error, s, err, stackTrace);
}

void logInfo(String s,{
  dynamic err,
  StackTrace? stackTrace
}) {
  _log(Level.info, s, err, stackTrace);
}

void logDebug(String s,{
  dynamic err,
  StackTrace? stackTrace
}){
  _log(Level.debug, s, err, stackTrace);
}

