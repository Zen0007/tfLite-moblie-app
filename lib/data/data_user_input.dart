import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const id = Uuid();
final dataFormat = DateFormat.yMEd();
final uuidV4 = id.v4();

class DataModel {
  final String nameStock;
  final String dateStart;
  final String dateEnd;
  final ColumnStock category;
  /*above this catehory create lete if know to conpert enum to string*/
  final String uuid;

  DataModel(
    this.uuid, {
    required this.nameStock,
    required this.dateStart,
    required this.dateEnd,
    required this.category,
  });
}

enum ColumnStock { open, close }

const columnStock = {
  ColumnStock.open: "Open",
  ColumnStock.close: "Close",
};
