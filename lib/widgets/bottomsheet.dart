import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/constant/extension.dart';
import 'package:drawing_sketch/editsection/cameraWithImage.dart';
import 'package:drawing_sketch/editsection/cameraWithText.dart';
import 'package:drawing_sketch/editsection/canvasWithImage.dart';
import 'package:drawing_sketch/editsection/canvasWithText.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> selectOption(context, String url, {bool isText = false, bool isFile = false}) {
  final RxBool isImage = false.obs;
  final RxBool isCanvas = false.obs;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: whiteColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), topRight: Radius.circular(40.r))),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 32.h),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: 28.w,
                width: 28.w,
                margin: EdgeInsets.symmetric(horizontal: 30.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border.all(color: blackColor.withOpacity(0.3), width: 2.w), shape: BoxShape.circle),
                child: Icon(Icons.close, color: blackColor.withOpacity(0.3)),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          ConstText("Preview_Tap", fontFamily: "B", fontSize: 20.sp, maxLines: 2),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Obx(() {
              final Color camera = (isImage.value ? pinkColor : blackColor.withOpacity(0.3));
              final Color canvas = (isCanvas.value ? pinkColor : blackColor.withOpacity(0.3));
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 32.w,
                          width: 32.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(border: Border.all(color: camera, width: 2.w), shape: BoxShape.circle),
                          child: ConstText("1", color: camera, fontFamily: "SB", fontSize: 12.sp, textAlign: TextAlign.center),
                        ),
                        SizedBox(height: 10.h),
                        InkWell(
                          borderRadius: BorderRadius.circular(15.r),
                          onTap: () {
                            isImage.value = !isImage.value;
                            if (isImage.value) {
                              isCanvas.value = false;
                            }
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: MediaQuery.sizeOf(context).height / 3.5,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(border: Border.all(color: camera, width: 2.w), borderRadius: BorderRadius.circular(15.r)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset("assets/png/draw_camera.png", height: 140.w, width: 140.w),
                                SizedBox(height: 13.h),
                                Container(
                                  alignment: Alignment.center,
                                  height: 42.h,
                                  width: MediaQuery.sizeOf(context).width,
                                  decoration: BoxDecoration(
                                      color: isImage.value ? pinkColor : borderColor,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12.r),
                                        bottomRight: Radius.circular(12.r),
                                      )),
                                  child: ConstText("Draw_camera", fontSize: 12.sp, fontFamily: "SB", color: isImage.value ? whiteColor : blackColor, textAlign: TextAlign.center, maxLines: 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 32.w,
                          width: 32.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(border: Border.all(color: canvas, width: 2.w), shape: BoxShape.circle),
                          child: ConstText("2", color: canvas, fontFamily: "SB", fontSize: 12.sp, textAlign: TextAlign.center),
                        ),
                        SizedBox(height: 10.h),
                        InkWell(
                          onTap: () {
                            isCanvas.value = !isCanvas.value;
                            if (isCanvas.value) {
                              isImage.value = false;
                            }
                          },
                          child: Container(
                            height: MediaQuery.sizeOf(context).height / 3.5,
                            width: MediaQuery.sizeOf(context).width,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(border: Border.all(color: canvas, width: 2.w), borderRadius: BorderRadius.circular(15.r)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset("assets/png/draw_canvas.png", width: 140.w, height: 140.w),
                                SizedBox(height: 13.h),
                                Container(
                                  alignment: Alignment.center,
                                  height: 42.h,
                                  width: MediaQuery.sizeOf(context).width,
                                  decoration: BoxDecoration(
                                      color: isCanvas.value ? pinkColor : borderColor,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12.r),
                                        bottomRight: Radius.circular(12.r),
                                      )),
                                  child: ConstText("Draw_canvas", fontSize: 12.sp, fontFamily: "SB", color: isCanvas.value ? whiteColor : blackColor, textAlign: TextAlign.center, maxLines: 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 57.h),
          ConstButton(
              text: 'Draw',
              height: 60.h,
              radius: 20.r,
              color: pinkColor,
              onTap: () {
                /// CHECK IMAGE OPTION [TRUE]
                if (isImage.value) {
                  Get.back();

                  /// DRAW TEXT IN CAMERA
                  if (isText) {
                    Get.to(() => CameraTextScreen(text: url));
                  } else {
                    /// DRAW IMAGE IN CAMERA
                    Get.to(() => CameraScreen(url: url, isFile: isFile));
                  }
                }

                /// CHECK CANVAS DRAW [TRUE]
                else if (isCanvas.value) {
                  Get.back();

                  /// DRAW TEXT IN CANVAS
                  if (isText) {
                    Get.to(() => CanvasTextScreen(text: url));
                  } else {
                    /// DRAW IMAGE IN CANVAS
                    Get.to(() => CanvasScreen(url: url, isFile: isFile));
                  }
                }
              }),
          SizedBox(height: 10.h),
          ApplovinAds.showBannerAds(),
          SizedBox(height: 20.h),
        ],
      );
    },
  );
}

Future showPermission(context, {required PerType type}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.h),
            ConstText('Permission', fontSize: 20.sp, fontFamily: 'B'),
            SizedBox(height: 20.h),
            ConstText(
              'Permission_text'.tr.replaceAll('xxx', type.name.tr),
              fontSize: 16.sp,
              fontFamily: 'M',
              padding: EdgeInsets.all(10.r),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    child: ConstText('Cancel', fontSize: 16.sp, color: blackColor.withOpacity(.6)),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    child: ConstText('Setting', color: pinkColor, fontSize: 16.sp, fontFamily: 'B'),
                    onPressed: () async {
                      await openAppSettings();
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      );
    },
  );
}
