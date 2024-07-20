// ignore_for_file: avoid_print
import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/constant/constant.dart';
import 'package:drawing_sketch/localization/languages.dart';
import 'package:drawing_sketch/notification/local_notification_services.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:drawing_sketch/ui/starting/spalshscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  OverlayStyle.dark;

  /// INITIALIZE GET-STORAGE
  await Storages.init();

  /// INITIALIZE FIREBASE
  await Apis.initFirebase();

  /// APP-DETAILS API INITIALIZE
  await ApplovinAds.initAppDetails();

  /// INITIALIZE LOCAL NOTIFICATION FOR [IOS]
  await NotificationService.init();
  await NotificationService.cancelAllNotifications();

  /// INITIALIZE REVENUE SDK
  await Config.initialize();

  /// GET USER ACTIVE PLAN
  await Config.getActiveSubscription();

  runApp(const MyApp());
}

class MyApp extends GetView {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Apis.isTab(context) ? const Size(585, 812) : Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, widget) {
          return GetMaterialApp(
            title: 'AR Draw Trace - Sketch & Paint',
            debugShowCheckedModeBanner: false,

            /// LOCALIZATION APP CHANGE LANGUAGE
            translations: LanguagesTranslations(),
            locale: Locale(Storages.read('languageCode')),
            theme: ThemeData(
                useMaterial3: false,
                scaffoldBackgroundColor: bgColor,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                appBarTheme: AppBarTheme(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  toolbarHeight: 66.h,
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: blackColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.r), bottomRight: Radius.circular(20.r)),
                  ),
                ),
                fontFamily: "R",
                colorScheme: ColorScheme.fromSwatch().copyWith(secondary: pinkColor),
                listTileTheme: ListTileThemeData(
                  tileColor: whiteColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                sliderTheme: SliderThemeData(
                  thumbColor: pinkColor,
                  trackHeight: 2,
                  activeTrackColor: blackColor,
                  inactiveTrackColor: borderColor,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                )),
            home: const SplashScreen(),
          );
        });
  }
}

class CustomSliderTab extends SliderTrackShape with BaseSliderTrackShape {
  @override
  Rect getPreferredRect({required RenderBox parentBox, Offset offset = Offset.zero, required SliderThemeData sliderTheme, bool isEnabled = false, bool isDiscrete = false}) {
    return Rect.fromLTWH(offset.dx + 10.w, (parentBox.size.height - 4.w) / 2 + offset.dy, parentBox.size.width - 20.w, 4.w);
  }

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset thumbCenter,
      Offset? secondaryOffset,
      bool? isEnabled,
      bool? isDiscrete,
      required TextDirection textDirection}) {
    final trackRect = getPreferredRect(parentBox: parentBox, offset: offset, sliderTheme: sliderTheme, isEnabled: isEnabled!, isDiscrete: isDiscrete!);

    final gradient = LinearGradient(colors: [borderColor, blackColor]);

    final Paint paint = Paint()..shader = gradient.createShader(trackRect);
    context.canvas.drawRect(trackRect, paint);
  }
}
