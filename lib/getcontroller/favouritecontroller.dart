import 'package:drawing_sketch/storages/sqflite.dart';
import 'package:get/get.dart';

class FavouriteController extends GetxController {
  final RxList<FavouriteModel> videoList = <FavouriteModel>[].obs;

  @override
  Future<void> onInit() async {
    await DatabaseHelper.getAllFavourite().then((list) {
      if (list.isNotEmpty) {
        videoList.addAll(list);
      }
    });
    super.onInit();
  }
}
