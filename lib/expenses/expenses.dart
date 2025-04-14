import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'expense_model.dart'; // Make sure this file is correctly generated

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final Box<Expense> _expensesBox = Hive.box<Expense>('expenses');

  void _addOrEditExpense({Expense? expense}) {
    final categoryController = TextEditingController(text: expense?.category);
    final amountController = TextEditingController(
        text: expense != null ? expense.amount.toStringAsFixed(2) : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final category = categoryController.text;
              final amount = double.tryParse(amountController.text) ?? 0.0;

              if (category.isEmpty || amount <= 0.0) return;

              final newExpense = Expense(
                category: category,
                amount: amount,
                date: DateTime.now(),
              );

              if (expense == null) {
                _expensesBox.add(newExpense);
              } else {
                expense.category = newExpense.category;
                expense.amount = newExpense.amount;
                expense.date = newExpense.date;
                expense.save();
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

  void _deleteExpense(Expense expense) {
    expense.delete();
    setState(() {});
  }

  void _showInvoice(Expense expense) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Expense Invoice'),
        content: Text(
          'Category: ${expense.category}\n'
          'Amount: ₹${expense.amount.toStringAsFixed(2)}\n'
          'Date: ${expense.date.toLocal()}',
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

  double _getTotalExpenses() {
    return _expensesBox.values.fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _expensesBox.listenable(),
      builder: (context, Box<Expense> box, _) {
        final expenses = box.values.toList();

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrangeAccent,
            onPressed: () => _addOrEditExpense(),
            child: Icon(Icons.add),
          ),
          body: expenses.isEmpty
              ? Center(
                  child: Text(
                    'No Expenses Recorded',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return Card(
                            color: Colors.grey[900],
                            margin:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: ListTile(
                              title: Text(
                                expense.category,
                                style:
                                    TextStyle(color: Colors.orangeAccent),
                              ),
                              subtitle: Text(
                                'Amount: ₹${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.receipt_long,
                                        color: Colors.greenAccent),
                                    onPressed: () => _showInvoice(expense),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.amber),
                                    onPressed: () =>
                                        _addOrEditExpense(expense: expense),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => _deleteExpense(expense),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.centerRight,
                      color: Colors.grey[850],
                      child: Text(
                        'Total: ₹${_getTotalExpenses().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
        );
      },
    );
  }
}
