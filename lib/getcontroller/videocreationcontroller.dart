import 'package:drawing_sketch/storages/sqflite.dart';
import 'package:get/get.dart';

class CreationController extends GetxController {
  final RxBool isSelectedAll = false.obs;
  final RxList deleteMulti = [].obs;
  final RxList<VideoModel> videoList = <VideoModel>[].obs;

  @override
  Future<void> onInit() async {
    await DatabaseHelper.getMyVideoByDate().then((list) {
      if (list.isNotEmpty) {
        videoList.addAll(list);
      }
    });
    super.onInit();
  }
}
