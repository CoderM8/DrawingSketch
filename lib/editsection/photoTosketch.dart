import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/editsection/photoeditscreen.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class PhotoToSketch extends GetView {
  const PhotoToSketch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText("Photo_To_Sketch", fontFamily: "B"),
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                InkWell(
                  onTap: () async {
                    await Apis.pickImage(source: ImageSource.gallery).then((url) async {
                      if (url != null) {
                        await Apis.cropImage(fileTest: url).then((value) async {
                          if (value != null) {
                            Get.to(() => OptionScreen(url: value));
                          }
                        });
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 116.w,
                        width: MediaQuery.sizeOf(context).width,
                        margin: EdgeInsets.symmetric(horizontal: 27.w),
                        decoration: BoxDecoration(color: yellowColor.withOpacity(0.5), borderRadius: BorderRadius.circular(35.r)),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 112.w,
                        width: MediaQuery.sizeOf(context).width,
                        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                        decoration: BoxDecoration(color: yellowColor, borderRadius: BorderRadius.circular(35.r)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConstText("${"Image_From".tr} ${"Gallery".tr}", fontFamily: "B", textAlign: TextAlign.start),
                                  SizedBox(height: 5.h),
                                  ConstText("Image_desc", fontSize: 10.sp, textAlign: TextAlign.start, maxLines: 2),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 25.h,
                                    width: 61.w,
                                    margin: EdgeInsets.only(top: 5.h),
                                    decoration: BoxDecoration(color: whiteColor, borderRadius: BorderRadius.circular(25.r)),
                                    child: ConstText("Enter", fontSize: 10.sp, fontFamily: "SB"),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset("assets/png/galleryYellow.png", width: 72.w, height: 72.w, fit: BoxFit.cover),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                InkWell(
                  onTap: () async {
                    await Apis.pickImage(source: ImageSource.camera).then((url) async {
                      if (url != null) {
                        await Apis.cropImage(fileTest: url).then((value) {
                          if (value != null) {
                            Get.to(() => OptionScreen(url: value));
                          }
                        });
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 116.w,
                        width: MediaQuery.sizeOf(context).width,
                        margin: EdgeInsets.symmetric(horizontal: 27.w),
                        decoration: BoxDecoration(color: lightPink.withOpacity(0.5), borderRadius: BorderRadius.circular(35.r)),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 112.w,
                        width: MediaQuery.sizeOf(context).width,
                        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                        decoration: BoxDecoration(color: lightPink, borderRadius: BorderRadius.circular(35.r)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConstText("${"Image_From".tr} ${"Camera".tr}", fontFamily: "B", textAlign: TextAlign.start),
                                  SizedBox(height: 5.h),
                                  ConstText("Image_desc", fontSize: 10.sp, textAlign: TextAlign.start, maxLines: 2),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 25.h,
                                    width: 61.w,
                                    margin: EdgeInsets.only(top: 5.h),
                                    decoration: BoxDecoration(color: whiteColor, borderRadius: BorderRadius.circular(25.r)),
                                    child: ConstText("Enter", fontSize: 10.sp, fontFamily: "SB"),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset("assets/png/cameraPink.png", width: 72.w, height: 72.w, fit: BoxFit.cover),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Lottie.asset("assets/lottie/boy-draw-sketch.json"),
        ],
      ),
    );
  }
}
