import 'package:flutter/material.dart';
//import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_user_input.dart';

class CardList extends StatelessWidget {
  const CardList({super.key, required this.dataModel});
  final DataModel dataModel;
  //final DataMachineLearning dataOutput;

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
                  child: Center(
                      child: Text(
                    dataModel.nameStock.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  )),
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
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Center(child: Text(dataModel.dateStart)),
                ),
                Expanded(
                  child: Center(child: Text(dataModel.dateEnd)),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                const Expanded(
                    child: Center(
                  child: Text(
                    "PREDICTION",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
                Expanded(
                    child: Center(
                  child: Text("last ${columnStock[dataModel.category]!}"),
                ))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                    child: Center(
                  child: Text(dataModel.pred!.toStringAsFixed(2)),
                  // child: Text("test pred"),
                )),
                Expanded(
                    child: Center(
                  child: Text("${dataModel.last}"),
                  // child: Text("test last"),
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
