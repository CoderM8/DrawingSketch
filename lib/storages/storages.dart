import 'package:get_storage/get_storage.dart';

class Storages {
  static Future<void> init() async {
    await GetStorage.init();
    box.writeIfNull('new', true);
    box.writeIfNull('languageCode', 'en');
  }

  static GetStorage box = GetStorage();

  /// Reads a value in your box with the given key.
  static T? read<T>(String key) {
    return box.read(key);
  }

  /// Write data on your box
  static Future<void> write(key, value) async {
    await box.write(key, value);
  }

  /// Write data on your box
  static Future<void> writeIfNull(key, value) async {
    await box.writeIfNull(key, value);
  }

  /// remove data from container by key
  static Future<void> remove(String key) async {
    await box.remove(key);
  }

  /// clear all data on your box
  static void get eraseAll async {
    await box.erase();
  }
}
