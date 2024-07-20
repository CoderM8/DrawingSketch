import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/permission/trackingpermission.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/ui/bottombar/bottombar.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _initAds();
    Future.delayed(const Duration(seconds: 3), () async {
      Storages.writeIfNull('Attempt', {"date": DateTime.now().microsecondsSinceEpoch, 'count': 0});
      final attempt = Storages.read('Attempt');
      final DateTime date = DateTime.fromMicrosecondsSinceEpoch(attempt['date']);
      final DateTime initDate = DateTime(date.year, date.month, date.day);
      final DateTime now = DateTime.now();
      final bool isPast = initDate.isBefore(DateTime(now.year, now.month, now.day));
      print('attempt date isPast $isPast $attempt');
      if (isPast) {
        Storages.write('Attempt', {"date": DateTime.now().microsecondsSinceEpoch, 'count': 0});
      }

      /// CHECK USER IS NEW OR OLD IN APP
      Get.off(() => Storages.read<bool>('new') == true ? const TrackingPermission() : BottomBar());
    });
    super.initState();
  }

  /// MOBILE ADS SDK INITIALIZE
  Future<void> _initAds() async {
    await ApplovinAds.initAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/png/SplashScreen.png"),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 222.h),
            Center(child: Image.asset("assets/png/splash.png", height: 246.h, width: 330.w)),
            SizedBox(height: 63.h),
            ConstText('AR Draw', fontSize: 37.sp, fontFamily: 'EB', color: blackColor),
            ConstText('SketchMagic', fontSize: 17.sp, color: blackColor, letterSpacing: 4),
            SizedBox(height: 137.h),
            Lottie.asset("assets/lottie/loader.json")
          ],
        ),
      ),
    );
  }
}
