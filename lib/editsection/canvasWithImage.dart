import 'dart:io';

import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/main.dart';
import 'package:drawing_sketch/ui/howtodraw.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key, required this.url, this.isFile = false});

  final String url;
  final bool isFile;

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final RxBool isLock = false.obs;
  final RxBool isFlip = false.obs;
  final RxBool isZoom = false.obs;
  final RxBool isColor = false.obs;
  final RxDouble opacity = 1.0.obs;
  final RxDouble rotateAngle = 0.0.obs;
  final RxInt selectedIndex = 0.obs;
  final RxList bgColor = <Color>[
    const Color(0xffF4F4F4),
    const Color(0xff171717),
    const Color(0xffFF2323),
    const Color(0xffFFA723),
    const Color(0xff23FFBD),
    const Color(0xff237BFF),
    const Color(0xff4F23FF),
    const Color(0xff9123FF),
  ].obs;
  PhotoViewControllerBase<PhotoViewControllerValue> photoViewController = PhotoViewController();
  PhotoViewScaleStateController scaleStateController = PhotoViewScaleStateController();

  /// RESET IMAGE CENTER
  void toggleReset() {
    if (!isLock.value) {
      photoViewController.reset();
      scaleStateController.reset();
      opacity.value = 1.0;
      isZoom.value = true;
      isFlip.value = false;
      selectedIndex.value = 0;
      rotateAngle.value = 0.0;
    }
  }

  ///FLIP IMAGE
  void toggleFlip() {
    if (!isLock.value) {
      isFlip.value = !isFlip.value;
    }
  }

  ///COLOR BACKGROUND
  void toggleColor() {
    if (!isLock.value) {
      isColor.value = !isColor.value;
    }
  }

  /// LOCK IMAGE
  void toggleLock() {
    isLock.value = !isLock.value;
  }

  /// LOCK IMAGE
  void toggleEdge(double value) {
    if (!isLock.value) {
      opacity.value = value;
    }
  }

  /// ROTATE IMAGE
  void toggleRotate() {
    if (!isLock.value) {
      rotateAngle.value += 55.0;
      if (rotateAngle.value >= 220.0) {
        rotateAngle.value = 0.0;
      }
    }
  }

  /// ZOOM IMAGE
  void toggleZoom() {
    isZoom.value = !isZoom.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ConstText('Canvas_Draw', fontFamily: "B"),
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
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ConstSvg(
              "assets/svg/info.svg",
              height: 24.w,
              width: 24.w,
              fit: BoxFit.scaleDown,
              color: blackColor,
              onTap: () {
                Get.to(() => const HowToDraw(fromImg: false));
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        return Container(
          color: bgColor[selectedIndex.value],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AnimatedOpacity(
                  opacity: opacity.value,
                  duration: const Duration(milliseconds: 500),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(isFlip.value ? -1.0 : 1.0, 1.0),
                    child: Transform.rotate(
                      angle: rotateAngle.value,
                      child: PhotoView(
                        initialScale: PhotoViewComputedScale.covered * 0.4,
                        controller: photoViewController,
                        scaleStateController: scaleStateController,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.error_outline, color: whiteColor));
                        },
                        enableRotation: !isLock.value,
                        enablePanAlways: !isLock.value,
                        disableGestures: !isZoom.value || isLock.value,
                        backgroundDecoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(15.r)),
                        imageProvider: widget.isFile ? FileImage(File(widget.url)) : NetworkImage(widget.url) as ImageProvider,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() {
                          return InkWell(
                            onTap: toggleLock,
                            child: Container(
                              height: 42.w,
                              width: 42.w,
                              margin: EdgeInsets.only(bottom: 10.h, left: 20.w),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: isLock.value ? pinkColor : blackColor.withOpacity(0.2)),
                              child: ConstSvg("assets/svg/lock.svg", height: 24.w, width: 24.w, color: whiteColor, fit: BoxFit.scaleDown),
                            ),
                          );
                        }),
                        InkWell(
                          onTap: toggleReset,
                          child: Container(
                            height: 42.w,
                            width: 42.w,
                            margin: EdgeInsets.only(bottom: 10.h, right: 20.w),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: blackColor.withOpacity(0.2)),
                            child: ConstSvg("assets/svg/reset.svg", height: 24.w, width: 24.w, color: whiteColor, fit: BoxFit.scaleDown),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      color: borderColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() {
                            if (isColor.value) {
                              return SizedBox(
                                height: 50.h,
                                child: ListView.builder(
                                  itemCount: bgColor.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.only(top: 10.h, left: 21.w),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        selectedIndex.value = index;
                                      },
                                      child: Obx(() {
                                        return Container(
                                          width: 44.w,
                                          height: 44.w,
                                          decoration: BoxDecoration(border: selectedIndex.value == index ? Border.all(color: bgColor[index], width: 2.w) : null, shape: BoxShape.circle),
                                          child: Container(
                                            width: 42.w,
                                            height: 42.w,
                                            margin: EdgeInsets.all(2.h),
                                            decoration: BoxDecoration(
                                              color: bgColor[index],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              );
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22.w),
                              child: Row(
                                children: [
                                  Image.asset("assets/png/image.png", width: 28.w, height: 28.w, color: blackColor.withOpacity(0.4)),
                                  Expanded(
                                    child: Obx(() {
                                      return SliderTheme(
                                        data: SliderThemeData(
                                          trackShape: CustomSliderTab(),
                                          thumbColor: pinkColor,
                                          trackHeight: 2,
                                          activeTrackColor: Colors.transparent,
                                          inactiveTrackColor: Colors.transparent,
                                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                                        ),
                                        child: Slider(
                                          value: opacity.value,
                                          max: 1,
                                          min: 0.1,
                                          onChanged: toggleEdge,
                                        ),
                                      );
                                    }),
                                  ),
                                  Image.asset("assets/png/image.png", width: 28.w, height: 28.w),
                                ],
                              ),
                            );
                          }),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.only(left: 22.w, right: 22.w),
                            child: Obx(() {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  /// ZOOM-IN ZOOM-OUT IMAGE
                                  InkWell(
                                    onTap: toggleZoom,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ConstSvg("assets/svg/zoom.svg", width: 24.w, height: 24.w, color: isZoom.value ? pinkColor : blackColor),
                                        SizedBox(height: 3.h),
                                        ConstText('Zoom', fontSize: 12.sp, fontFamily: "SB", color: isZoom.value ? pinkColor : blackColor),
                                      ],
                                    ),
                                  ),

                                  /// BACKGROUND COLOR
                                  InkWell(
                                    onTap: toggleColor,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ConstSvg("assets/svg/color.svg", width: 24.w, height: 24.w, color: isColor.value ? pinkColor : blackColor),
                                        SizedBox(height: 3.h),
                                        ConstText('Color', fontSize: 12.sp, fontFamily: "SB", color: isColor.value ? pinkColor : blackColor),
                                      ],
                                    ),
                                  ),

                                  /// FLIP IMAGE
                                  InkWell(
                                    onTap: toggleFlip,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ConstSvg("assets/svg/flip.svg", width: 24.w, height: 24.w, color: isFlip.value ? pinkColor : blackColor),
                                        SizedBox(height: 3.h),
                                        ConstText('Flip', fontSize: 12.sp, fontFamily: "SB", color: isFlip.value ? pinkColor : blackColor),
                                      ],
                                    ),
                                  ),

                                  /// ROTATE IMAGE [55 ANGLE]
                                  InkWell(
                                    onTap: toggleRotate,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ConstSvg("assets/svg/rotate.svg", width: 24.w, height: 24.w),
                                        SizedBox(height: 3.h),
                                        ConstText('Rotate', fontSize: 12.sp, fontFamily: "SB"),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
