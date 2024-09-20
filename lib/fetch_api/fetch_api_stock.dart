import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:responsibel/data/data_results.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:http/http.dart' as http;

Future<List<Results>> dataFetch(
    {required String name, required String start, required String end}) async {
  List<Results> dataResults = [];
  try {
    final String url =
        "https://api.polygon.io/v2/aggs/ticker/$name/range/1/day/${start.substring(0, 10)}/${end.substring(0, 10)}?adjusted=true&sort=asc&apiKey=MZvutjZELI0FrlPO8c_SlSPdU4KXHQKY";

    // "https://api.polygon.io/v2/aggs/ticker/$name/range/1/day/${start.substring(0, 10)}/${end.substring(0, 10)}?adjusted=false&sort=desc&apiKey=3Nq8xQxfTb8xwIWUhGtaXbqhQUL_OHn4";

    final getApi = http.Client();
    var response = await getApi.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> temData = data['results'];
      dataResults = temData.map((json) => Results.fromJson(json)).toList();
    } else {
      print("${response.statusCode} --------------------------status");
      return [];
    }
  } catch (e, strackTrace) {
    print(e);
    print(strackTrace);
  }
  return dataResults;
}

Future<Response> _retryData(Future<Response> Function() url,
    [int retries = 3]) async {
  int attempt = 0;
  while (true) {
    try {
      final response = await url();
      return response;
    } on DioException catch (e) {
      attempt++;
      if (e.response?.statusCode == 429) {
        final retryAffer = e.response?.headers.value('Ratry-Affer');
        final retry = retryAffer != null ? int.tryParse(retryAffer) : 5;

        await Future.delayed(Duration(seconds: retry!));
      } else {
        print("massage error ${e.message}");
        if (attempt >= retries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    } on TimeoutException catch (e) {
      print("timeout $e");
      attempt++;
      if (attempt >= retries) {
        rethrow;
      }
    } on SocketException catch (e) {
      print("socketException $e");
      attempt++;
    } catch (e, strackTrace) {
      attempt++;
      print(e);
      print(strackTrace);

      if (attempt >= retries) {
        rethrow;
      }
      await Future.delayed(Duration(seconds: 2 * attempt));
    }
  }
}

Stream<List<double>> dataStream01({
  required String nameStock,
  required String dateStart,
  required String dateEnd,
  required ColumnStock colums,
}) async* {
  final Queue<List<double>> resulst = Queue<List<double>>();
  final List<double> listDataOpen = [];
  final List<double> listDataClose = [];

  /*beloe this for loop for get data dataModel this data model contain input user 
  and i uses for multifel resques to api and store to queue
  */

  try {
    List<Results> dataResult = await dataFetch(
      name: nameStock.toUpperCase(),
      start: dateStart,
      end: dateEnd,
    );

    /*below chek if data in open store to listOpen and not store to clese*/
    for (var addQueue in dataResult) {
      if (colums.name == 'open') {
        listDataOpen.add(addQueue.open);
      } else if (colums.name == 'close') {
        listDataClose.add(addQueue.close);
      }
    }
  } catch (e, strackTrace) {
    debugPrint("$e ----");
    debugPrint("$strackTrace --------");
  }

  // debugPrint("$listDataClose -data close");
  // debugPrint("$listDataOpen  --------data open");
  if (listDataOpen.isNotEmpty) {
    resulst.add(listDataOpen);
  }
  if (listDataClose.isNotEmpty) {
    resulst.add(listDataClose);
  }

  // debugPrint("$resulst           results");
  /*Below for return data for queue*/
  while (resulst.isNotEmpty) {
    yield resulst.first;
    resulst.removeFirst();
  }
}
