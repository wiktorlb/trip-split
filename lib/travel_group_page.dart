import 'package:flutter/material.dart';
import 'group_list_page.dart';
import 'create_group_page.dart';
import 'database/database_helper.dart';

/*
* Travel Group
* Main Page allows users to choose next action
* Add New Group or Group List or Clear Data
* */

class TravelGroupPage extends StatelessWidget {

  Future<void> _clearAllTables() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    await databaseHelper.clearAllTables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TRIP-SPLIT')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateGroupPage()),
              );
            },
            child: Text('Utwórz nową grupę'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupListPage()),
              );
            },
            child: Text('Pokaż grupy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _clearAllTables();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TravelGroupPage()),
              );
            },
            child: Text('Wyczyść dane'),
          ),
        ],
      ),
    );
  }
}
