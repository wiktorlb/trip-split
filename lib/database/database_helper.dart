import 'dart:convert';  // Dla konwersji na JSON
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '/models.dart';
import 'package:collection/collection.dart';


class DatabaseHelper {
  static Database? _database;

  // Inicjalizacja bazy danych
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Tworzenie bazy danych
  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'trip_database.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // Tworzenie tabel w bazie danych
  Future<void> _onCreate(Database db, int version) async {
    // Tworzenie tabeli dla grup
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        country TEXT,
        currency TEXT,
        members TEXT  -- Zmieniamy na TEXT do przechowywania JSON
      );
    ''');

    // Tworzenie tabeli dla wydatków
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

  // Funkcja migracji
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Można dodać kolejne operacje migracji, np. zmiana struktury tabel
    }
  }

  // Funkcja czyszcząca dane z wszystkich tabel
  Future<void> clearAllTables() async {
    final db = await database; // Załaduj bazę danych

    // Wyczyszczenie wszystkich tabel
    await db.delete('groups');  // Usuwamy dane z tabeli 'groups'
    await db.delete('expenses');  // Usuwamy dane z tabeli 'expenses'
    // Jeżeli masz tabelę 'members', dodaj ją tutaj
    // await db.delete('members');
  }
  // Dodawanie grupy
  insertGroup(TravelGroup group) async {
    final db = await database;

    // Zamiana listy obiektów Member na listę stringów
    final membersString = group.members.map((member) => member.name).join(',');

    await db.insert(
      'groups',
      {
        'country': group.country,
        'currency': group.currency,
        'members': membersString, // Zapisujemy tylko imiona członków
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Dodawanie wydatku
  Future<void> insertExpense(Expense expense, int groupId) async {
    final db = await database;
    await db.insert(
      'expenses',
      {
        'group_id': groupId,
        'description': expense.description,
        'person': expense.person.name,  // Zapisujemy tylko nazwisko osoby
        'amount': expense.amount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Pobieranie wszystkich grup
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


  // Pobieranie wydatków dla grupy
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
        id: row['id'] != null ? row['id'] as int : 0, // lub lepiej: null jeśli `id` jest nullable
        description: row['description'] as String,
        person: Member(name: row['person'] as String),
        amount: row['amount'] is int ? (row['amount'] as int).toDouble() : row['amount'] as double,
      );
    });

  }

  // Aktualizowanie wydatku
  Future<void> updateExpense(Expense expense, int groupId) async {
    final db = await database;
    await db.update(
      'expenses',
      {
        'description': expense.description,
        'amount': expense.amount,
        // 'person_id': expense.person.id,
        'group_id': groupId,
      },
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Usuwanie wydatku
  Future<void> deleteExpense(int expenseId) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [expenseId],
    );
  }
}
