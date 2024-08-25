import 'dart:collection';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_results.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'dart:math';
import 'dart:async';
import 'package:tflite_flutter/tflite_flutter.dart';

final List<DataMachineLearning> temporaryData = [];

class ModelTFLite {
  final List<Results> dataResults;
  final List<DataModel> dataModel;
  ModelTFLite({required this.dataResults, required this.dataModel}) {
    dataStream();
  }

  final queue = ListQueue<List<double>>();

  Stream<List<double>> dataStream() async* {
    List<double> listDataOpen = [];
    List<double> listDataClose = [];

    for (var data in dataModel) {
      for (var addQueue in dataResults) {
        if (columnStock[data.category]! == 'Open') {
          listDataOpen.add(addQueue.open);
        } else {
          listDataClose.add(addQueue.close);
        }
      }
    }

    if (listDataOpen.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      yield listDataOpen;
    } else {
      await Future.delayed(const Duration(seconds: 2));
      yield listDataClose;
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

  Stream<List<DataMachineLearning>> process() async* {
    final List<DataMachineLearning> pred = [];

    var dataStreams = dataStream();
    dataStreams.listen(
      (event) async {
        queue.add(event);
        while (queue.isNotEmpty) {
          final List<double> dataList = [];
          for (var data in queue) {
            dataList.addAll(data);
          }
          double minData = dataList.reduce(min);
          double maxData = dataList.reduce(max);

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
          Interpreter model =
              await Interpreter.fromAsset('assets/model.tflite');

          try {
            model.run(input, output);
            print("$pred  comperter");

            model.close();
          } catch (e) {
            print("$e  e");
          }

          /* beloe for prediction data from user*/
          double prediction = output.first[0];
          double predictionStock = prediction * 0.977;
          double lastDateStock = dataList.last;

          // below for send data to database
          /*
         below code for send data to list <dataModel> 
        DataModel.add(DataModelprediction:predictionStock,LastOpen:lastStock))
        */

          pred.add(DataMachineLearning(
              lastDate: lastDateStock, predictionStock: predictionStock));

          print("$prediction output model");
          print(" $predictionStock prediction");
          print(" $lastDateStock ---lastTime");
          print("${pred.length} pred2");
          queue.removeFirst();
        }
      },
      onDone: () {},
    );
    print("${pred.length}  pred");
    yield pred;
  }
}

Stream<List<DataMachineLearning>> resultsDataFromModel(
    List<Results> dataResults, List<DataModel> dataModel) {
  List<DataMachineLearning> data = [];
  yield data;
}
