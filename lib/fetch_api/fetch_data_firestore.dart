import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsibel/data/data_user_input.dart';

Future<List<DataModel>> getDataFireStore() async {
  final List<DataModel> dataModel = [];
  final db = FirebaseFirestore.instance;
  try {
    var dataDb = await db.collection("user").get();
    for (var data in dataDb.docs) {
      var category = ColumnStock.close;
      if (data['category'] == "open") {
        category = ColumnStock.open;
      }
      dataModel.add(DataModel(
        uuid: data.id,
        nameStock: data['nameStock'],
        dateStart: data['dateStart'],
        dateEnd: data['dateEnd'],
        category: category,
        last: data["output_model"][1],
        pred: data["output_model"][0],
      ));
    }
    print("complated ${dataModel.length}");
  } catch (e, strackTrace) {
    print('$e  -----------------E-------------e');
    print('$strackTrace S');
  }
  return dataModel;
}
