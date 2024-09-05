import 'dart:collection';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_results.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/fetch_api/fetch_api_stock.dart';
import 'package:responsibel/model_ML/reshape.dart';
import 'dart:math';
import 'dart:async';
import 'package:tflite_flutter/tflite_flutter.dart';

final List<DataMachineLearning> temporaryData = [];

//

Stream<List<double>> _dataStream(List<DataModel> dataModel) async* {
  final Queue<List<double>> resulst = Queue<List<double>>();
  final List<double> listDataOpen = [];
  final List<double> listDataClose = [];
  for (var data in dataModel) {
    try {
      List<Results> dataResult = await dataFetch(
        name: data.nameStock.toUpperCase(),
        start: "${data.dateStart}",
      );

      for (var addQueue in dataResult) {
        print("${columnStock[data.category]!} 00");
        if (columnStock[data.category]! == 'Open') {
          listDataOpen.add(addQueue.open);
        } else if (columnStock[data.category]! == 'Close') {
          listDataClose.add(addQueue.close);
        }
      }
      print(listDataClose);
      print(listDataOpen);
    } catch (e, strackTrace) {
      print(e);
      print(strackTrace);
    }
  }

  if (listDataClose.isNotEmpty) {
    resulst.add(listDataClose);
  }
  if (listDataOpen.isNotEmpty) {
    resulst.add(listDataOpen);
  }
  print("${resulst.length} 888");
  while (resulst.isNotEmpty) {
    yield resulst.first;
    resulst.removeFirst();
    await Future.delayed(const Duration(seconds: 5));
  }
}

