import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/ui/howtodraw.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zoom_widget/zoom_widget.dart';

class CanvasTextScreen extends StatefulWidget {
  const CanvasTextScreen({super.key, required this.text});

  final String text;

  @override
  State<CanvasTextScreen> createState() => _CanvasTextScreenState();
}

class _CanvasTextScreenState extends State<CanvasTextScreen> {
  final RxBool isLock = false.obs;
  final RxDouble opacity = 1.0.obs;
  final RxBool isFlip = false.obs;
  final RxBool isColor = false.obs;
  final RxBool isZoom = false.obs;
  final RxDouble rotateAngle = 0.0.obs;
  final RxDouble scale = 1.0.obs;

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

  /// RESET
  void toggleReset() {
    if (!isLock.value) {
      rotateAngle.value = 0.0;
      opacity.value = 1.0;
      scale.value = 1;
      isFlip.value = false;
    }
  }

  ///FLIP TEXT
  void toggleFlip() {
    if (!isLock.value) {
      isFlip.value = !isFlip.value;
    }
  }

  /// LOCK TEXT
  void toggleLock() {
    isLock.value = !isLock.value;
  }

  /// LOCK IMAGE
  void toggleEdge(double value) {
    if (!isLock.value) {
      opacity.value = value;
    }
  }

  /// ZOOM IMAGE
  void toggleZoom() {
    isZoom.value = !isZoom.value;
  }

  ///COLOR BACKGROUND
  void toggleColor() {
    if (!isLock.value) {
      isColor.value = !isColor.value;
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
                child: Transform(
                  /// FLIP
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(isFlip.value ? -1.0 : 1.0, 1.0),
                  child: AnimatedOpacity(
                    opacity: opacity.value,
                    duration: const Duration(milliseconds: 500),
                    child: Zoom(
                      maxZoomHeight: MediaQuery.sizeOf(context).width,
                      maxZoomWidth: MediaQuery.sizeOf(context).width / 2,
                      maxScale: 5,
                      backgroundColor: Colors.transparent,
                      canvasColor: Colors.transparent,
                      zoomSensibility: isLock.value
                          ? 0
                          : isZoom.value
                              ? 0.5
                              : 0,
                      scrollWeight: 0,
                      child: Transform.scale(
                        scale: scale.value,
                        child: Transform.rotate(
                          angle: rotateAngle.value,
                          child: ConstText(widget.text, style: Apis.style(Storages.read('style')['index'], Storages.read('style')['font'], blackColor)),
                        ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                      return Slider(
                                        value: opacity.value,
                                        max: 1,
                                        min: 0.1,
                                        onChanged: toggleEdge,
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
