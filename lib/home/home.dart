import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/home/home_view.dart';
import 'package:responsibel/home/show_modal.dart';
import 'package:responsibel/model_ML/model.dart';

/*  data have to store to data base thas is data from user in folder show_modal.dart 
   data form ml in model.dart
*/

void getData() async {
  print("data on");
  final List<DataModel> dataModel = [];
  /*this error has solve becaus data before 2024 is int therefore dataML is solve*/
  /*below this dataFetch will be arise exception int not sigh to doubel if datetime sart begin in yer 2023 */
  final db = FirebaseFirestore.instance;
  var dataDb = await db.collection("user").get();
  for (var data in dataDb.docs) {
    var category = ColumnStock.close;
    print("${data['nameStock']} -----------------------1");
    print("${data['dateStart']} -------------------------2");
    print("${data['dateEnd']} -------------------------2");
    print("${data['category']} ----------------------------3");
    print(data.id);
    print("${data["output_model"]}         4");
    if (data['category'] == "open") {
      category = ColumnStock.open;
    }
    print(category);

    dataModel.add(DataModel(
      uuid: data.id,
      nameStock: data['nameStock'],
      dateStart: data['dateStart'],
      dateEnd: data['dateEnd'],
      category: category,
      last: data["output_model"],
    ));
  }
  try {
    List<double> model = await process(
      nameStock: "aapl",
      dateStart: "2024-08-01",
      dateEnd: "2024-09-16",
      colums: ColumnStock.close,
    );
    print("${model.first}  data home ");
  } catch (e, strackTrace) {
    debugPrint("$e");
    debugPrint("$strackTrace");
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*======================{ABOVE get data from local storage}=====================*/

/*          STORE DATA TO LOCAL STORAGE its not will store to database ----------- -------- -------- -*/

  void addShowModal() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => ShowModal(addData: getData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Widget layout = const Column(
      children: [
        Expanded(
          child: HomeView(),
        ),
      ],
    );

    if (width >= 600) {
      layout = Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: const Color.fromARGB(255, 187, 255, 0),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blue,
              child: const HomeView(),
            ),
          ),
        ],
      );
    }
    print("rebuild home");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Prediction"),
        actions: [
          if (width <= 600)
            IconButton(
              // showmodal
              onPressed: addShowModal,
              icon: const Icon(
                Icons.add,
                size: 25,
              ),
            )
        ],
      ),
      body: layout,
    );
  }
}
