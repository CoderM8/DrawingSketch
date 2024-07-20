import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:drawing_sketch/editsection/previewscreen.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:drawing_sketch/subscription/config.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:applovin_max/applovin_max.dart';
import 'package:drawing_sketch/constant/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_id/flutter_device_id.dart';

String privacy = "";
String terms = "";
String appVersion = "";
final RxInt adLimit = 3.obs; // [adLimit] times user can show rewarded watching ad without premium

/// HIDE ADS FROM WHOLE APP [showAds] false
final RxBool showAds = false.obs;
const String url = "https://vocsyinfotech.in/vocsy/flutter/Drawing_app/api.php?";
const String appDetails = "${url}method_name=app_details";
const String categoriesApi = "${url}method_name=cat_list";
const String subscription = "${url}method_name=get_subscription";

String get shareApp {
  if (Platform.isAndroid) {
    return "https://play.google.com/store/apps/details?id=com.vocsy.drawingSketch";
  } else if (Platform.isIOS) {
    return "https://apps.apple.com/in/app/ar-draw-trace-sketch-paint/id6483211295";
  } else {
    return "Unsupported Platform ${Platform.operatingSystem}";
  }
}

String get rateApp {
  if (Platform.isAndroid) {
    return "https://play.google.com/store/apps/details?id=com.vocsy.drawingSketch";
  } else if (Platform.isIOS) {
    return "https://itunes.apple.com/app/id6483211295?action=write-review";
  } else {
    return "Unsupported Platform ${Platform.operatingSystem}";
  }
}

String get moreApp {
  if (Platform.isAndroid) {
    return "https://play.google.com/store/apps/details?id=com.vocsy.drawingSketch";
  } else if (Platform.isIOS) {
    return "https://apps.apple.com/us/developer/vinod-asodariya/id1470394345";
  } else {
    return "Unsupported Platform ${Platform.operatingSystem}";
  }
}

class ApplovinAds {
  // TODO:[ANDROID] add meta data ---> android/app/src/main/AndroidManifest.xml
  /*
       <meta-data android:name="applovin.sdk.key"
             android:value="APPLOVIN SDK KEY FROM MAX DASHBOARD"/>
         <!-- Sample AdMob app ID: ca-app-pub-3940256099942544~3347511713 -->
         <meta-data
             android:name="com.google.android.gms.ads.APPLICATION_ID"
             android:value="GOOGLE ADMOB APP ID"/>
 */

  /// applovin sdk key
  static late String _sdkKey;
  static final MaxNativeAdViewController maxNativeAdViewController = MaxNativeAdViewController();

  /// ad unit id
  static late String interstitialAdUnitId;
  static late String bannerAdUnitId;
  static late String rewardedAdUnitId;
  static late String nativeAdUnitId;

  static final int maxExponentialRetryCount = 6;

  /// Create states
  static int interstitialRetryAttempt = 0;
  static int rewardedAdRetryAttempt = 0;
  static bool isInitialized = false;

  static double mediaViewAspectRatio = 16 / 9;

  /// ONLY FOR BANNER ADS HIDE [isBanner] false
  static bool isBanner = false;

  /// ONLY FOR INTERSTITIAL ADS HIDE [isInterstitial] false
  static bool isInterstitial = false;

  /// ONLY FOR REWARDED ADS HIDE [isRewarded] false
  static bool isRewarded = false;

  /// ONLY FOR NATIVE ADS HIDE [isNative] false
  static bool isNative = false;

