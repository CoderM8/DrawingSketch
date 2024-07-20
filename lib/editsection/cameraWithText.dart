// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';

import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/getcontroller/videocreationcontroller.dart';
import 'package:drawing_sketch/storages/sqflite.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/ui/howtodraw.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:zoom_widget/zoom_widget.dart';

class CameraTextScreen extends StatefulWidget {
  final String text;

  const CameraTextScreen({super.key, required this.text});

  @override
  State<CameraTextScreen> createState() => _CameraTextScreenState();
}

class _CameraTextScreenState extends State<CameraTextScreen> with WidgetsBindingObserver {
  final CreationController cc = Get.find<CreationController>();

  late CameraController cameraController;

  late Timer timer;
  final RxBool initialize = false.obs; // camera
  final RxBool isFlashOn = false.obs; // flash light
  final RxBool isLock = false.obs; // lock everything
  final RxBool isFullScreen = false.obs; // full screen camera
  final RxBool isRecord = false.obs; // recording start - stop
  final RxBool isFlip = false.obs; // flip text
  final RxBool isZoom = false.obs; // zoom-in/ zoom-out
  final RxDouble scale = 1.0.obs; // zoom-in/ zoom-out
  final RxDouble opacity = 1.0.obs; // text opacity [edge]
  final RxDouble rotateAngle = 0.0.obs; // rotate text
  final RxInt count = 0.obs; // recoding time [second]

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    init();
    super.initState();
  }

  Future<void> init() async {
    /// REQUEST FOR PERMISSION
    await Apis.checkPermission();

    final List<CameraDescription> items = await availableCameras();
    if (items.isNotEmpty) {
      cameraController = CameraController(items[0], ResolutionPreset.high);
      cameraController.initialize().then((_) {
        initialize.value = true;
      }).catchError((Object e) {
        print('HELLO CAMERA ERROR $e');
      });
    } else {
      if (mounted) {
        Apis.constSnack(context, 'empty'.tr.replaceAll('xxx', "${'Camera'.tr} ${'Preview'.tr}"));
      }
    }
  }

  /// BACK CAMERA FLASH
  void toggleFlashLight() async {
    try {
      if (isFlashOn.value) {
        await cameraController.setFlashMode(FlashMode.off);
      } else {
        await cameraController.setFlashMode(FlashMode.torch);
      }
      isFlashOn.value = !isFlashOn.value;
    } on CameraException catch (e) {
      if (mounted) {
        Apis.constSnack(context, '${e.description} 💡');
      }
    }
  }

  /// RESET IMAGE CENTER
  void toggleReset() {
    if (!isLock.value) {
      opacity.value = 1.0;
      isZoom.value = false;
      isFlip.value = false;
      rotateAngle.value = 0.0;
      scale.value = 1.0;
    }
  }

  /// LOCK IMAGE
  void toggleEdge(double value) {
    if (!isLock.value) {
      opacity.value = value;
    }
  }

  ///FLIP IMAGE
  void toggleFlip() {
    if (!isLock.value) {
      isFlip.value = !isFlip.value;
    }
  }

  /// LOCK IMAGE
  void toggleLock() {
    isLock.value = !isLock.value;
  }

  /// ZOOM IMAGE
  void toggleZoom() {
    isZoom.value = !isZoom.value;
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

  /// FULL SCREEN
  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;
  }

  /// VIDEO RECORD TIMER
  void startTimer() {
    count.value = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      count.value++;
    });
  }

  /// STOP RECORD TIMER
  void stopTimer() {
    count.value = 0;
    timer.cancel();
  }

  /// RECORD VIDEO FOR CREATION
  void toggleRecord() async {
    if (isRecord.value) {
      stopTimer();
      await cameraController.stopVideoRecording().then((value) async {
        isRecord.value = false;
        Apis.constSnack(context, "Saved".tr + " Creation".tr);
        final String? file = await Apis.fromFile(value.path);

        final int id = await DatabaseHelper.addVideo(VideoModel(createdAt: DateTime.now().toString(), image: file!, path: value.path, system: Platform.operatingSystem, type: 'Video'));
        await ImageGallerySaver.saveFile(value.path, isReturnPathOfIOS: true, name: "Creation${value.name}");
        cc.videoList.insert(0, VideoModel(id: id, createdAt: DateTime.now().toString(), image: file, path: value.path, system: Platform.operatingSystem, type: 'Video'));
      });
    } else {
      await cameraController.startVideoRecording();
      startTimer();
      isRecord.value = false;
      isRecord.value = true;
    }
  }

  String formatDuration(int seconds) {
    // int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // App state changed before we got the chance to initialize.
    if (!initialize.value) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initialize.value = false;
      await init();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const ConstText('Sketch_Draw', fontFamily: "B"),
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
                Get.to(() => const HowToDraw());
              },
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Obx(() {
                  if (initialize.value) {
                    return CameraPreview(
                      cameraController,
                      child: Transform(
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
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
            ],
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
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isLock.value ? pinkColor : Colors.white.withOpacity(0.2)),
                          child: ConstSvg("assets/svg/lock.svg", height: 24.w, width: 24.w, color: whiteColor, fit: BoxFit.scaleDown),
                        ),
                      );
                    }),
                    Obx(() {
                      if (!isRecord.value) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        height: 40.h,
                        width: 80.w,
                        margin: EdgeInsets.symmetric(vertical: 5.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: pinkColor,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: ConstText(formatDuration(count.value), fontFamily: "SB", fontSize: 15.sp, color: whiteColor),
                      );
                    }),
                    InkWell(
                      onTap: toggleReset,
                      child: Container(
                        height: 42.w,
                        width: 42.w,
                        margin: EdgeInsets.only(bottom: 10.h, right: 20.w),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
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
                      Padding(
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
                      ),
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

                              /// CAMERA FLASH ON-OFF
                              InkWell(
                                onTap: toggleFlashLight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ConstSvg("assets/svg/flash.svg", width: 24.w, height: 24.w, color: isFlashOn.value ? pinkColor : blackColor),
                                    SizedBox(height: 3.h),
                                    ConstText('Flash', fontSize: 12.sp, fontFamily: "SB", color: isFlashOn.value ? pinkColor : blackColor),
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

                              /// RECORD VIDEO
                              InkWell(
                                onTap: toggleRecord,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ConstSvg("assets/svg/record.svg", width: 24.w, height: 24.w, color: isRecord.value ? pinkColor : blackColor),
                                    SizedBox(height: 3.h),
                                    ConstText(isRecord.value ? "Saved" : 'Record', fontSize: 12.sp, fontFamily: "SB", color: isRecord.value ? pinkColor : blackColor),
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
  }
}
