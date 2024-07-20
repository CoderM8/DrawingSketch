import 'dart:convert';
import 'dart:io';

import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/ui/bottombar/bottombar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:http/http.dart' as http;

/// RETURN [TRUE] IF PLAN ACTIVATED
final RxBool isSubscribe = false.obs;

class Config {
  static final RxList<StoreProduct> products = <StoreProduct>[].obs;
  static final RxBool isPurchasing = false.obs;
  static final RxBool isLoadPlan = false.obs;

  /// STATIC PURCHASE KEY
  static const appleApiKey = 'appl_rWajqXlxSJkvqzCPkKmokqdARxL';
  static const googleApiKey = '';
  static const entitlementKey = 'pro';

  static String get apiKey {
    if (Platform.isAndroid) {
      return googleApiKey;
    } else if (Platform.isIOS) {
      return appleApiKey;
    } else {
      return "Unsupported Platform ${Platform.operatingSystem}";
    }
  }

  /// CONFIGURE REVENUE SDK
  /// INITIALIZE PURCHASE
  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.error);
    await Purchases.configure(PurchasesConfiguration(apiKey));
    await Purchases.enableAdServicesAttributionTokenCollection();
  }

  /// GET ALL PRODUCT
  static Future<void> getAllProducts() async {
    try {
      products.clear();
      isLoadPlan.value = true;
      final response = await http.get(Uri.parse(subscription));
      if (kDebugMode) {
        print('HELLO API RESPONSE get_subscription [${response.statusCode}]');
      }
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List draw = List.from(json['DRAW']);
        if (draw.isNotEmpty) {
          List<String> subIds = [];
          List<String> purIds = [];
          for (final element in draw) {
            /// consumable A Type for subscriptions.
            if (element['Type'] == "subscription") {
              if (Platform.isAndroid) {
                subIds.add(element['Android']);
              } else if (Platform.isIOS) {
                subIds.add(element['IOS']);
              }
            }

            /// non-consumable A Type for in-app products.
            else if (element['Type'] == "nonSubscription") {
              if (Platform.isAndroid) {
                purIds.add(element['Android']);
              } else if (Platform.isIOS) {
                purIds.add(element['IOS']);
              }
            }
          }
          if (subIds.isNotEmpty) {
            final items = await Purchases.getProducts(subIds, productCategory: ProductCategory.subscription);
            for (final key in items) {
              products.add(key);
            }
          }
          if (purIds.isNotEmpty) {
            final items = await Purchases.getProducts(purIds, productCategory: ProductCategory.nonSubscription);
            for (final key in items) {
              products.add(key);
            }
          }
          products.sort((a, b) => a.price.compareTo(b.price));
        }
      }
      isLoadPlan.value = false;
      if (kDebugMode) {
        print('HELLO PURCHASE INITIALIZE storeProduct ${products.length}');
      }
    } on PlatformException catch (e) {
      isLoadPlan.value = false;
      if (kDebugMode) {
        print('HELLO PURCHASE INITIALIZE ERROR [${e.code}] ${e.message}');
      }
    }
  }

  /// GET USER ACTIVE SUBSCRIPTION DATA
  static Future<void> getActiveSubscription() async {
    isPurchasing.value = false;
    isPurchasing.value = true;
    final CustomerInfo info = await Purchases.getCustomerInfo();
    final bool isPro = info.entitlements.active.containsKey(entitlementKey);
    final bool isActive = info.activeSubscriptions.isNotEmpty || info.nonSubscriptionTransactions.isNotEmpty;
    if (kDebugMode) {
      print('HELLO PURCHASE GET isActive $isActive isPro $isPro sub ${info.activeSubscriptions} inApp ${info.nonSubscriptionTransactions} entitlements ${info.entitlements.active}');
    }
    isSubscribe.value = (isActive && isPro);
    isPurchasing.value = false;
    if (kDebugMode) {
      print('HELLO PURCHASE GET isSubscribe $isSubscribe');
    }
  }

  /// RESTORE PURCHASE
  static Future<void> restoreSubscription() async {
    try {
      isPurchasing.value = false;
      isPurchasing.value = true;
      final CustomerInfo info = await Purchases.restorePurchases();
      final bool isPro = info.entitlements.active.containsKey(entitlementKey);
      final bool isActive = info.activeSubscriptions.isNotEmpty || info.nonSubscriptionTransactions.isNotEmpty;
      if (kDebugMode) {
        print('HELLO PURCHASE RESTORE ACTIVE isActive $isActive isPro $isPro sub ${info.activeSubscriptions} inApp ${info.nonSubscriptionTransactions} entitlements ${info.entitlements.active}');
      }
      isSubscribe.value = (isActive && isPro);
    } on PlatformException catch (e) {
      isPurchasing.value = false;
      if (kDebugMode) {
        print('HELLO PURCHASE RESTORE ERROR [${e.code}] ${e.message}');
      }
    }
    isPurchasing.value = false;
    if (kDebugMode) {
      print('HELLO PURCHASE RESTORE isSubscribe $isSubscribe');
    }
  }

  /// BUY SUBSCRIPTION PLAN
  static Future<void> buySubscription(context, {required StoreProduct item, bool isVisit = false}) async {
    try {
      isPurchasing.value = false;
      isPurchasing.value = true;
      final CustomerInfo information = await Purchases.restorePurchases();
      final bool isProRestore = information.entitlements.active.containsKey(entitlementKey);
      final bool isActiveRestore = information.activeSubscriptions.isNotEmpty || information.nonSubscriptionTransactions.isNotEmpty;

      if (!isProRestore && !isActiveRestore) {
        final CustomerInfo info = await Purchases.purchaseStoreProduct(item);
        final bool isPro = info.entitlements.active.containsKey(entitlementKey);
        final bool isActive = info.activeSubscriptions.isNotEmpty || info.nonSubscriptionTransactions.isNotEmpty;
        if (kDebugMode) {
          print('HELLO PURCHASE BUY isActive $isActive isPro $isPro sub ${info.activeSubscriptions} inApp ${info.nonSubscriptionTransactions} entitlements ${info.entitlements.active} ');
        }
        isSubscribe.value = (isActive && isPro);
      } else {
        isSubscribe.value = (isActiveRestore && isProRestore);
      }
      if (isVisit) {
        Get.off(() => BottomBar());
      } else {
        Get.back();
      }
    } on PlatformException catch (e) {
      isPurchasing.value = false;
      Apis.constSnack(context, e.message.toString());
      if (kDebugMode) {
        print('HELLO PURCHASE BUY ERROR [${e.code}] ${e.message}');
      }
      if (e.code == '6' || e.message == 'This product is already active for the user.') {
        await restoreSubscription();
      }
    }
    isPurchasing.value = false;
    if (kDebugMode) {
      print('HELLO PURCHASE BUY isSubscribe $isSubscribe');
    }
  }
}