  /// get app-details data from php api
  static Future<void> initAppDetails() async {
    // NOTE: Platform messages are asynchronous, so we initialize in an async method.
    final response = await http.get(Uri.parse(appDetails));
    if (kDebugMode) {
      print('HELLO API RESPONSE app_details [${response.statusCode}]');
    }
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (List.from(json['DRAW']).isNotEmpty) {
        final draw = json['DRAW'][0];
        privacy = draw['app_privacy_policy'] ?? "";
        terms = draw['terms_condition'] ?? "";
        appVersion = draw['app_version'] ?? "";
        _sdkKey = draw['applovin_app_id'] ?? "";
        adLimit.value = draw['limit'] as int;
        showAds.value = (isSubscribe.value ? false : draw['showAds']);
        if (showAds.value) {
          isBanner = Platform.isIOS ? draw['banner_ios_status'] : draw['banner_android_status'];
          isInterstitial = Platform.isIOS ? draw['interstital_ios_status'] : draw['interstital_android_status'];
          isRewarded = Platform.isIOS ? draw['rewarded_ios_status'] : draw['rewarded_android_status'];
          isNative = Platform.isIOS ? draw['ios_native_id_status'] : draw['native_ad_status'];

          if (isBanner) {
            bannerAdUnitId = Platform.isIOS ? draw['applovin_banner_ios_id'] : draw['applovin_banner_android_id'];
          }

          if (isInterstitial) {
            interstitialAdUnitId = Platform.isIOS ? draw['applovin_interstital_ios_id'] : draw['applovin_interstital_android_id'];
          }

          if (isRewarded) {
            rewardedAdUnitId = Platform.isIOS ? draw['applovin_rewarded_ios_id'] : draw['applovin_rewarded_android_id'];
          }

          if (isNative) {
            nativeAdUnitId = Platform.isIOS ? draw['applovin_native_id_ios'] : draw['applovin_native_android_id'];
          }
        }
      }
    }
    if (kDebugMode) {
      print('HELLO ADS initAppDetails adLimit : $adLimit \nshowAds: $showAds\nisBannerShow: $isBanner\nisInterstitialShow: $isInterstitial\nisRewardedShow: $isRewarded\nisNativeShow: $isNative');
    }
  }

  /// initialize applovin ads sdk
  static Future<void> initAds() async {
    if (showAds.value) {
      print("ApplovinMAX SDK Initialized: key $_sdkKey");
      final MaxConfiguration? configuration = await AppLovinMAX.initialize(_sdkKey);
      if (configuration != null) {
        isInitialized = true;
        print("ApplovinMAX SDK Initialized: ${configuration.countryCode}");
      }
      if (isInitialized) {
        final String? advertisingId = await FlutterDeviceId().getDeviceId();
        print('Hello advertisingId $advertisingId');
        AppLovinMAX.setTestDeviceAdvertisingIds([advertisingId]);
        if (isInterstitial) {
          AppLovinMAX.loadInterstitial(interstitialAdUnitId);
        }
        if (isRewarded) {
          AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
        }
      }
      attachAdListeners();
    }
  }

  /// show banner applovin ads in app
  static Widget showBannerAds() {
    return Obx(() {
      isSubscribe.value;
      if (isBanner && !isSubscribe.value) {
        return MaxAdView(
          adUnitId: bannerAdUnitId,
          adFormat: AdFormat.banner,
          listener: AdViewAdListener(onAdLoadedCallback: (ad) {
            print('Banner widget ad loaded from ${ad.networkName}');
          }, onAdLoadFailedCallback: (adUnitId, error) {
            print('Banner widget ad failed to load with error code ${error.code} and message: ${error.message}');
          }, onAdClickedCallback: (ad) {
            print('Banner widget ad clicked');
          }, onAdExpandedCallback: (ad) {
            print('Banner widget ad expanded');
          }, onAdCollapsedCallback: (ad) {
            print('Banner widget ad collapsed');
          }, onAdRevenuePaidCallback: (ad) {
            print('Banner widget ad revenue paid: ${ad.revenue}');
          }),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  /// show interstital ads in app
  static Future<bool> showInterAds() async {
    if (isInterstitial && !isSubscribe.value) {
      final bool isReady = await AppLovinMAX.isInterstitialReady(interstitialAdUnitId) ?? false;
      if (isReady) {
        AppLovinMAX.showInterstitial(interstitialAdUnitId);
      } else {
        print('Loading interstitial ad...');
        AppLovinMAX.loadInterstitial(interstitialAdUnitId);
      }
      return isReady;
    }
    return false;
  }

  /// show rewarded ads in app
  static Future<bool> showRewardAds() async {
    if (isRewarded && !isSubscribe.value) {
      final bool isReady = await AppLovinMAX.isRewardedAdReady(rewardedAdUnitId) ?? false;
      if (isReady) {
        AppLovinMAX.showRewardedAd(rewardedAdUnitId);
      } else {
        print('Loading rewarded ad...');
        AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
      }
      return isReady;
    }
    return false;
  }

  /// show native ads in app and adjust height
  static Widget showNativeAds(double height) {
    return Obx(() {
      isSubscribe.value;
      if (isNative && !isSubscribe.value) {
        return Container(
          margin: const EdgeInsets.all(8.0),
          height: height,
          child: MaxNativeAdView(
            adUnitId: nativeAdUnitId,
            controller: maxNativeAdViewController,
            listener: NativeAdListener(onAdLoadedCallback: (ad) {
              print('Native ad loaded from ${ad.networkName}');
              mediaViewAspectRatio = ad.nativeAd?.mediaContentAspectRatio ?? 16 / 9;
            }, onAdLoadFailedCallback: (adUnitId, error) {
              print('Native ad failed to load with error code ${error.code} and message: ${error.message}');
            }, onAdClickedCallback: (ad) {
              print('Native ad clicked');
            }, onAdRevenuePaidCallback: (ad) {
              print('Native ad revenue paid: ${ad.revenue}');
            }),
            child: Container(
              color: const Color(0xffefefef),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        child: const MaxNativeAdIconView(width: 48, height: 48),
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MaxNativeAdTitleView(style: TextStyle(fontFamily: "B", fontSize: 16), maxLines: 1, overflow: TextOverflow.visible),
                            MaxNativeAdAdvertiserView(style: TextStyle(fontFamily: "M", fontSize: 10), maxLines: 1, overflow: TextOverflow.fade),
                            MaxNativeAdStarRatingView(size: 10),
                          ],
                        ),
                      ),
                      const MaxNativeAdOptionsView(width: 20, height: 20),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: MaxNativeAdBodyView(style: TextStyle(fontFamily: "M", fontSize: 14), maxLines: 3, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AspectRatio(aspectRatio: mediaViewAspectRatio, child: const MaxNativeAdMediaView()),
                  ),
                  const SizedBox(
                    width: double.infinity,
                    child: MaxNativeAdCallToActionView(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(pinkColor),
                        textStyle: WidgetStatePropertyAll<TextStyle>(TextStyle(fontSize: 15, fontFamily: "SB")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  /// applovin adk listener
  static void attachAdListeners() {
    /// Interstitial Ad Listeners
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialAdReady(_interstitial_ad_unit_id) will now return 'true'
        print('Interstitial ad loaded from ${ad.networkName}');

        // Reset retry attempt
        interstitialRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        interstitialRetryAttempt = interstitialRetryAttempt + 1;
        if (interstitialRetryAttempt > maxExponentialRetryCount) {
          print('Interstitial ad failed to load with code ${error.code}');
          return;
        }

        final int retryDelay = pow(2, min(maxExponentialRetryCount, interstitialRetryAttempt)).toInt();
        print('Interstitial ad failed to load with code ${error.code} - retrying in ${retryDelay}s');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          print('Interstitial ad retrying to load...');
          AppLovinMAX.loadInterstitial(interstitialAdUnitId);
        });
      },
      onAdDisplayedCallback: (ad) {
        print('Interstitial ad displayed');
      },
      onAdDisplayFailedCallback: (ad, error) {
        print('Interstitial ad failed to display with code ${error.code} and message ${error.message}');
      },
      onAdClickedCallback: (ad) {
        print('Interstitial ad clicked');
      },
      onAdHiddenCallback: (ad) {
        print('Interstitial ad hidden');
        AppLovinMAX.loadInterstitial(interstitialAdUnitId);
      },
      onAdRevenuePaidCallback: (ad) {
        print('Interstitial ad revenue paid: ${ad.revenue}');
      },
    ));

    /// Rewarded Ad Listeners
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
      onAdLoadedCallback: (ad) {
        // Rewarded ad is ready to be shown. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) will now return 'true'
        print('Rewarded ad loaded from ${ad.networkName}');

        // Reset retry attempt
        rewardedAdRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        // Rewarded ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        rewardedAdRetryAttempt = rewardedAdRetryAttempt + 1;
        if (rewardedAdRetryAttempt > maxExponentialRetryCount) {
          print('Rewarded ad failed to load with code ${error.code}');
          return;
        }

        final int retryDelay = pow(2, min(maxExponentialRetryCount, rewardedAdRetryAttempt)).toInt();
        print('Rewarded ad failed to load with code ${error.code} - retrying in ${retryDelay}s');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          print('Rewarded ad retrying to load...');
          AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
        });
      },
      onAdDisplayedCallback: (ad) {
        print('Rewarded ad displayed');
      },
      onAdDisplayFailedCallback: (ad, error) {
        print('Rewarded ad failed to display with code ${error.code} and message ${error.message}');
      },
      onAdClickedCallback: (ad) {
        print('Rewarded ad clicked');
      },
      onAdHiddenCallback: (ad) {
        print('Rewarded ad hidden');
        AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
        Get.to(() => PreviewScreen(url: Storages.read('url')));
      },
      onAdReceivedRewardCallback: (ad, reward) {
        print('Rewarded ad granted reward');
      },
      onAdRevenuePaidCallback: (ad) {
        print('Rewarded ad revenue paid: ${ad.revenue}');
      },
    ));

    /// Banner Ad Listeners
    AppLovinMAX.setBannerListener(AdViewAdListener(
      onAdLoadedCallback: (ad) {
        print('Banner ad loaded from ${ad.networkName}');
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        print('Banner ad failed to load with error code ${error.code} and message: ${error.message}');
      },
      onAdClickedCallback: (ad) {
        print('Banner ad clicked');
      },
      onAdExpandedCallback: (ad) {
        print('Banner ad expanded');
      },
      onAdCollapsedCallback: (ad) {
        print('Banner ad collapsed');
      },
      onAdRevenuePaidCallback: (ad) {
        print('Banner ad revenue paid: ${ad.revenue}');
      },
    ));

    /// MREC Ad Listeners
    AppLovinMAX.setMRecListener(AdViewAdListener(onAdLoadedCallback: (ad) {
      print('MREC ad loaded from ${ad.networkName}');
    }, onAdLoadFailedCallback: (adUnitId, error) {
      print('MREC ad failed to load with error code ${error.code} and message: ${error.message}');
    }, onAdClickedCallback: (ad) {
      print('MREC ad clicked');
    }, onAdExpandedCallback: (ad) {
      print('MREC ad expanded');
    }, onAdCollapsedCallback: (ad) {
      print('MREC ad collapsed');
    }, onAdRevenuePaidCallback: (ad) {
      print('MREC ad revenue paid: ${ad.revenue}');
    }));
  }
}

// TODO: easy ads old code
// String? googleAppId;
// String? facebookAppId;
//
// String? googleBanner;
// String? facebookBanner;
//
// String? googleInterstitial;
// String? facebookInterstitial;
//
// String? googleRewarded;
// String? facebookRewarded;

// /// HIDE ADS FROM WHOLE APP [showAds] false
// bool showAds = false;
//
// /// ONLY FOR BANNER ADS HIDE [isBanner] false
// bool isBanner = false;
//
// /// ONLY FOR INTERSTITIAL ADS HIDE [isInterstitial] false
// bool isInterstitial = false;
//
// /// ONLY FOR REWARDED ADS HIDE [isRewarded] false
// bool isRewarded = false;
//
// Future<void> fetchAds() async {
//   final response = await http.get(Uri.parse(appDetails));
//   if (kDebugMode) {
//     print('HELLO API RESPONSE app_details [${response.statusCode}]');
//   }
//   if (response.statusCode == 200) {
//     final json = jsonDecode(response.body);
//     if (List.from(json['DRAW']).isNotEmpty) {
//       final draw = json['DRAW'][0];
//       privacy = draw['app_privacy_policy'] ?? "";
//       terms = draw['terms_condition'] ?? "";
//       appVersion = draw['app_version'] ?? "";
//       showAds = (isSubscribe.value ? false : draw['showAds']);
//       if (showAds) {
//         googleAppId = draw['google_app_id'];
//         facebookAppId = draw['facebook_app_id'];
//
//         isBanner = Platform.isIOS ? draw['banner_ios_status'] : draw['banner_android_status'];
//         isInterstitial = Platform.isIOS ? draw['interstital_ios_status'] : draw['interstital_android_status'];
//         isRewarded = Platform.isIOS ? draw['rewarded_ios_status'] : draw['rewarded_android_status'];
//
//         if (isBanner) {
//           googleBanner = Platform.isIOS ? draw['google_banner_ios_id'] : draw['google_banner_android_id'];
//           facebookBanner = Platform.isIOS ? draw['facebook_banner_ios_id'] : draw['facebook_banner_android_id'];
//         }
//
//         if (isInterstitial) {
//           googleInterstitial = Platform.isIOS ? draw['google_interstital_ios_id'] : draw['google_interstital_android_id'];
//           facebookInterstitial = Platform.isIOS ? draw['facebook_interstital_ios_id'] : draw['facebook_interstital_android_id'];
//         }
//
//         if (isRewarded) {
//           googleRewarded = Platform.isIOS ? draw['google_rewarded_ios_id'] : draw['google_rewarded_android_id'];
//           facebookRewarded = Platform.isIOS ? draw['facebook_rewarded_ios_id'] : draw['facebook_rewarded_android_id'];
//         }
//       } else {
//         isInterstitial = false;
//         isBanner = false;
//         isRewarded = false;
//       }
//     }
//   }
//   if (kDebugMode) {
//     print('HELLO ADS showAds : $showAds\nisBanner : $isBanner\nisInterstitial : $isInterstitial\n isRewarded : $isRewarded');
//   }
//
//   if (showAds) {
//     final String deviceId = await FlutterDeviceId().getDeviceId() ?? '';
//     print("DEVICE ID  $deviceId");
//     EasyAds.instance.initialize(
//       isShowAppOpenOnAppStateChange: false,
//       AdsTestAdIdManager(),
//       adMobAdRequest: const AdRequest(),
//       admobConfiguration: RequestConfiguration(testDeviceIds: [deviceId]),
//       fbTestMode: true,
//       showAdBadge: Platform.isIOS,
//       fbiOSAdvertiserTrackingEnabled: true,
//     );
//   }
// }

/// Banner Ads
// Widget bannerAds() {
//   return Obx(() {
//     isSubscribe.value;
//     if (isBanner && !isSubscribe.value) {
//       return EasySmartBannerAd(priorityAdNetworks: [AdNetwork.facebook, AdNetwork.admob], adSize: AdSize.banner);
//     } else {
//       return SizedBox.shrink();
//     }
//   });
// }

/// Interstitial & Rewarded Ads
// void showAd(AdUnitType adUnitType) {
//   if (adUnitType == AdUnitType.interstitial && isInterstitial && !isSubscribe.value) {
//     if (EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.facebook)) {
//       print('${adUnitType.name} loaded');
//     } else
//       EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.admob);
//   } else if (adUnitType == AdUnitType.rewarded && isRewarded && !isSubscribe.value) {
//     if (EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.facebook)) {
//       print('${adUnitType.name} loaded');
//     } else
//       EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.admob);
//   }
// }
//
// class AdsTestAdIdManager extends IAdIdManager {
//   AdsTestAdIdManager();
//
//   @override
//   AppAdIds? get fbAdIds => AppAdIds(appId: facebookAppId!, bannerId: facebookBanner, interstitialId: facebookInterstitial, rewardedId: facebookRewarded);
//
//   ///ca-app-pub-1031554205279977/5797983866
//   @override
//   AppAdIds? get admobAdIds => AppAdIds(appId: googleAppId!, bannerId: googleBanner, interstitialId: googleInterstitial, rewardedId: googleRewarded);
//
//   @override
//   AppAdIds? get unityAdIds => null;
//
//   @override
//   AppAdIds? get appLovinAdIds => null;
// }
