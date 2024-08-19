import 'package:flutter/material.dart';
import 'package:responsibel/card/card_list.dart';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_user_input.dart';

class HomeView extends StatelessWidget {
  const HomeView(
      {super.key, required this.dataModel, required this.dataOutput});
  final List<DataModel> dataModel;
  final List<DataMachineLearning> dataOutput;
  @override
  Widget build(BuildContext context) {
    final temData = [
      DataMachineLearning(lastDate: 0.00, predictionStock: 0.00),
      DataMachineLearning(lastDate: 0.00, predictionStock: 0.00)
    ];
    return ListView.builder(
      itemCount: dataModel.length,
      itemBuilder: (context, index) => CardList(
        dataModel: dataModel[index],
        dataOutput: dataOutput.isEmpty ? temData[index] : dataOutput[index],
      ),
      /*Above cart List will have replace to dismisSebel*/
    );
  }
}
