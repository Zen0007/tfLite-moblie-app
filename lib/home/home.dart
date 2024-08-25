import 'dart:async';
import 'package:flutter/material.dart';
import 'package:responsibel/data/data_model.dart';
import 'package:responsibel/data/data_results.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/fetch_api/fetch_api_stock.dart';
import 'package:responsibel/home/home_view.dart';
import 'package:responsibel/home/show_modal.dart';
import 'package:responsibel/model_ML/try_not_uses_stream.dart';

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
  static final List<DataModel> _dataModel = [];

/*----- ------- -----STORE DATA TO LOCAL STORAGE its not will store to database ----------- -------- -------- -*/

/* above this code for Model tfLite flutter*/
  List<DataMachineLearning> dataML = [];
  List<Results> _dataForModel = [];

  Future<void> _getDataApi() async {
    // this error has solve becaus data before 2024 is int therefore dataML is solve
    /*below this dataFetch will be arise exception int not sigh to doubel if datetime sart begin in yer 2023 */

    List<Results> data;

    for (var datas in _dataModel) {
      try {
        data = await dataFetch(
          name: datas.nameStock.toUpperCase(),
          start: "${datas.dateStart}",
        );

        setState(() {
          _dataForModel = data;
          getDataModel(_dataForModel, _dataModel);
        });
        print('${data.first.close}   results');
        print("len model ${_dataModel.length}");
      } catch (e, strackTrace) {
        print('$e  -----------------E-------------e');
        print('$strackTrace S');
        print("${_dataModel.first.dateStart.toString().substring(0, 10)} len");
      }
    }
  }

  void getDataModel(List<Results> dataForMl, List<DataModel> dataModel) async {
    try {
      List<DataMachineLearning> model =
          await dataMachineLearning(dataForMl, dataModel);
      setState(() {
        dataML = model;
      });
      print(dataML.length);
    } catch (e, strackTrace) {
      print("$e ((((()))))");
      print(strackTrace);
    }
  }

  @override
  void initState() {
    super.initState();
    _getDataApi();
  }

  void _addData(DataModel data) {
    setState(() {
      _dataModel.add(data);
    });
  }

  void _opendSheet() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => ShowModal(
        addData: _addData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Widget layout = Column(
      children: [
        Expanded(
          child: HomeView(
            dataModel: _dataModel,
            dataOutput: _dataForModel,
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
              child: HomeView(dataModel: _dataModel, dataOutput: _dataForModel),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Prediction"),
        actions: [
          if (width <= 600)
            IconButton(
                onPressed: _opendSheet,
                icon: const Icon(
                  Icons.add,
                  size: 25,
                ))
        ],
      ),
      body: layout,
    );
  }
}
