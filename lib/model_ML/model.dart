import 'dart:collection';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'dart:math';
import 'dart:async';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelTFLite {
  final List<Results> dataResults;
  final List<DataModel> dataModel;
  ModelTFLite({required this.dataResults, required this.dataModel}) {
    dataStream();
    process();
  }

  final queue = ListQueue<List<double>>();
  static final List<DataMachineLearning> finishDataML = [];
  static final List<DataMachineLearning> dataMachineLearning = [];

  List<List<double>> newDataTem = [];

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
      await Future.delayed(const Duration(seconds: 5));
      yield listDataOpen;
    } else {
      await Future.delayed(const Duration(seconds: 5));
      yield listDataClose;
    }
  }

  List<List<T>> reshape<T>(
      {required List<List<T>> list, required col, required int row}) {
    List<List<T>> result =
        List.generate(row, (_) => List.filled(col, 0.0 as T));
    try {
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
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }
    return result;
  }

  void process() {
    var dataStreams = dataStream();
    // ignore: unused_local_variable
    late StreamSubscription<List<double>> subscription;
    subscription = dataStreams.listen(
      (event) async {
        queue.add(event);
        while (queue.isNotEmpty) {
          final List<double> dataList = [];
          for (var data in queue) {
            dataList.addAll(data);
          }
          double minData = dataList.reduce(min);
          double maxData = dataList.reduce(max);
          print(minData);
          print(maxData);

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

          //final List<List<double>> output = [];

          /*below  for model machine learning  */
          // interperter model tflite.Interpreter.fromAsset('asset/model.tflite')

          /* beloe for prediction data from user*/
          //model.run(newData,output)

          // double prediction = output.last[0];
          // // double predictionStock = prediction * 0.9773;
          // // double lastDateStock = dataList.last;

          // below for send data to database
          /*
         below code for send data to list <dataModel> 
        DataModel.add(DataModelprediction:predictionStock,LastOpen:lastStock))
        */

          print("${input.shape}  datalist");
          print(" ${newData.shape} newdata");
          print(" ${newData.shape}---tem");
          //print("queue");
          queue.removeFirst();
        }
      },
      onDone: () {
        print("${queue.length} queue");
      },
    );
  }
}

class Results {
  final double open;
  final double close;

  Results({
    required this.open,
    required this.close,
  });

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        open: (json['o'] as num).toDouble(),
        close: (json['c'] as num).toDouble(),
      );
}
