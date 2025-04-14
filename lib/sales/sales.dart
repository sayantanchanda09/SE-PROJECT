import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'sales_model.dart'; // Ensure this file defines and registers the Hive adapter for Sale

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late final Box<Sale> _salesBox;

  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _salesBox = Hive.box<Sale>('sales');
  }

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addOrEditSale({Sale? sale}) {
    final productController = TextEditingController(text: sale?.product);
    final quantityController = TextEditingController(text: sale?.quantity.toString());
    final priceController = TextEditingController(text: sale?.price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(sale == null ? 'Add Sale' : 'Edit Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: productController,
              decoration: InputDecoration(labelText: 'Product'),
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final product = productController.text.trim();
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0.0;

              if (product.isEmpty || quantity <= 0 || price <= 0.0) return;

              if (sale == null) {
                _salesBox.add(Sale(
                  product: product,
                  quantity: quantity,
                  price: price,
                  date: DateTime.now(),
                ));
              } else {
                sale.product = product;
                sale.quantity = quantity;
                sale.price = price;
                sale.date = DateTime.now();
                sale.save();
              }

              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteSale(Sale sale) {
    sale.delete();
    setState(() {});
  }

  void _generateInvoice(Sale sale) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Invoice'),
        content: Text(
          'Product: ${sale.product}\n'
          'Quantity: ${sale.quantity}\n'
          'Price: ₹${sale.price.toStringAsFixed(2)}\n'
          'Total: ₹${sale.total.toStringAsFixed(2)}\n'
          'Date: ${sale.date.toLocal()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Sale>>(
      valueListenable: _salesBox.listenable(),
      builder: (context, box, _) {
        final sales = box.values.toList();

        return Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrangeAccent,
            onPressed: () => _addOrEditSale(),
            child: Icon(Icons.add),
          ),
          body: sales.isEmpty
              ? Center(
                  child: Text('No Sales Added', style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];

                    return Card(
                      color: Colors.grey[900],
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(sale.product, style: TextStyle(color: Colors.orangeAccent)),
                        subtitle: Text(
                          'Qty: ${sale.quantity}, Price: ₹${sale.price}, Total: ₹${sale.total.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.receipt_long, color: Colors.greenAccent),
                              onPressed: () => _generateInvoice(sale),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _addOrEditSale(sale: sale),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteSale(sale),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
