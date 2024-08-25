import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsibel/data/data_results.dart';

Future<List<Results>> dataFetch(
    {required String name, required String start}) async {
  var response = await http.get(
    Uri.parse(
      "https://api.polygon.io/v2/aggs/ticker/$name/range/1/day/${start.substring(0, 10)}/2024-08-01?adjusted=false&sort=desc&apiKey=3Nq8xQxfTb8xwIWUhGtaXbqhQUL_OHn4",
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> temData = data['results'];
    print("${temData.length} len");
    return temData.map((json) => Results.fromJson(json)).toList();
  } else {
    throw Exception("data not found");
  }
}
