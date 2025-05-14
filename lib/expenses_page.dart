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
  Member? _selectedMember;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _expenses = _databaseHelper.getExpenses(widget.group.id);
  }

  void _addExpense() async {
    if (_formKey.currentState!.validate() && _selectedMember != null) {
      final expense = Expense(
        description: _descriptionController.text,
        person: _selectedMember!,
        amount: double.parse(_amountController.text),
      );
      await _databaseHelper.insertExpense(expense, widget.group.id);

      setState(() {
        _expenses = _databaseHelper.getExpenses(widget.group.id);
      });

      _clearForm();
    }
  }

  void _clearForm() {
    _descriptionController.clear();
    _amountController.clear();
    _selectedMember = null;
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
            final expenses = snapshot.data!;
            final summary = <String, double>{};

            for (var e in expenses) {
              summary[e.person.name] = (summary[e.person.name] ?? 0) + e.amount;
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
                      final expense = expenses[index];
                      return ListTile(
                        title: Text(expense.description),
                        subtitle: Text('${expense.person.name}: ${expense.amount.toStringAsFixed(2)} zł'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editExpense(expense),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _confirmDelete(expense),
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
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        tooltip: 'Dodaj wydatek',
      ),
    );
  }

  void _showAddDialog() {
    _clearForm();

    showDialog(
      context: context,
      builder: (context) {
        return _buildExpenseDialog(
          title: 'Dodaj wydatek',
          onConfirm: () {
            if (_formKey.currentState!.validate()) {
              _addExpense();
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  void _editExpense(Expense expense) {
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _selectedMember = widget.group.members.firstWhere(
          (m) => m.id == expense.person.id,
      orElse: () => widget.group.members.first,
    );

    showDialog(
      context: context,
      builder: (context) {
        return _buildExpenseDialog(
          title: 'Edytuj wydatek',
          onConfirm: () async {
            if (_formKey.currentState!.validate()) {
              final updatedExpense = Expense(
                id: expense.id,
                description: _descriptionController.text,
                amount: double.parse(_amountController.text),
                person: _selectedMember!,
              );
              await _databaseHelper.updateExpense(updatedExpense, widget.group.id);
              setState(() {
                _expenses = _databaseHelper.getExpenses(widget.group.id);
              });
              _clearForm();
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  void _confirmDelete(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Potwierdź usunięcie'),
        content: Text('Czy na pewno chcesz usunąć ten wydatek?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Anuluj'),
          ),
          TextButton(
            onPressed: () async {
              if (expense.id != null) {
                await _databaseHelper.deleteExpense(expense.id!);
                setState(() {
                  _expenses = _databaseHelper.getExpenses(widget.group.id);
                });
              }
              Navigator.of(context).pop();
            },
            child: Text('Usuń'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDialog({required String title, required VoidCallback onConfirm}) {
    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Opis'),
              validator: (value) => value == null || value.isEmpty ? 'Wprowadź opis' : null,
            ),
            DropdownButtonFormField<Member>(
              value: _selectedMember,
              decoration: InputDecoration(labelText: 'Osoba'),
              items: widget.group.members.map((member) {
                return DropdownMenuItem(value: member, child: Text(member.name));
              }).toList(),
              onChanged: (member) => setState(() => _selectedMember = member),
              validator: (value) => value == null ? 'Wybierz osobę' : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Kwota'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wprowadź kwotę';
                if (double.tryParse(value) == null) return 'Wprowadź poprawną kwotę';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Anuluj'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text('Zapisz'),
        ),
      ],
    );
  }
}
