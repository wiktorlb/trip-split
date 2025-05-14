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
  final _membersController = TextEditingController();
  late DatabaseHelper _databaseHelper;
  List<Member> selectedMembers = [];
  int _nextMemberId = 1;

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
        members: selectedMembers,
      );
      await _databaseHelper.insertGroup(group);
      Navigator.pop(context);
    }
  }

  void _addMember() {
    final memberName = _membersController.text.trim();
    if (memberName.isNotEmpty &&
        !selectedMembers.any((member) => member.name == memberName)) {
      setState(() {
        selectedMembers.add(
          Member(id: _nextMemberId++, name: memberName),
        );
      });
      _membersController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Utwórz grupę')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // schowanie klawiatury po kliknięciu poza pole
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _countryController,
                  decoration: InputDecoration(labelText: 'Kraj'),
                ),
                TextField(
                  controller: _currencyController,
                  decoration: InputDecoration(labelText: 'Waluta'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _membersController,
                  decoration: InputDecoration(labelText: 'Dodaj członka'),
                  onSubmitted: (_) => _addMember(),
                ),
                ElevatedButton(
                  onPressed: _addMember,
                  child: Text('Dodaj członka'),
                ),
                SizedBox(height: 20),
                Text('Wybrani członkowie:'),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: selectedMembers.map((member) {
                    return Chip(
                      label: Text(member.name),
                      onDeleted: () {
                        setState(() {
                          selectedMembers.remove(member);
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _createGroup,
                    child: Text('Utwórz grupę'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
