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
  final double? pred;
  final double? last;
  /*above this catehory create lete if know to conpert enum to string*/
  final String? uuid;

  DataModel({
    required this.nameStock,
    required this.dateStart,
    required this.dateEnd,
    required this.category,
    this.last,
    this.pred,
    this.uuid,
  });
}

enum ColumnStock { open, close }

const columnStock = {
  ColumnStock.open: "Open",
  ColumnStock.close: "Close",
};
