import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/data/todo_model.dart';

class LocalStore {
  static const _key = 'todos';

  Future<List<ToDo>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(ToDo.fromJson).toList();
  }

  Future<void> writeAll(List<ToDo> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
