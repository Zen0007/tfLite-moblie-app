import 'package:flutter/material.dart';

import 'package:responsibel/data/data_user_input.dart';

class ShowModal extends StatefulWidget {
  const ShowModal({super.key, required this.addData});
  final void Function(DataModel data) addData;
  // final void Function(DataMachineLearning data) addMl;

  @override
  State<ShowModal> createState() => _ShowModalState();
}

class _ShowModalState extends State<ShowModal> {
  final _nameStock = TextEditingController();
  DateTime? _dateStart;
  DateTime? _dateEnd;
  ColumnStock _opsionColumn = ColumnStock.open;
  void _sumbitData() {
    if (_nameStock.text.isEmpty || _dateStart == null || _dateEnd == null) {
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

/*======================================={ABOVE post data to local storage}=====================================*/
    widget.addData(
      DataModel(
        nameStock: _nameStock.text,
        dateStart: _dateStart!,
        dateEnd: _dateEnd!,
        category: _opsionColumn,
      ),
    );

    Navigator.pop(context);
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
