import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'travel_group_page.dart';
import 'database/database_helper.dart';

void main() async{
  // Sprawdzamy, czy aplikacja jest uruchamiana na platformie web
  if (kIsWeb) {
    // Dla platformy web używamy sqflite_common_ffi_web
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Dla innych platform (Android, iOS) używamy sqflite_common_ffi
    databaseFactory = databaseFactoryFfi;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TravelGroupPage(),
    );
  }
}
