import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stories_for_kids/models/dictionary_model.dart';

Future<List<Meaning>> fetchMeanings(String word) async {
  final url =
      Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$word");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List jsonData = json.decode(response.body);
    return (jsonData.first['meanings'] as List)
        .map((json) => Meaning.fromJson(json))
        .toList();
  } else {
    throw Exception("Failed to load meanings");
  }
}
