import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsibel/data/data_user_input.dart';
import 'package:responsibel/model_ML/model.dart';

class ShowModal extends StatefulWidget {
  final void Function() addData;
  const ShowModal({super.key, required this.addData});

  @override
  State<ShowModal> createState() => _ShowModalState();
}

class _ShowModalState extends State<ShowModal> {
  final TextEditingController _nameStock = TextEditingController();
  DateTime? _dateStart;
  DateTime? _dateEnd;
  ColumnStock _opsionColumn = ColumnStock.open;

  void _sumbitData() async {
    if (_nameStock.text.isEmpty || _dateStart == null || _dateEnd == null) {
      platfrom();
      return;
    }
    print("${_nameStock.text} -----------------------1");
    print("${_dateStart} -------------------------2");
    print("${_dateEnd} -------------------------2");
    print("${_opsionColumn} ----------------------------3");
    /*======================================={ABOVE post data to local firestore}=====================================*/
    try {
      List<double> model = await process(
        nameStock: _nameStock.text,
        dateStart: "$_dateStart",
        dateEnd: "$_dateEnd",
        colums: _opsionColumn,
      );

      final Map<String, dynamic> dataModel = {
        "nameStock": _nameStock.text,
        "dateStart": "${_dateStart!}".substring(0, 10),
        "dateEnd": "${_dateEnd!}".substring(0, 10),
        "category": _opsionColumn.name,
        "output_model": model,
      };

      final CollectionReference db =
          FirebaseFirestore.instance.collection("user");
      db.doc().set(dataModel).onError(
        (error, stackTrace) {
          print("$error el");
          print("$stackTrace st");
        },
      );

      print("$dataModel  .................");
    } catch (e, strackTrace) {
      debugPrint("$e..................");
      debugPrint("$strackTrace .........");
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    // getData();
  }

  // void getData() async {
  //   print("data on");

  //   final List<DataModel> list = [
  //     DataModel(
  //         nameStock: "aapl",
  //         dateStart: _dateStart.toString(),
  //         dateEnd: _dateEnd.toString(),
  //         category: _opsionColumn)
  //   ];
  //   //
  //   final model = await process(
  //     nameStock: list.first.nameStock,
  //     colums: list.first.category,
  //     dateStart: list.first.dateStart,
  //     dateEnd: list.first.dateEnd,
  //   );

  //   for (var element in model) {
  //     print("complated ml $element");
  //     print("complated last date $element");
  //   }
  //   print("succes ${model} ${model}");
  // }

  void platfrom() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("invalid input "),
          content: const Text("please fill all the input before in summbit"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("oke"),
            ),
          ],
        ),
      );
      return;
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "INVALID INPUT",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'please fill all the input before sumbit',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('oke'),
            )
          ],
        ),
      );
      return;
    }
  }

  void _startTime() async {
    final now = DateTime.now();
    final firstDate = DateTime(2000);
    final pickDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDate: now,
    );
    setState(() {
      _dateStart = pickDate;
    });
  }

  void _endTime() async {
    final now = DateTime.now();
    final firstDate = DateTime(2000);
    final pickDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDate: now,
    );
    setState(() {
      _dateEnd = pickDate;
    });
  }

  @override
  void dispose() {
    _nameStock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyBord = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: double.infinity + 200,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 40, 25, keyBord + 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _dateStart == null
                                  ? "DateTime Start"
                                  : ("$_dateStart").substring(0, 10),
                            ),
                            IconButton(
                              onPressed: _startTime,
                              icon: const Icon(Icons.calendar_month),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _dateEnd == null
                                  ? "DateTime End"
                                  : ("$_dateEnd").substring(0, 10),
                            ),
                            IconButton(
                              onPressed: _endTime,
                              icon: const Icon(Icons.calendar_month),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameStock,
                          decoration: const InputDecoration(
                            label: Text('Symbol Stock'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      DropdownButton(
                        value: _opsionColumn,
                        items: ColumnStock.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.name.toUpperCase(),
                                ),
                              ),
                            )
                            .toList(),
                        // for (var data in  ColumnStock.values)

                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            print(_dateStart);
                            _opsionColumn = value;
                          });
                        },
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("CANCEL"),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        onPressed: _sumbitData,
                        child: const Text("SUMBIT"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
