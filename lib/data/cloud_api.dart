import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:task_mate/data/todo_model.dart';

class CloudApi {
  Uri url = Uri.parse(
    dotenv.env['DATA_URL'] ?? '',
  ); //The URL for the endpoint should not be hardcoded and then pushed to git. For this to work there needs to be a file called .env at the root of the project, with this content: DATA_URL=https://myPlaceholder.com

  Future<List<ToDo>> getData() async {
    final response = await http.get(url, headers: {'Accept': 'application/json', 'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Fetch failed ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as List;
    return decoded.map((entry) => ToDo.fromJson(Map<String, dynamic>.from(entry))).toList();
  }

  Future<void> upsert(ToDo todo) async {
    final response = await http.put(
      url.resolve('/${todo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()..remove('pending')),
    );
    if (response.statusCode >= 300) throw Exception('Upsert failed ${response.statusCode}');
  }

  Future<void> delete(int id) async {
    final response = await http.delete(url.resolve('/$id'));
    if (response.statusCode >= 300) throw Exception('Delete failed ${response.statusCode}');
  }
}
