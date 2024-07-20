import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  ///init database
  static initDatabase() async {
    Directory? documentDirectory;
    if (Platform.isAndroid) {
      documentDirectory = await getExternalStorageDirectory();
    } else {
      documentDirectory = await getApplicationDocumentsDirectory();
    }
    String path = join(documentDirectory!.path, 'drawing.db');
    final db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  static _onCreate(Database db, int version) async {
    ///create database
    await db.execute('CREATE TABLE ${VideoModel.table} (Id INTEGER PRIMARY KEY autoincrement,createdAt TEXT,image TEXT,path TEXT,system TEXT,type TEXT)');
    await db.execute('CREATE TABLE ${FavouriteModel.table} (Id INTEGER PRIMARY KEY autoincrement,createdAt TEXT,image TEXT,title TEXT,aid TEXT,cid TEXT,type TEXT)');
    if (kDebugMode) {
      print('::::Table Create::::');
    }
  }

  /// ---------- VIDEO ----------- ///
  /// ADD
  static Future<int> addVideo(VideoModel diary) async {
    final db = await database;
    return await db!.insert(VideoModel.table, diary.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// REMOVE
  static Future<int> removeVideo(int id) async {
    final db = await database;
    return await db!.delete(VideoModel.table, where: 'Id = ?', whereArgs: [id]);
  }

  /// GET ALL
  static Future<List<VideoModel>> getMyVideoByDate() async {
    final db = await database;
    List<Map> maps = await db!.query(VideoModel.table, orderBy: 'createdAt DESC');
    List<VideoModel> myList = [];
    if (maps.isNotEmpty) {
      for (final element in maps) {
        myList.add(VideoModel.fromMap(element));
      }
    }
    return myList;
  }

  /// ---------- FAVOURITE ----------- ///
  /// ADD
  static Future<int> addFavourite(FavouriteModel fav) async {
    final db = await database;
    return await db!.insert(FavouriteModel.table, fav.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// REMOVE
  static Future<int> removeFavourite(String aid) async {
    final db = await database;
    return await db!.delete(FavouriteModel.table, where: 'aid = ?', whereArgs: [aid]);
  }

  /// CHECK ALREADY ADDED
  static Future<bool> isFavourite(String aid) async {
    final db = await database;
    List<Map> maps = await db!.query(FavouriteModel.table, where: 'aid = ?', whereArgs: [aid]);
    return maps.isNotEmpty;
  }

  static Future<List<FavouriteModel>> getAllFavourite() async {
    final db = await database;
    List<Map> maps = await db!.query(FavouriteModel.table, orderBy: 'createdAt DESC');
    List<FavouriteModel> myList = [];
    if (maps.isNotEmpty) {
      for (final element in maps) {
        myList.add(FavouriteModel.fromMap(element));
      }
    }
    return myList;
  }
}

class VideoModel {
  static const String table = "MyVideo";
  final int? id;
  final String createdAt;
  final String path;
  final String image;
  final String system;
  final String type;

  VideoModel({this.id, required this.createdAt, required this.image, required this.path, required this.system, required this.type});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'Id': id, 'createdAt': createdAt, 'image': image, 'path': path, 'system': system, 'type': type};
  }

  factory VideoModel.fromMap(Map<dynamic, dynamic> map) {
    return VideoModel(id: map['Id'], createdAt: map['createdAt'], image: map['image'], path: map['path'], system: map['system'], type: map['type']);
  }
}

class FavouriteModel {
  static const String table = "Favourite";
  final int? id;
  final String createdAt;
  final String title;
  final String image;
  final String cid;
  final String aid;
  final String type;

  FavouriteModel({this.id, required this.createdAt, required this.image, required this.title, required this.cid, required this.aid, required this.type});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'Id': id, 'createdAt': createdAt, 'image': image, 'title': title, 'cid': cid, 'aid': aid, 'type': type};
  }

  factory FavouriteModel.fromMap(Map<dynamic, dynamic> map) {
    return FavouriteModel(id: map['Id'], createdAt: map['createdAt'], image: map['image'], title: map['title'], aid: map['aid'], cid: map['cid'], type: map['type']);
  }
}
