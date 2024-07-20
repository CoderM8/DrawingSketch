import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/constant/extension.dart';
import 'package:drawing_sketch/firebase_options.dart';
import 'package:drawing_sketch/permission/camerapermission.dart';
import 'package:drawing_sketch/permission/commonpermission.dart';
import 'package:drawing_sketch/permission/microphonepermission.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/ui/starting/getstartscreen.dart';
import 'package:drawing_sketch/widgets/bottomsheet.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Apis {
  /// RESPONSIVE UI
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 600;
  }

  static bool isTab(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600 && MediaQuery.sizeOf(context).width < 2048;
  }

  /// CHANGE LANGUAGE
  static Future<void> changeLanguage(value) async {
    await Storages.write('languageCode', value);
    await Get.updateLocale(Locale(value));
  }

  /// PERMISSION
  static Future<bool> requestPermission(context, {required PerType type, bool isVisit = false}) async {
    switch (type) {
      case PerType.Camera:
        {
          PermissionStatus status = await Permission.camera.request();
          if (kDebugMode) {
            print('HELLO PERMISSION STATUS ${type.name} $status');
          }
          if (status.isPermanentlyDenied && !isVisit) {
            await showPermission(context, type: type);
          }
          if (isVisit) {
            Get.offAll(() => MicroPhonePermission());
          }
          return status.isGranted;
        }
      case PerType.Microphone:
        {
          PermissionStatus status = await Permission.microphone.request();
          if (kDebugMode) {
            print('HELLO PERMISSION STATUS ${type.name} $status');
          }
          if (status.isPermanentlyDenied && !isVisit) {
            await showPermission(context, type: type);
          }
          if (isVisit) {
            Get.offAll(() => GetStartScreen());
          }
          return status.isGranted;
        }
      case PerType.Tracking:
        {
          final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
          // If the system can show an authorization request dialog
          print('HELLO PERMISSION STATUS ${type.name} $status');
          if (status == TrackingStatus.notDetermined) {
            await AppTrackingTransparency.requestTrackingAuthorization();
          } else if (status == TrackingStatus.denied) {
            await showPermission(context, type: type);
          }
          if (status == TrackingStatus.authorized) {
            final uuid =  await AppTrackingTransparency.getAdvertisingIdentifier();

            print("uuid = $uuid");
          }
          if (isVisit) {
            Get.offAll(() => CameraPermission());
          }
          return status == TrackingStatus.authorized;
        }
    }
  }

  static Future<void> checkPermission() async {
    final PermissionStatus cameraStatus = await Permission.camera.status;
    final PermissionStatus microphoneStatus = await Permission.microphone.status;
    print('HELLO PERMISSION STATUS camera $cameraStatus');
    print('HELLO PERMISSION STATUS microphone $microphoneStatus');
    if ((cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) || (microphoneStatus.isDenied || microphoneStatus.isPermanentlyDenied)) {
      Get.to(() => CommonPermission());
    }
  }

  /// URL LAUNCHER
  static Future<void> lunchApp(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (kDebugMode) {
        print('FAILED TO LUNCH $url');
      }
    }
  }

  /// FIREBASE INITIALIZE
  static Future<void> initFirebase() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    /// automatically get breadcrumb logs to understand user actions leading up to a crash, non-fatal, or ANR event
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    /// This data can help you understand basic interactions, such as how many times your app was opened, and how many users were active in a chosen time period.
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }

  /// SHOW SNACK-BAR
  static void constSnack(context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: pinkColor, content: ConstText(msg, textAlign: TextAlign.start, color: whiteColor, fontFamily: "M", fontSize: 16.sp)),
    );
  }

  /// THUMBNAIL FROM FILE
  static Future<String?> fromFile(String url) async {
    String? file = await VideoThumbnail.thumbnailFile(video: url, imageFormat: ImageFormat.JPEG, maxHeight: 0, maxWidth: 0, quality: 100);
    return file;
  }

  /// PICK IMAGE FROM DEVICE
  static Future<String?> pickImage({ImageSource source = ImageSource.camera}) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return file.path;
    }
    return null;
  }

  /// CROP SELECTED IMAGE
  static Future<File?> cropImage({required String fileTest}) async {
    final ImageCropper cropper = ImageCropper();
    final croppedFile = await cropper.cropImage(
      sourcePath: fileTest,
      uiSettings: [IOSUiSettings(cancelButtonTitle: "Cancel".tr, doneButtonTitle: "Done".tr, aspectRatioPickerButtonHidden: true, title: "Preview".tr)],
    );
    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  /// EDIT TEXT STYLE CHANGE ALSO [texteditscreen.dart]
  static TextStyle style(int index, double fontSize, Color color) {
    switch (index) {
      case 0:
        {
          /// GoogleFonts.inter
          return TextStyle(fontFamily: "EB", fontSize: fontSize, color: color);
        }
      case 1:
        {
          /// GoogleFonts.parisienne
          return GoogleFonts.parisienne(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      case 2:
        {
          /// GoogleFonts.tiltNeon
          return GoogleFonts.tiltNeon(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      case 3:
        {
          /// GoogleFonts.bungeeSpice
          return GoogleFonts.bungeeSpice(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      case 4:
        {
          /// GoogleFonts.rye
          return GoogleFonts.rye(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      case 5:
        {
          /// GoogleFonts.rubikMonoOne
          return GoogleFonts.rubikMonoOne(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      case 6:
        {
          /// GoogleFonts.bungeeShade
          return GoogleFonts.bungeeShade(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      case 7:
        {
          /// GoogleFonts.alike
          return GoogleFonts.alike(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      case 8:
        {
          /// GoogleFonts.carterOne
          return GoogleFonts.carterOne(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      case 9:
        {
          /// GoogleFonts.protestGuerrilla
          return GoogleFonts.protestGuerrilla(fontSize: fontSize, color: color, fontWeight: FontWeight.bold);
        }
      default:
        return TextStyle(fontFamily: "EB", fontSize: fontSize, color: color);
    }
  }

  /// SORT LIST BY DATE
  static Map<T, List<S>> groupByDateList<S, T>(Iterable<S> values, T Function(S) key) {
    var map = <T, List<S>>{};
    for (var element in values) {
      (map[key(element)] ??= []).add(element);
    }
    return map;
  }

  /// DATE TIME
  static String getWhen({required DateTime date, String? format}) {
    DateTime now = DateTime.now();
    String when;
    if (date.day == now.day) {
      when = 'Today';
    } else if (date.day == now.subtract(const Duration(days: 1)).day) {
      when = 'Yesterday';
    } else {
      when = DateFormat(format ?? 'dd-MMM-y').format(date);
    }
    return when;
  }
}
