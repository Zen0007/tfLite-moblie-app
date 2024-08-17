import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/home/home_view.dart';
import 'package:responsibel/home/show_modal.dart';
import 'package:http/http.dart' as http;
import 'package:responsibel/model_ML/model.dart';

Future<List<Results>> dataFetch(
    {required String name, required String start}) async {
  var response = await http.get(
    Uri.parse(
      "https://api.polygon.io/v2/aggs/ticker/$name/range/1/day/$start/2024-08-01?adjusted=false&sort=desc&apiKey=3Nq8xQxfTb8xwIWUhGtaXbqhQUL_OHn4",
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> temData = data['results'];
    print(temData.length);
    return temData.map((json) => Results.fromJson(json)).toList();
  } else {
    throw Exception("data not found");
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
  static final List<DataModel> _dataModel = [
    DataModel(
      nameStock: "aapl",
      dateStart: DateTime(2024, 07, 25),
      dateEnd: DateTime.now(),
      category: ColumnStock.open,
    ),
    DataModel(
      nameStock: "goog",
      dateStart: DateTime(2024, 08, 02),
      dateEnd: DateTime.now(),
      category: ColumnStock.open,
    ),
  ];

/*          STORE DATA TO LOCAL STORAGE its not will store to database ----------- -------- -------- -*/
  static List<Results> _dataMl = [];

/* above this code for Model tfLite flutter*/
  late ModelTFLite modelML;
/*above for queue data to fetch*/

  Future<void> _getData() async {
    // this error has solve becaus data before 2024 is int therefore dataML is improve
    /*below this dataFetch will be arise exception int not sigh to doubel if datetime sart begin in yer 2023 */

    List<Results> data;
    for (var datas in _dataModel) {
      try {
        data = await dataFetch(
          name: datas.nameStock.toUpperCase(),
          start: "2024-01-01",
        );

        setState(() {
          _dataMl = data;
          modelML = ModelTFLite(dataResults: _dataMl, dataModel: _dataModel);
          print("${_dataMl.length} data Lenght");
        });
      } catch (e, strackTrace) {
        print('$e  -----------------E-------------e');
        print('$strackTrace S');
      }
    }
  }

  @override
  void initState() {
    _getData();
    super.initState();
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
                dataModel: _dataModel,
              ),
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
