import 'package:flutter/material.dart';
import 'models.dart';
import 'database/database_helper.dart';

class ExpensePage extends StatefulWidget {
  final TravelGroup group;

  ExpensePage({required this.group});

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late DatabaseHelper _databaseHelper;
  late Future<List<Expense>> _expenses;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  Member? _selectedMember; // This will hold the selected member

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _expenses = _databaseHelper.getExpenses(widget.group.id); // Load existing expenses
  }

  void _addExpense() async {
    if (_formKey.currentState!.validate() && _selectedMember != null) {
      final description = _descriptionController.text;
      final amount = double.parse(_amountController.text);

      final expense = Expense(
        description: description,
        person: _selectedMember!, // Use the selected Member
        amount: amount,
      );
      await _databaseHelper.insertExpense(expense, widget.group.id);

      setState(() {
        _expenses = _databaseHelper.getExpenses(widget.group.id); // Refresh expenses
      });

      // Clear form
      _descriptionController.clear();
      _amountController.clear();
      _selectedMember = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wydatki - ${widget.group.country}')),
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

            // PODSUMOWANIE: zlicz kwoty dla każdej osoby
            Map<String, double> summary = {};
            for (var expense in expenses) {
              final name = expense.person.name;
              summary[name] = (summary[name] ?? 0) + expense.amount;
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summary.entries.map((entry) {
                      return Text(
                        '${entry.key}: ${entry.value.toStringAsFixed(2)} zł',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(expenses[index].description),
                        subtitle: Text(
                          '${expenses[index].person.name}: ${expenses[index].amount.toStringAsFixed(2)} zł',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // TODO: edycja
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                //_deleteExpense(expenses[index].id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Dodaj wydatek'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Opis'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Wprowadź opis';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<Member>(
                        value: _selectedMember,
                        decoration: InputDecoration(labelText: 'Osoba'),
                        items: widget.group.members
                            .map((member) => DropdownMenuItem(
                          value: member,
                          child: Text(member.name),
                        ))
                            .toList(),
                        onChanged: (member) {
                          setState(() {
                            _selectedMember = member;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Wybierz osobę';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(labelText: 'Kwota'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Wprowadź kwotę';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Wprowadź poprawną kwotę';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Anuluj'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _addExpense();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Dodaj'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Dodaj wydatek',
      ),
    );
  }
}