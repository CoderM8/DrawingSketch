import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlViewer extends GetView {
  const HtmlViewer({super.key, required this.title, required this.data});

  final String title;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ConstText(title, fontFamily: "B"),
        leading: ConstSvg(
          "assets/svg/back.svg",
          height: 24.w,
          width: 24.w,
          fit: BoxFit.scaleDown,
          color: blackColor,
          onTap: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Html(
          data: data,
          onLinkTap: (url, attributes, element) async {
            if (url != null) {
              await Apis.lunchApp(url);
            }
          },
          style: {
            "body": Style(fontFamily: "R", fontSize: FontSize(12.sp), color: blackColor),
            "a": Style(fontFamily: "M", fontSize: FontSize(12.sp), color: Colors.blue),
            "strong": Style(fontFamily: "B", fontSize: FontSize(16.sp), color: themeColor),
          },
        ),
      ),
    );
  }
}
