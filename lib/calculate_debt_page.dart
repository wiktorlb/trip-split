import 'package:flutter/material.dart';
import 'models.dart';
import 'database/database_helper.dart';

/*
* CalculateDebtPage
*
*
* */

class CalculateDebtPage extends StatefulWidget {
  final TravelGroup group;

  CalculateDebtPage({required this.group});

  @override
  _CalculateDebtPageState createState() => _CalculateDebtPageState();
}

class _CalculateDebtPageState extends State<CalculateDebtPage> {
  late DatabaseHelper _databaseHelper;
  late Future<List<Expense>> _expenses;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _expenses = _databaseHelper.getExpenses(widget.group.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Oblicz zadłużenie')),
      body: FutureBuilder<List<Expense>>(
        future: _expenses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Brak wydatków.'));
          } else {
            List<Expense> expenses = snapshot.data!;
            // Calculate Total Debt
            // Add All Expenses
            double total = expenses.fold(0, (sum, e) => sum + e.amount);
            return Center(child: Text('Suma wydatków: $total zł'));
          }
        },
      ),
    );
  }
}
