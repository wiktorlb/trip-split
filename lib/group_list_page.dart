import 'package:flutter/material.dart';
import 'models.dart';
import 'database/database_helper.dart';
import 'expenses_page.dart';

class GroupListPage extends StatefulWidget {
  @override
  _GroupListPageState createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late DatabaseHelper _databaseHelper;
  late Future<List<TravelGroup>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _groupsFuture = _databaseHelper.getGroups();
    });
  }

  void _confirmDeleteGroup(BuildContext context, TravelGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Usuń grupę'),
        content: Text('Czy na pewno chcesz usunąć grupę "${group.country}"?'),
        actions: [
          TextButton(
            child: Text('Anuluj'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Usuń'),
            onPressed: () async {
              await _databaseHelper.deleteGroup(group.id!);
              Navigator.of(context).pop();
              _loadGroups();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grupy podróży')),
      body: FutureBuilder<List<TravelGroup>>(
        future: _groupsFuture,
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
                final group = groups[index];
                return ListTile(
                  title: Text(group.country),
                  subtitle: Text('Waluta: ${group.currency}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteGroup(context, group),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpensePage(group: group),
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
