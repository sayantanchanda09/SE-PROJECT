import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Local imports
import 'package:billing_and_accounting_system/database/database.dart';
import 'package:billing_and_accounting_system/expenses/expense_model.dart';
import 'package:billing_and_accounting_system/expenses/expenses.dart';
import 'package:billing_and_accounting_system/profit_loss_report/profit_loss_report.dart';
import 'package:billing_and_accounting_system/sales/sales.dart';
import 'package:billing_and_accounting_system/sales/sales_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  // Open Hive Boxes
  await Hive.openBox<Sale>('sales');
  await Hive.openBox<Expense>('expenses');

  print("Boxes opened successfully ✅");

  runApp(BusinessApp());
}

class BusinessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Billing App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.deepOrangeAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.deepOrangeAccent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.deepOrangeAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    SalesScreen(),
    ExpensesScreen(),
    ProfitLossScreen(),
    CustomerSupplierScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Profit/Loss',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Database',
          ),
        ],
      ),
    );
  }
}
