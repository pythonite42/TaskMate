import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:task_mate/data/todo_model.dart';

class CloudApi {
  String url = dotenv.env['DATA_URL'] ?? '';
  //The URL for the endpoint should not be hardcoded and then pushed to git. For this to work there needs to be a file called .env at the root of the project, with this content: DATA_URL=https://myPlaceholder.com

  Future<List<ToDo>> getData() async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Fetch failed ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as List;
    return decoded.map((entry) => ToDo.fromJson(Map<String, dynamic>.from(entry))).toList();
  }

  //for upsert and delete I get status code 200 but the backend is not actually changed.
  //Maybe this is a wanted behaviour or the backend is setup wrong
  //this of course leads to a reset of the changes whenever the data is reloaded

  Future<void> upsert(ToDo todo) async {
    var newUrl = Uri.parse('$url/${todo.id}');
    final responsePatch = await http.patch(
      newUrl,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()..remove('pending')),
    );
    if (responsePatch.statusCode >= 300) {
      final responsePost = await http.post(
        newUrl,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode(todo.toJson()..remove('pending')),
      );
      if (responsePost.statusCode >= 300) throw Exception('Upsert failed ${responsePost.statusCode}');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$url/$id'));
    if (response.statusCode >= 300) throw Exception('Delete failed ${response.statusCode}');
  }
}
