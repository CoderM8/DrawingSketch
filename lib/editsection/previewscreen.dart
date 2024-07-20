import 'dart:io';

import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/widgets/bottomsheet.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PreviewScreen extends GetView {
  const PreviewScreen({super.key, required this.url, this.isText = false, this.isFile = false});

  final String url;

  /// SET TRUE WHEN PASS VALUE IN [TEXT]
  final bool isText;

  /// SET TRUE WHEN PASS IMAGE [URL] FROM FILE
  final bool isFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ConstText(isText ? 'Text_Preview' : "Preview", fontFamily: "B"),
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
        actions: const [ConstPro()],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isText) ...[
              Container(
                height: 200.w,
                width: MediaQuery.sizeOf(context).width,
                alignment: Alignment.center,
                margin: EdgeInsets.all(20.w),
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(color: whiteColor, borderRadius: BorderRadius.circular(15.r), border: Border.all(color: pinkColor)),
                child: ConstText(url, style: Apis.style(Storages.read('style')['index'], Storages.read('style')['font'], blackColor)),
              ),
              ApplovinAds.showNativeAds(300),
            ] else ...[
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height / 2,
                alignment: Alignment.center,
                margin: EdgeInsets.all(20.w),
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(color: whiteColor, borderRadius: BorderRadius.circular(40.r)),
                child: ClipRRect(borderRadius: BorderRadius.circular(10.r), child: isFile ? Image.file(File(url)) : Image.network(url)),
              ),
              SizedBox(height: 50.h),
              ApplovinAds.showBannerAds()
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: ConstButton(
          icon: ConstText('Start_Drawing', fontSize: 18.sp, fontFamily: 'SB', color: whiteColor),
          height: 60.h,
          color: pinkColor,
          onTap: () async {
            await ApplovinAds.showInterAds();
            selectOption(context, url, isText: isText, isFile: isFile);
          },
        ),
      ),
    );
  }
}
