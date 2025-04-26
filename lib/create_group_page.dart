import 'package:flutter/material.dart';
import 'models.dart';
import 'database/database_helper.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _countryController = TextEditingController();
  final _currencyController = TextEditingController();
  final _membersController = TextEditingController();  // Pole tekstowe dla członków
  late DatabaseHelper _databaseHelper;
  List<Member> selectedMembers = [];  // Lista wybranych członków

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
  }

  _createGroup() async {
    final country = _countryController.text;
    final currency = _currencyController.text;

    if (country.isNotEmpty && currency.isNotEmpty && selectedMembers.isNotEmpty) {
      final group = TravelGroup(
        id: 0,
        country: country,
        currency: currency,
        members: selectedMembers,  // Lista obiektów Member
      );
      await _databaseHelper.insertGroup(group);
      Navigator.pop(context);
    }
  }

  // Funkcja, która dodaje członka do listy
  void _addMember() {
    final memberName = _membersController.text.trim();
    if (memberName.isNotEmpty && !selectedMembers.any((member) => member.name == memberName)) {
      setState(() {
        selectedMembers.add(Member(name: memberName));  // Dodajemy obiekt Member
      });
      _membersController.clear();  // Czyścimy pole po dodaniu członka
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Utwórz grupę')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _countryController, decoration: InputDecoration(labelText: 'Kraj')),
            TextField(controller: _currencyController, decoration: InputDecoration(labelText: 'Waluta')),
            SizedBox(height: 20),
            TextField(
              controller: _membersController,
              decoration: InputDecoration(labelText: 'Dodaj członka'),
            ),
            ElevatedButton(
              onPressed: _addMember,
              child: Text('Dodaj członka'),
            ),
            SizedBox(height: 20),
            Text('Wybrani członkowie:'),
            // Wyświetlanie wybranych członków
            Wrap(
              children: selectedMembers.map((member) {
                return Chip(
                  label: Text(member.name),  // Wyświetlamy nazwisko członka
                  onDeleted: () {
                    setState(() {
                      selectedMembers.remove(member);  // Usuwamy członka
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _createGroup, child: Text('Utwórz grupę')),
          ],
        ),
      ),
    );
  }
}
