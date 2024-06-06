import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

mixin LocalDatabase {
  static late Isar? isar;
  Isar? get instance => isar;

  static late Box? hive;
  Box? get hiveInstance => hive;

  static Future<void> init() async {
    try {
      if (Isar.instanceNames.isNotEmpty) return;

      hive = await openHive();
      isar = await openIsar();
    } on Exception catch (e, stacktrace) {
      unawaited(Logger.e('Init local failed: $e', stackTrace: stacktrace));
    }
  }

  static Future<Isar> openIsar() async {
    final appDir = await getApplicationDocumentsDirectory();
    final isarDir = Directory('${appDir.path}/isar');
    await isarDir.create(recursive: true);

    final isar = await Isar.open(
      [
        // Models
      ],
      directory: isarDir.path,
    );

    return isar;
  }

  static Future<Box> openHive() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init('${appDir.path}/ai_analyzer_hive')
    // ..registerAdapter(PersonAdapter())
        ;

    // return Hive.openBox<Map<String, dynamic>>('ai_analyzer');
    return Hive.openBox('ai_analyzer');
  }

  static Future clearDatabase() async {
    await isar?.writeTxn<void>(() async {
    });

    await hive?.clear();
  }

  static Future<bool?> dispose() async => isar?.close();

  Map<String, dynamic>? getHiveDataAsMap(String key) {
    final cache = hiveInstance?.get(key);
    if (cache == null) {
      return null;
    }

    final encode = jsonEncode(cache);
    return jsonDecode(encode);
  }

  Iterable? getHiveDataAsList(String key) {
    final result = hiveInstance?.get(key);
    if (result == null) {
      return null;
    }

    final Iterable jsonList = jsonDecode(result);
    return jsonList;
  }

  Future<void> setHiveDataList(String key, List data) async {
    final jsonList = data.map((item) => item.toJson()).toList();
    await hiveInstance?.put(key, jsonEncode(jsonList));
  }
}

abstract class BaseLocalDatabase<T> {
  Stream<List<T>> listenDb() {
    throw UnimplementedError('listenDb $T');
  }

  Future<List<T>> getAll() {
    throw UnimplementedError('getAll $T');
  }

  Future<List<T>> gets({required int limit, required int offset}) {
    throw UnimplementedError('gets $T');
  }

  Future<T?> get(String id) {
    throw UnimplementedError('get $T');
  }

  Future<T?> getByKey(Id id) {
    throw UnimplementedError('getByKey $T');
  }

  Future<List<T>> filter() {
    throw UnimplementedError('filter $T');
  }

  Future<Id> insert(T model) {
    throw UnimplementedError('insert $T');
  }

  Future<T> insertModel(T model) async {
    throw UnimplementedError('insert $T');
  }

  Future<bool> insertAll(List<T> models) {
    throw UnimplementedError('insert $T');
  }

  Future<List<T>> insertAllModel(List<T> models) async {
    throw UnimplementedError('insert $T');
  }

  Future<Id> update(T model) {
    throw UnimplementedError('update $T');
  }

  Future<List<Id>> updateAll(List<T> models) {
    throw UnimplementedError('update $T');
  }

  ///Delete by key
  Future<bool> delete(int id) {
    throw UnimplementedError('delete $T');
  }
}
