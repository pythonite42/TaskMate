import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/data/todo_model.dart';

class LocalStore {
  static const _key = 'todos';

  Future<List<ToDo>> getData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_key);
    if (rawData == null) return [];
    final list = (jsonDecode(rawData) as List).cast<Map<String, dynamic>>();
    return list.map(ToDo.fromJson).toList();
  }

  Future<void> setData(List<ToDo> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((entry) => entry.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
