/*
* Models
* Contains classes of database
* and dynamic classes used in project
* */

class TravelGroup {
  int id;
  String country;
  String currency;
  List<Expense> expenses;
  final List<Member> members;

  TravelGroup({
    required this.id,
    required this.country,
    required this.currency,
    List<Expense>? expenses,
    this.members = const [],
  }) : expenses = expenses ?? [];
}


class Expense {
  String description;
  Member person;
  double amount;
  final int? id;
  final List<Member>? members;

  Expense({
    required this.description,
    required this.person,
    required this.amount,
    this.id,
    this.members,
  });
}

class Member {
  final int? id;
  String name;

  Member({
    this.id,
    required this.name
  });
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Member && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

