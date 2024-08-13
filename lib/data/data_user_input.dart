import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const id = Uuid();
final dataFormat = DateFormat.yMEd();
final uuidV4 = id.v4();

class DataModel {
  final String nameStock;
  final DateTime dateStart;
  final DateTime dateEnd;
  final ColumnStock category;
  /*above this catehory create lete if know to conpert enum to string*/
  final String uuid;

  DataModel({
    required this.nameStock,
    required this.dateStart,
    required this.dateEnd,
    required this.category,
  }) : uuid = uuidV4;

  get dateStarts {
    return dataFormat.format(dateStart);
  }

  get dateEnds {
    return dataFormat.format(dateEnd);
  }
}

enum ColumnStock { open, close }

final columnStock = {
  ColumnStock.open: "Open",
  ColumnStock.close: "Close",
};
