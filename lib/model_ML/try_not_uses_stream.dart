import 'dart:collection';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_results.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelTFLiteNotUsesStream {
  final List<Results> dataResults;
  final List<DataModel> dataModel;

  ModelTFLiteNotUsesStream(
      {required this.dataResults, required this.dataModel}) {
    dataStream();
  }

  final queue = ListQueue<List<double>>();

  // void fetchData() async {
  //   try {
  //     _interpreter = await Interpreter.fromAsset("assets/model.tflite");
  //     print("sucess");
  //     return;
  //   } catch (e, strackTrace) {
  //     print("$e error 404");
  //     print(strackTrace);
  //   }
  // }

  void dataStream() {
    List<double> listDataOpen = [];
    List<double> listDataClose = [];

    for (var data in dataModel) {
      for (var addQueue in dataResults) {
        if (columnStock[data.category]! == 'Open') {
          listDataOpen.add(addQueue.open);
          print("${columnStock[data.category]} colums");
        } else {
          listDataClose.add(addQueue.close);
        }
      }
    }

    if (listDataOpen.isNotEmpty) {
      queue.add(listDataOpen);
      print("$listDataOpen list open");
      return;
    } else {
      queue.add(listDataClose);
      print("$listDataClose \n list close");
      return;
    }
  }

  List<List<T>> reshape<T>(
      {required List<List<T>> list, required col, required int row}) {
    List<List<T>> result =
        List.generate(row, (_) => List.filled(col, 0.0 as T));

    int indexRow = 0;
    int indexColumn = 0;
    for (var i = 0; i < row; i++) {
      for (var j = 0; j < col; j++) {
        if (indexRow < list.length && indexColumn < list[indexRow].length) {
          result[i][j] = list[indexRow][indexColumn];
        } else {
          result[i][j] = 0.0 as T;
        }

        indexColumn++;
        if (indexColumn >= list[indexRow].length) {
          indexColumn = 0;
          indexRow++;
        }

        if (indexRow >= list.length) break;
      }
    }

    return result;
  }

  Future<List<DataMachineLearning>> process() async {
    List<DataMachineLearning> pred = [];

    while (queue.isNotEmpty) {
      final List<double> dataList = [];

      for (var data in queue) {
        dataList.addAll(data);
      }
      double minData =
          dataList.isEmpty ? 0.0 : (dataList.reduce(min) as num).toDouble();
      double maxData =
          dataList.isEmpty ? 0.0 : (dataList.reduce(max) as num).toDouble();

      List<double> normalisasiData = [];
      for (var data in dataList) {
        normalisasiData.add((data - minData) / (maxData - minData));
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
        newData = newData.sublist(0, -newData.length % requiredLength);
      }

      newData = reshape(list: newData, col: 1, row: 8);

      /* below reshpe data in newData*/
      final input = newData.reshape(reshapeShape);
      final output = List.filled(1, 0).reshape([1, 1]);

      /*below  for model machine learning  */
      final Interpreter interpreter =
          await Interpreter.fromAsset("assets/model.tflite");
      try {
        interpreter.run(input, output);
      } catch (e, strackTrace) {
        print(e);
        print(strackTrace);
      }

      /* beloe for prediction data from user*/
      double prediction = ((output.first[0]) as num).toDouble();
      double predictionStock = (prediction * 0.977).toDouble();
      double lastDateStock = (dataList.last).toDouble();

      // below for send data to database
      /*
         below code for send data to list <dataModel> 
        DataModel.add(DataModelprediction:predictionStock,LastOpen:lastStock))
        */

      pred.add(DataMachineLearning(
        lastDate: lastDateStock,
        predictionStock: predictionStock,
      ));

      print("${queue.length} data queue");
      queue.removeFirst();
    }

    return pred;
  }
}

Future<List<DataMachineLearning>> dataMachineLearning(
    List<Results> dataForML, List<DataModel> dataModel) async {
  List<DataMachineLearning> data = [];
  try {
    final ModelTFLiteNotUsesStream modelML =
        ModelTFLiteNotUsesStream(dataResults: dataForML, dataModel: dataModel);
    data = await modelML.process();
  } catch (e, strackTrace) {
    print("$e fuction try not uses stream");
    print("$strackTrace try not  uses stream");
  }

  return data;
}
