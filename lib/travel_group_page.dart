import 'package:flutter/material.dart';
import 'group_list_page.dart';
import 'create_group_page.dart';
import 'database/database_helper.dart';

class TravelGroupPage extends StatelessWidget {
  // Funkcja do czyszczenia tabel w bazie danych
  Future<void> _clearAllTables() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.clearAllTables();  // Wywołanie metody z DatabaseHelper
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
              await _clearAllTables();  // Wywołanie funkcji do czyszczenia tabel
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
