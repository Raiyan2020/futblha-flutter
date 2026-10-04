import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../../data/models/enums/db_boxes.dart';

class DbManager {
  static late Box<dynamic> box;

  DbManager._init();

  static Future<DbManager> init(HiveBoxes currentBox) async {
    var db = DbManager._init();
    box = await Hive.openBox(currentBox.name);
    return db;
  }

  Future<void> add(dynamic id, Map value) async {
    //return box.add(value);
    return box.put(id, value);
  }

  Future<void> editById(dynamic id, Map<String, dynamic> value) {
    return box.put(id, value);
  }

  Future<void> editAll(dynamic value) {
    return box.putAll(value);
  }

  Future<void> removeById(dynamic id) async {
    return box.delete(id);
  }

  Future<dynamic> getById(dynamic id) async {
    return parser(box.get(id));
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final list = List<Map<dynamic, dynamic>>.from(box.values);
    return list.map((e) => parser(e)).toList(); //convert from dynamic to string
  }

  Future<int> removeAll() async {
    return box.clear();
  }
}

Map<String, dynamic> parser(dynamic hiveMap) {
  final jsonString = jsonEncode(hiveMap);
  return jsonDecode(jsonString);
}
