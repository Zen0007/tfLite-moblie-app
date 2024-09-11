import 'package:flutter/material.dart';
import 'package:responsibel/card/card_list.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/model_ML/model.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.dataModel,
  });
  final List<DataModel> dataModel;

  @override
  Widget build(BuildContext context) {
    print(dataModel.length);
    print("show");

    try {} catch (e) {}
    if (dataModel.isEmpty) {
      return const Center(
        child: Text(
          "you have add some data",
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
      );
    }

    return FutureBuilder(
      future: process(dataModel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("a");
          return const Center(
            child: Column(
              children: [
                SizedBox(
                  height: 9,
                ),
                SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    value: null,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: Text("please wait"),
                )
              ],
            ),
          );
        } else if (snapshot.hasError) {
          print("b");
          return Center(
            child: Text(
              "${snapshot.error}\n this error",
              maxLines: 2,
            ),
          );
        } else if (!snapshot.hasData) {
          print("c");
          return const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text("data not available"),
              ],
            ),
          );
        } else if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text("data isempaty"),
          );
        } else {
          print("d");
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => CardList(
              dataModel: dataModel[index],
              dataOutput: snapshot.data![index],
            ),
            /*Above cart List will have replace to dismisSebel*/
          );
        }
      },
    );
  }
}



//  StreamBuilder(
//       stream: resultsDataFromModel(dataModel),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (context, index) {
//               CardList(
//                   dataModel: dataModel[index],
//                   dataOutput: snapshot.data![index]);
//             },
//           );
//         }
//       },
//     );