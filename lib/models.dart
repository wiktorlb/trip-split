// class TravelGroup {
//   int id;
//   String country;
//   String currency;
//   List<Expense> expenses;
//
//   final List<String>? members; //TEST
//
//   TravelGroup({required this.id, required this.country, required this.currency, List<Expense>? expenses, this.members})
//       : expenses = expenses ?? [];
// }

class TravelGroup {
  int id;
  String country;
  String currency;
  List<Expense> expenses;
  //final List<String> members; // Lista członków (nie nullable)
  final List<Member> members; // Lista członków, którzy mają nazwę

  TravelGroup({
    required this.id,
    required this.country,
    required this.currency,
    List<Expense>? expenses,
    this.members = const [], // Domyślnie pusta lista
  }) : expenses = expenses ?? [];
}


class Expense {
  String description;
  Member person; // Typ Member
  double amount;
  final int? id;
  final List<Member>? members; // Lista członków (obiektów Member)

  Expense({
    required this.description,
    required this.person, // Tutaj oczekujemy obiektu Member
    required this.amount,
    this.id,
    this.members,
  });
}

class Member {
  String name;

  Member({required this.name});
}
// class Group {
//   List<Member> members;
//
//   Group({this.members = const []});  // Dodajemy pustą listę jako domyślną wartość
// }
