import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/constant/extension.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/widgets/button.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonPermission extends StatefulWidget {
  const CommonPermission({super.key});

  @override
  State<CommonPermission> createState() => _CommonPermissionState();
}

class _CommonPermissionState extends State<CommonPermission> {
  final RxBool camera = false.obs;
  final RxBool microphone = false.obs;
  final RxBool tracking = false.obs;

  @override
  void initState() {
    permissionStatus();
    super.initState();
  }

  void permissionStatus() async {
    final PermissionStatus cameraStatus = await Permission.camera.status;
    final PermissionStatus microphoneStatus = await Permission.microphone.status;
    final TrackingStatus trackingStatus = await AppTrackingTransparency.trackingAuthorizationStatus;

    camera.value = cameraStatus.isGranted;
    microphone.value = microphoneStatus.isGranted;
    tracking.value = trackingStatus == TrackingStatus.authorized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ConstText("App ${"permission_needed".tr}", fontFamily: 'B'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset("assets/png/camera_permission.png", color: blackColor, height: 25.w, width: 25.w),
                  title: ConstText("Camera", fontFamily: 'M', fontSize: 16.sp, textAlign: TextAlign.start),
                  onTap: () async {
                    if (!camera.value) {
                      camera.value = await Apis.requestPermission(context, type: PerType.Camera);
                    }
                  },
                  trailing: Obx(() {
                    if (camera.value) {
                      return ConstSvg("assets/svg/done.svg", height: 23.w, width: 23.w);
                    } else {
                      return Icon(Icons.radio_button_unchecked, color: blackColor, size: 25.h);
                    }
                  }),
                ),
                SizedBox(height: 5.h),
                ListTile(
                  leading: Image.asset("assets/png/microphone_permission.png", color: blackColor, height: 25.w, width: 25.w),
                  title: ConstText("Microphone", fontFamily: 'M', fontSize: 16.sp, textAlign: TextAlign.start),
                  onTap: () async {
                    if (!microphone.value) {
                      microphone.value = await Apis.requestPermission(context, type: PerType.Microphone);
                    }
                  },
                  trailing: Obx(() {
                    if (microphone.value) {
                      return ConstSvg("assets/svg/done.svg", height: 23.w, width: 23.w);
                    } else {
                      return Icon(Icons.radio_button_unchecked, color: blackColor, size: 25.h);
                    }
                  }),
                ),
                SizedBox(height: 5.h),
                ListTile(
                  leading: Image.asset("assets/png/tracking_permission.png", color: blackColor, height: 25.w, width: 25.w),
                  title: ConstText("Tracking", fontFamily: 'M', fontSize: 16.sp, textAlign: TextAlign.start),
                  onTap: () async {
                    if (!tracking.value) {
                      tracking.value = await Apis.requestPermission(context, type: PerType.Tracking);
                    }
                  },
                  trailing: Obx(() {
                    if (tracking.value) {
                      return ConstSvg("assets/svg/done.svg", height: 23.w, width: 23.w);
                    } else {
                      return Icon(Icons.radio_button_unchecked, color: blackColor, size: 25.h);
                    }
                  }),
                ),
              ],
            ),
          ),
          Spacer(),
          ConstButton(
            height: 56.w,
            text: "Continue",
            onTap: () {
              Get.back();
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
