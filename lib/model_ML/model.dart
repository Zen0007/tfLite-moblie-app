import 'dart:collection';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'dart:math';
import 'dart:async';
//import 'package:tflite_flutter/tflite_flutter.dart';

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

  void data() {}

  Stream<void> dataStream() async* {
    List<double> listDataOpen = [];
    List<double> listDataClose = [];

    for (var data in dataModel) {
      for (var addQueue in dataResults) {
        if (columnStock[data.category]! == 'Open') {
          listDataOpen.add(addQueue.open);

          await Future.delayed(const Duration(seconds: 5));
          queue.add(listDataOpen);
          return;
        } else {
          listDataClose.add(addQueue.close);

          await Future.delayed(const Duration(seconds: 5));
          queue.add(listDataClose);
          return;
        }
      }
    }
  }

  void process() async {
    var dataStreams = dataStream();
    // ignore: unused_local_variable
    late StreamSubscription<void> subscription;
    subscription = dataStreams.listen(
      (_) async {
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

          int nSteps = 5;
          List<double> newData = [];

          for (var i = 0; i < normalisasiData.length - nSteps + 1; i++) {
            var tem = normalisasiData.sublist(i, i + nSteps);
            newData.addAll(tem);
          }

          final reshapeShape = [8, 1];
          final int requiredLength = reshapeShape.reduce(
            (value, element) => value * element,
          );

          if (newData.length % requiredLength != 0) {
            newData = newData.sublist(0, -newData.length % requiredLength);
          }
          /* below reshpe data in newData*/
          // final input = newData.reshape([8, 1]);

          // final List<List<double>> output = [];

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

          print("${dataList.last} ${newData.length}---tem");
          queue.removeFirst();
        }
      },
      onDone: () => print(queue.length),
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
