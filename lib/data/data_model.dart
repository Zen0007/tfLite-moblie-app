import 'package:responsibel/data/data_user_input.dart';

class DataMachineLearning {
  final double lastDate;
  final double predictionStock;
  final String id;

  DataMachineLearning({
    required this.lastDate,
    required this.predictionStock,
  }) : id = uuidV4;
}
