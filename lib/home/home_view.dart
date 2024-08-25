import 'package:flutter/material.dart';
import 'package:responsibel/card/card_list.dart';
import 'package:responsibel/data/data_results.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/model_ML/try_not_uses_stream.dart';

class HomeView extends StatelessWidget {
  const HomeView(
      {super.key, required this.dataModel, required this.dataOutput});
  final List<DataModel> dataModel;
  final List<Results> dataOutput;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dataMachineLearning(dataOutput, dataModel).asStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return CardList(
                dataModel: dataModel[index],
                dataOutput: snapshot.data![index],
              );
            },
          );
        } else {
          return Center(
            child: Text(" late data ${snapshot.data}  "),
          );
        }
      },
    );
  }
}
