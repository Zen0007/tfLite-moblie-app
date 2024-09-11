import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:responsibel/data/data_results.dart';

Future<List<Results>> dataFetch(
    {required String name, required String start, required String end}) async {
  List<Results> dataResults = [];
  final String url =
      "https://api.polygon.io/v2/aggs/ticker/$name/range/1/day/${start.substring(0, 10)}/${end.substring(0, 10)}?adjusted=false&sort=desc&apiKey=3Nq8xQxfTb8xwIWUhGtaXbqhQUL_OHn4";
  final client = http.Client();
  try {
    var response = await _retryData(() => client.get(Uri.parse(url)));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> temData = data['results'];
      print("${temData[0]['o']}       temData");
      dataResults = temData.map((json) => Results.fromJson(json)).toList();
    } else {
      print("${response.statusCode} --------------------------status");
      return [];
    }
  } catch (e, strackTrace) {
    print(e);
    print(strackTrace);
  } finally {
    client.close();
  }
  return dataResults;
}

Future<http.Response> _retryData(Future<http.Response> Function() url,
    [int retries = 3]) async {
  int attempt = 0;
  while (true) {
    try {
      final response = await url();
      return response;
    } catch (e, strackTrace) {
      attempt++;
      if (attempt >= retries) {
        rethrow;
      }
      await Future.delayed(Duration(seconds: 2 * attempt));
      print(e);
      print(strackTrace);
    }
  }
}
