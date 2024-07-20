import 'package:drawing_sketch/constant/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ConstText extends StatelessWidget {
  const ConstText(this.text,
      {super.key,
      this.maxLines,
      this.overflow,
      this.textAlign = TextAlign.center,
      this.padding = EdgeInsets.zero,
      this.textDirection,
      this.fontWeight,
      this.fontSize,
      this.height,
      this.letterSpacing,
      this.color,
      this.style,
      this.fontFamily});

  final String text;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? height;
  final double? letterSpacing;
  final Color? color;
  final String? fontFamily;
  final EdgeInsets padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.tr,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaler: const TextScaler.linear(1),
        style: style ?? TextStyle(fontWeight: fontWeight, fontSize: fontSize ?? 18.sp, color: color ?? blackColor, fontFamily: fontFamily ?? "R", height: height, letterSpacing: letterSpacing),
      ),
    );
  }
}
