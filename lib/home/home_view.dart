import 'package:flutter/material.dart';
import 'package:responsibel/card/card_list.dart';
import 'package:responsibel/data/data_user_input.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.dataModel});
  final List<DataModel> dataModel;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dataModel.length,
      itemBuilder: (context, index) => CardList(
        dataModel: dataModel[index],
      ),
      /*Above cart List will have replace to dismisSebel*/
    );
  }
}
