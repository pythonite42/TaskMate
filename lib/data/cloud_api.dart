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
  //This is because I use a fake backend for testing and it does not actually change anything
  //this of course leads to a reset of the changes whenever the data is reloaded

  Future<void> upsert(ToDo todo) async {
    //since it is easier in the rest of the code to not distinguish between insert and update, I try patch first and if that fails I do a post
    //this is not perfect because if the patch fails for another reason than "not found", I would still do a post
    //If the backend were giving proper status codes (e.g. 404 for not found) I could check for that
    //but jsonplaceholder always returns 200
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
