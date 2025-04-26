import 'package:flutter/material.dart';
import 'models.dart';
import 'database/database_helper.dart';

class AddExpensePage extends StatefulWidget {
  final TravelGroup group;
  AddExpensePage({required this.group});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  Member? _selectedPerson;  // Zmieniamy z String na Member

  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
  }

  _addExpense() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final description = _descriptionController.text;
    final person = _selectedPerson;

    if (description.isEmpty || person == null || amount == 0) return;

    final member = person;  // <-- już jest typu Member

    final expense = Expense(
      description: description,
      person: member,
      amount: amount,
      members: widget.group.members,
    );

    await _databaseHelper.insertExpense(expense, widget.group.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj wydatek')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Kwota'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Opis wydatku'),
            ),
            SizedBox(height: 20),
            // Dodanie DropdownButton z listą członków
            if (widget.group.members.isNotEmpty)
              DropdownButton<Member>(
                value: _selectedPerson,
                hint: Text('Wybierz osobę'),
                isExpanded: true,
                items: widget.group.members.map((Member member) {
                  return DropdownMenuItem<Member>(
                    value: member,
                    child: Text(member.name),  // Wyświetlamy nazwisko
                  );
                }).toList(),
                onChanged: (Member? newValue) {
                  setState(() {
                    _selectedPerson = newValue;
                  });
                },
              ),
            if (widget.group.members.isEmpty)
              Text('Brak członków w grupie'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Dodaj wydatek'),
            ),
            SizedBox(height: 20),
            Text('Członkowie grupy:'),
            if (widget.group.members.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.group.members
                    .map((member) => Text('- ${member.name}'))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
