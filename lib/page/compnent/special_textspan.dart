
import 'package:bangbang/page/compnent/emoji_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  MySpecialTextSpanBuilder({this.showAtBackground = false,  this.isplay = false, this.pagewidth = 0, this.isText = false, this.myonTap,
    this.isopen = false});

  /// whether show background for @somebody
  final bool showAtBackground;
  final bool isplay;
  final bool isText;
  final bool isopen;//是否打开过红包
  final double pagewidth;
  final SpecialTextGestureTapCallback? myonTap; //

  @override
  TextSpan build(String data,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    if (kIsWeb) {
      return TextSpan(text: data, style: textStyle);
    }

    return super.build(data, textStyle: textStyle, onTap: onTap);
  }

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    if (flag == '') {
      return null;
    }
    textStyle ??= const TextStyle(color: Colors.black87, fontSize: 13);

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle,
          start: index - (EmojiText.flag.length - 1));
    }
    else if (isStart(flag, AtText.flag)) {
      return AtText(
        textStyle,
        onTap,
        start: index - (AtText.flag.length - 1),
        showAtBackground: showAtBackground,
      );
    }
    // else if (isStart(flag, SoundText.flag)) {
    //   return SoundText(textStyle, null,
    //       start: index - (EmojiText.flag.length - 1), isplay: this.isplay, isText: this.isText );
    // }
    // else if (isStart(flag, ImageText.flag)) {
    //   return ImageText(textStyle, null,
    //       start: index - (EmojiText.flag.length - 1), isText: this.isText, pageWidth: this.pagewidth);
    // }
    // else if (isStart(flag, LocationText.flag)) {
    //   return LocationText(textStyle, null,
    //       start: index - (LocationText.flag.length - 1), isText: this.isText, pageWidth: this.pagewidth);
    // }
    // else if (isStart(flag, SharedText.flag)){
    //   return SharedText(textStyle, myonTap,
    //     start: index - (SharedText.flag.length - 1), isText: this.isText, pageWidth: this.pagewidth, );
    // }
    // else if (isStart(flag, RedPacketText.flag)){
    //   return RedPacketText(textStyle, myonTap,
    //     start: index - (EmojiText.flag.length - 1), isText: this.isText, isopen: this.isopen, pageWidth: this.pagewidth, );
    // }
    return null;
  }

  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}

class AtText extends SpecialText {
  AtText(TextStyle textStyle,  SpecialTextGestureTapCallback? onTap,
      {this.showAtBackground = false, this.start = 0})
      : super(flag, ' ', textStyle, onTap: onTap);
  static const String flag = '@';
  final int start ;

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  InlineSpan finishText() {
    final TextStyle textStyle = this.textStyle!.copyWith();
    final String atText = toString();

    Paint paint=Paint();
    paint.color = Colors.white;

    return showAtBackground ? BackgroundTextSpan(
      background: paint,
      text: atText,
      actualText: atText,
      start: start,
      ///caret can move into special text
      deleteAll: true,
      style: textStyle,
      recognizer: (TapGestureRecognizer()
        ..onTap = () {
          if (onTap != null) {
            onTap!(atText);
          }
        }))
      : SpecialTextSpan(
        text: atText,
        actualText: atText,
        start: start,
        style: textStyle,
        recognizer: (TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) {
              onTap!(atText);
            }
          }));
  }
}