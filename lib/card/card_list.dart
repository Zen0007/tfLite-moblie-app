import 'package:flutter/material.dart';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_user_input.dart';

class CardList extends StatelessWidget {
  const CardList(
      {super.key, required this.dataModel, required this.dataOutput});
  final DataModel dataModel;
  final DataMachineLearning dataOutput;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(child: Text(dataModel.nameStock.toUpperCase())),
                ),
                const Spacer(),
                Text(
                  columnStock[dataModel.category]!,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Row(
              children: [
                Expanded(child: Center(child: Text('Start'))),
                Expanded(child: Center(child: Text('Ends')))
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Center(child: Text("${dataModel.dateStarts}")),
                ),
                Expanded(
                  child: Center(child: Text("${dataModel.dateEnds}")),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: Center(
                  child: Text("${dataOutput.lastDate}"),
                )),
                Expanded(
                    child: Center(
                  child: Text(dataOutput.predictionStock.toStringAsFixed(3)),
                ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
