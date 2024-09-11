import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/home/home_view.dart';
import 'package:responsibel/home/show_modal.dart';

/*  data have to store to data base thas is data from user in folder show_modal.dart 
   data form ml in model.dart
*/

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*======================{ABOVE get data from local storage}=====================*/
  final List<DataModel> dataModel = [];
  final db = FirebaseFirestore.instance;

/*          STORE DATA TO LOCAL STORAGE its not will store to database ----------- -------- -------- -*/
  // static List<Results> _dataForMl = [];

/* above this code for Model tfLite flutter*/
  // late ModelTFLite modelML;

  void getData() async {
    print("data on");
    // this error has solve becaus data before 2024 is int therefore dataML is solve
    /*below this dataFetch will be arise exception int not sigh to doubel if datetime sart begin in yer 2023 */
    try {
      var dataDb = await db.collection("user").get();
      for (var data in dataDb.docs) {
        var category = ColumnStock.close;
        print("${data['nameStock']} -----------------------1");
        print("${data['dateStart']} -------------------------2");
        print("${data['dateEnd']} -------------------------2");
        print("${data['category']} ----------------------------3");
        print(data.id);
        if (data['category'] == "open") {
          category = ColumnStock.open;
        }
        print(category);
        setState(() {
          dataModel.add(DataModel(
            data.id,
            nameStock: data['nameStock'],
            dateStart: data['dateStart'],
            dateEnd: data['dateEnd'],
            category: category,
          ));
        });
      }
      print("complated ${dataModel.length}");
    } catch (e, strackTrace) {
      print('$e  -----------------E-------------e');
      print('$strackTrace S');
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

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
    Widget layout = Column(
      children: [
        Expanded(
          child: HomeView(
            dataModel: dataModel,
          ),
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
              child: HomeView(
                dataModel: dataModel,
              ),
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
