import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/fetch_api/fetch_api_stock.dart';
import 'package:responsibel/model_ML/reshape.dart';
import 'dart:math';
import 'dart:async';
import 'package:tflite_flutter/tflite_flutter.dart';

Future<List<double>> process(
    {required String nameStock,
    required String dateStart,
    required String dateEnd,
    required ColumnStock colums}) async {
  final Queue<List<double>> queue = Queue<List<double>>();
  // Stream for listening to data from the API
  final Stream<List<double>> stream = dataStream01(
      nameStock: nameStock,
      dateStart: dateStart,
      dateEnd: dateEnd,
      colums: colums);
  final List<double> pred = [];

  await for (var element in stream) {
    if (element.isNotEmpty) {
      queue.add(element);
    }

    while (queue.isNotEmpty) {
      final List<double> dataList = [];
      for (var data in queue) {
        dataList.addAll(data);
      }
      double minData = dataList.reduce(min);
      double maxData = dataList.reduce(max);

      List<double> normalizedData = [];
      for (var i = 0; i < dataList.length; i++) {
        normalizedData.add((dataList[i] - minData) / (maxData - minData));
      }

      int nSteps = 3;
      List<List<double>> newData = [];

      for (var i = (normalizedData.length) - nSteps - 1; i > 0; i--) {
        var temp = normalizedData.sublist(i, i + nSteps);
        newData.add(temp);
      }

      final reshapeShape = [8, 1];
      final int requiredLength = reshapeShape.reduce(
        (value, element) => value * element,
      );

      if (newData.length % requiredLength != 0) {
        newData = newData.sublist(0, -newData.length % requiredLength);
      }

      newData = reshape(list: newData, col: 1, row: 8);
      final input = newData.reshape(reshapeShape);
      final output = List.filled(1, 0).reshape([1, 1]);

      /*below  for model machine learning  */
      Interpreter model = await Interpreter.fromAsset('assets/model.tflite');

      /*this try catch for make sure is run */
      try {
        model.run(input, output);
      } catch (e) {
        debugPrint("$e  e");
      } finally {
        model.close();
      }

      /* beloe for prediction data from user*/
      final double prediction = output.first[0] * (maxData - minData) + minData;
      final double predictionResults = prediction * 0.977;
      final double lastStock = dataList.last;

      pred.add(predictionResults);
      pred.add(lastStock);

      queue.removeFirst();
    }
  }

  // Add a timeout or some condition to ensure completer completes even if onDone is not called
  print("${pred.length}          data model");
  return pred;
}

Future<List<DataMachineLearning>> processOne({
  required String nameStock,
  required String dateStart,
  required String dateEnd,
  required ColumnStock colums,
}) {
  final Queue<List<double>> queue = Queue<List<double>>();
  final Completer<List<DataMachineLearning>> controler =
      Completer<List<DataMachineLearning>>();

  /* below this stream for listen data from api stock*/
  final Stream<List<double>> stream = dataStream01(
      nameStock: nameStock,
      dateStart: dateStart,
      dateEnd: dateEnd,
      colums: colums);
  final List<DataMachineLearning> pred = [];
  bool check = false;
  stream.listen(
    (event) async {
      queue.add(event);

      print("queue    $queue");
      /*below this for proses data from api to model*/
      while (queue.isNotEmpty) {
        final List<double> dataList = [];
        for (var data in queue) {
          dataList.addAll(data);
        }
        double minData = dataList.reduce(min);
        double maxData = dataList.reduce(max);

        List<double> normalisasiData = [];
        for (var i = 0; i < dataList.length; i++) {
          normalisasiData.add((dataList[i] - minData) / (maxData - minData));
        }

        int nSteps = 3;
        List<List<double>> newData = [];

        for (var i = (normalisasiData.length) - nSteps - 1; i > 0; i--) {
          var tem = normalisasiData.sublist(i, i + nSteps);
          newData.add(tem);
        }

        final reshapeShape = [8, 1];
        final int requiredLength = reshapeShape.reduce(
          (value, element) => value * element,
        );

        if (newData.length % requiredLength != 0) {
          final validLen = newData.length - (newData.length % requiredLength);
          newData = newData.sublist(0, validLen);
        }

        newData = reshape(list: newData, col: 1, row: 8);

        /* below reshpe data in newData*/
        final input = newData.reshape(reshapeShape);
        final output = List.filled(1, 0).reshape([1, 1]);

        /*below  for model machine learning  */
        Interpreter model = await Interpreter.fromAsset('assets/model.tflite');

        /*this try catch for make sure is run */
        try {
          model.run(input, output);
        } catch (e) {
          debugPrint("$e  e");
        }

        /* beloe for prediction data from user*/
        final double prediction =
            output.first[0] * (maxData - minData) + minData;
        final double predictionResults = prediction * 0.977;
        final double lastStock = dataList.last;
        // below for send data to database
        /*
         below code for send data to list <dataModel> 
        DataModel.add(DataModelprediction:predictionStock,LastOpen:lastStock))
        */

        pred.add(DataMachineLearning(
          lastDate: lastStock,
          predictionStock: predictionResults,
        ));

        queue.removeFirst();
        print("data pred model ${pred.length}");
      }
    },
    /*below this for data in body listen is compled data can be return */
    onDone: () {
      if (!check) {
        controler.complete(pred);
        check = true;
      }
    },
    onError: (error) {
      if (!check) {
        controler.completeError(error);
        check = true;
      }
    },
  );
  print("pred $pred");
  Future.delayed(
    const Duration(seconds: 2),
    () {
      if (!check) {
        controler.complete(pred);
        check = true;
      }
    },
  );
  return controler.future;
}
