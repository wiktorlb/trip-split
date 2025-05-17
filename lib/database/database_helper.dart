import 'dart:convert';  // Dla konwersji na JSON
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '/models.dart';
import 'package:collection/collection.dart';


class DatabaseHelper {
  static Database? _database;

  // Database Initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Create Database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'trip_database.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // Create Tables in Database
  Future<void> _onCreate(Database db, int version) async {
    // Groups Table
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        country TEXT,
        currency TEXT,
        members TEXT  -- Zmieniamy na TEXT do przechowywania JSON
      );
    ''');

    // Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER,
        description TEXT,
        person TEXT,
        amount REAL,
        FOREIGN KEY(group_id) REFERENCES groups(id)
      );
    ''');
  }

  // Migrate Database (Update)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {

    }
  }

  // Clear tables
  Future<void> clearAllTables() async {
    final db = await database; // Load Database

    // Clear Gruops and Expenses
    await db.delete('groups');
    await db.delete('expenses');
  }
  // Add Table Group
  insertGroup(TravelGroup group) async {
    final db = await database;

    // Member Objects Converted to String
    final membersString = group.members.map((member) => member.name).join(',');

    await db.insert(
      'groups',
      {
        'country': group.country,
        'currency': group.currency,
        'members': membersString,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Add Expense
  Future<void> insertExpense(Expense expense, int groupId) async {
    final db = await database;
    await db.insert(
      'expenses',
      {
        'group_id': groupId,
        'description': expense.description,
        'person': expense.person.name,
        'amount': expense.amount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get Gruops
  Future<List<TravelGroup>> getGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> groupMaps = await db.query('groups');
    List<TravelGroup> groups = [];

    for (var groupMap in groupMaps) {
      var expenses = await getExpenses(groupMap['id']);
      groups.add(
        TravelGroup(
          id: groupMap['id'],
          country: groupMap['country'],
          currency: groupMap['currency'],
          expenses: expenses,
          members: (groupMap['members'] ?? '')
              .toString()
              .split(',')
              .mapIndexed((index, name) => Member(id: index, name: name.trim()))
              .toList(),
        ),
      );
    }

    return groups;
  }

  // Delete Gruops
  Future<void> deleteGroup(int groupId) async {
    final db = await database;
    
    await db.delete(
      'expenses',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );

    await db.delete(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }


  // Get group's expenses
  Future<List<Expense>> getExpenses(int groupId) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );

    return List.generate(result.length, (i) {
      final row = result[i];
      return Expense(
        id: row['id'] != null ? row['id'] as int : 0,
        description: row['description'] as String,
        person: Member(name: row['person'] as String),
        amount: row['amount'] is int ? (row['amount'] as int).toDouble() : row['amount'] as double,
      );
    });

  }

  // Update Expense
  Future<void> updateExpense(Expense expense, int groupId) async {
    final db = await database;
    await db.update(
      'expenses',
      {
        'description': expense.description,
        'amount': expense.amount,
        'group_id': groupId,
      },
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete Expense
  Future<void> deleteExpense(int expenseId) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [expenseId],
    );
  }
}