Future<List<DataMachineLearning>> process(List<DataModel> dataModel) {
  final Queue<List<double>> queue = Queue<List<double>>();
  final Completer<List<DataMachineLearning>> controler =
      Completer<List<DataMachineLearning>>();

  final List<DataMachineLearning> pred = [];
  try {
    final Stream<List<double>> stream = _dataStream(dataModel);
    stream.listen(
      (event) async {
        queue.add(event);
        print("${queue.length} queue");

        while (queue.isNotEmpty) {
          final List<double> dataList = [];
          for (var data in queue) {
            print("${data.length} data");
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
            print("$model  comperter");
          } catch (e) {
            print("$e  e");
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

          pred.add(
            DataMachineLearning(
              lastDate: lastStock,
              predictionStock: predictionResults,
            ),
          );

          print("$prediction output model");
          print("${pred.length} pred2");
          print("${queue.length}  queue");

          queue.removeFirst();
        }
      },
      onDone: () => controler.complete(pred),
      onError: (error) => controler.completeError(error),
    );
  } catch (e, strackTrace) {
    print(e);
    print(strackTrace);
  }

  // print("${.length}\n pred");

  return controler.future;
}

// Stream<List<DataMachineLearning>> resultsDataFromModel(
//     List<DataModel> dataModel) async* {
//   List<DataMachineLearning> results = [];
//   try {
//     final model = process(dataModel);
//     model.listen(
//       (event) {
//         results = event;
//         print(event);
//       },
//     );
//   } catch (e, strackTrace) {
//     print(e);
//     print(strackTrace);
//   }

//   print('${results.length} resultsdatafrommodel ');
//   yield results;
// }

//class ModelTFLite {
//   //final List<Results> dataResults;
//   final List<DataModel> dataModel;
//   ModelTFLite({required this.dataModel}) {
//     dataStream();
//   }

//   // late List<Results> dataResult = [];

//   // void getData() async {
//   //   for (var data in dataModel) {
//   //     try {
//   // dataResult = await dataFetch(
//   //   name: data.nameStock.toUpperCase(),
//   //   start: "${data.dateStart}",
//   // );
//   //     } catch (e, strackTrace) {
//   //       print(e);
//   //       print(strackTrace);
//   //     }
//   //   }
//   // }

//   Stream<List<double>> dataStream() async* {
//     List<double> listDataOpen = [];
//     List<double> listDataClose = [];

//     for (var data in dataModel) {
//       try {
//         List<Results> dataResult = await dataFetch(
//           name: data.nameStock.toUpperCase(),
//           start: "${data.dateStart}",
//         );

//         for (var addQueue in dataResult) {
//           if (columnStock[data.category]! == 'Open') {
//             listDataOpen.add(addQueue.open);
//           } else {
//             listDataClose.add(addQueue.close);
//           }
//         }
//       } catch (e, strackTrace) {
//         print(e);
//         print(strackTrace);
//       }
//     }

//     if (listDataOpen.isNotEmpty) {
//       yield listDataOpen;
//     } else {
//       yield listDataClose;
//     }
//   }

//   List<List<T>> reshape<T>(
//       {required List<List<T>> list, required col, required int row}) {
//     List<List<T>> result =
//         List.generate(row, (_) => List.filled(col, 0.0 as T));

//     int indexRow = 0;
//     int indexColumn = 0;
//     for (var i = 0; i < row; i++) {
//       for (var j = 0; j < col; j++) {
//         if (indexRow < list.length && indexColumn < list[indexRow].length) {
//           result[i][j] = list[indexRow][indexColumn];
//         } else {
//           result[i][j] = 0.0 as T;
//         }

//         indexColumn++;
//         if (indexColumn >= list[indexRow].length) {
//           indexColumn = 0;
//           indexRow++;
//         }

//         if (indexRow >= list.length) break;
//       }
//     }

//     return result;
//   }

//   Stream<List<DataMachineLearning>> process() async* {
//     final List<DataMachineLearning> pred = [];
//     final queue = ListQueue<List<double>>();

//     try {
//       var dataStreams = dataStream();
//       dataStreams.listen(
//         (event) async {
//           queue.add(event);
//           print("$event 00");
//         },
//       );
//     } catch (e, strackTrace) {
//       print('$e this error from get data api stock');
//       print("$strackTrace this strackTrace from geta data api stock");
//     }

//     while (queue.isNotEmpty) {
//       print(queue);
//       final List<double> dataList = [];
//       for (var data in queue) {
//         dataList.addAll(data);
//       }
//       double minData = dataList.reduce(min);
//       double maxData = dataList.reduce(max);

//       List<double> normalisasiData = [];
//       for (var data in dataList) {
//         normalisasiData.add((data - minData) / (maxData - minData));
//       }

//       int nSteps = 3;
//       List<List<double>> newData = [];

//       for (var i = (normalisasiData.length) - nSteps - 1; i > 0; i--) {
//         var tem = normalisasiData.sublist(i, i + nSteps);
//         newData.add(tem);
//       }

//       final reshapeShape = [8, 1];
//       final int requiredLength = reshapeShape.reduce(
//         (value, element) => value * element,
//       );

//       if (newData.length % requiredLength != 0) {
//         newData = newData.sublist(0, -newData.length % requiredLength);
//       }

//       newData = reshape(list: newData, col: 1, row: 8);

//       /* below reshpe data in newData*/
//       final input = newData.reshape(reshapeShape);
//       final output = List.filled(1, 0).reshape([1, 1]);

//       /*below  for model machine learning  */
//       Interpreter model = await Interpreter.fromAsset('assets/model.tflite');

//       try {
//         model.run(input, output);
//         print("$model  comperter");

//         model.close();
//       } catch (e) {
//         print("$e  e");
//       }

//       /* beloe for prediction data from user*/
//       double prediction = output.first[0] * (maxData - minData) + minData;
//       double predictionStock = prediction * 0.977;
//       double lastDateStock = dataList.last;

//       // below for send data to database
//       /*
//          below code for send data to list <dataModel>
//         DataModel.add(DataModelprediction:predictionStock,LastOpen:lastStock))
//         */

//       pred.add(DataMachineLearning(
//         lastDate: lastDateStock,
//         predictionStock: predictionStock,
//       ));

//       print("$prediction output model");
//       print(" $predictionStock prediction");
//       print(" $lastDateStock ---lastTime");
//       print("${pred.length} pred2");
//       print("${queue.length}  queue");
//       queue.removeFirst();
//     }
//     print("${pred.length}  pred");

//     yield pred;
//   }
// }
