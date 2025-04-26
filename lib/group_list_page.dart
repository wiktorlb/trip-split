import 'package:flutter/material.dart';
import 'models.dart';
import 'database/database_helper.dart';
import 'expenses_page.dart';

class GroupListPage extends StatelessWidget {
  late DatabaseHelper _databaseHelper;

  @override
  Widget build(BuildContext context) {
    _databaseHelper = DatabaseHelper();
    return Scaffold(
      appBar: AppBar(title: Text('Grupy podróży')),
      body: FutureBuilder<List<TravelGroup>>(
        future: _databaseHelper.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Brak grup.'));
          } else {
            List<TravelGroup> groups = snapshot.data!;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(groups[index].country),
                  subtitle: Text(groups[index].currency),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpensePage(group: groups[index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}