import 'package:hive/hive.dart';

part 'sales_model.g.dart';

@HiveType(typeId: 0)
class Sale extends HiveObject {
  @HiveField(0)
  String product;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double price;

  @HiveField(3)
  DateTime date;

  Sale({
    required this.product,
    required this.quantity,
    required this.price,
    required this.date,
  });

  double get total => quantity * price;
}
