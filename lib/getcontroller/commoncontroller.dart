import 'dart:convert';

import 'package:drawing_sketch/ads/ads.dart';
import 'package:drawing_sketch/constant/constant.dart';
import 'package:drawing_sketch/localization/languages.dart';
import 'package:drawing_sketch/storages/storages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CommonController extends GetxController with WidgetsBindingObserver {
  final RxList categories = [].obs;
  final RxInt selectedIndex = 0.obs;

  @override
  Future<void> onInit() async {
    int index = AppLanguage.list.indexWhere((element) => element.languageCode == Storages.read<String>('languageCode'));
    if (!index.isNegative) {
      selectedIndex.value = index;
    }
    await getAllCategory;
    super.onInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      OverlayStyle.dark;
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> get getAllCategory async {
    categories.clear();
    final response = await http.get(Uri.parse(categoriesApi));
    if (kDebugMode) {
      print('HELLO API RESPONSE cat_list [${response.statusCode}]');
    }
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      categories.addAll(json['DRAW']);
    }
  }

  Future<List> getSingleCategory({required String cid}) async {
    final body = {"data": '{"method_name":"cat_iteams","cat_id":"$cid"}'};
    final response = await http.post(Uri.parse(url), body: body);
    if (kDebugMode) {
      print('HELLO API RESPONSE cat_iteams CID [$cid] ===> [${response.statusCode}]');
    }
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['DRAW'];
    }
    return [];
  }
}
