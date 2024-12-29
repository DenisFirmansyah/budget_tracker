import 'package:budget_tracker/data/hive_database.dart';
import 'package:budget_tracker/datetime/date_time_helper.dart';
import 'package:budget_tracker/models/expense_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseData extends ChangeNotifier {
  // Referensi ke koleksi Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // list of ALl expenses
  List<ExpenseItem> overallExpenseList = [];

  // get expense list
  List<ExpenseItem> getAllExpenseList() {
    return overallExpenseList;
  }

  // Ambil daftar pengeluaran dari Firestore
  Future<void> fetchExpenses() async {
    try {
      final snapshot = await _firestore.collection('expenses').get();
      overallExpenseList = snapshot.docs.map((doc) {
        final data = doc.data();
        return ExpenseItem(
          id: doc.id,
          name: data['name'] ?? '',
          amount: data['amount'].toString(),
          dateTime: DateTime.parse(data['date']),
          isIncome: data['isIncome'] ?? false,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }
  // prepare data to display
  // final db = HiveDataBase();
  // void prepareData() {
  //   // if there exists data, get it
  //   if (db.readData().isNotEmpty) {
  //     overallExpenseList = db.readData();
  //   }
  // }

  // Tambahkan pengeluaran baru
  Future<void> addNewExpense(ExpenseItem newExpense) async {
    try {
      final docRef = await _firestore.collection('expenses').add({
        'name': newExpense.name,
        'amount': newExpense.amount,
        'date': newExpense.dateTime.toIso8601String(),
        'isIncome': newExpense.isIncome,
      });
      // Tambahkan juga ke list lokal
      overallExpenseList.add(newExpense.copyWith(id: docRef.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding expense: $e');
    }
  }
  // void addNewExpense(ExpenseItem newExpense) {
  //   overallExpenseList.add(newExpense);

  //   notifyListeners();
  //   db.saveData(overallExpenseList);
  // }

  // Hapus pengeluaran
  Future<void> deleteExpense(ExpenseItem expense) async {
    try {
      await _firestore.collection('expenses').doc(expense.id).delete();
      overallExpenseList.removeWhere((item) => item.id == expense.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
    }
  }
  // void deleteExpense(ExpenseItem Expense) {
  //   overallExpenseList.remove(Expense);

  //   notifyListeners();
  //   db.saveData(overallExpenseList);
  // }

  // get weekday (mon, tues, etc) from datTime object
  String getDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thurs';
      case 5:
        return 'Fri';
      case 6:
        return 'Satur';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  // get the date for the start of the weel (sunday)
  DateTime startOfWeekDate() {
    DateTime? startOfWeek;

    // get todays date
    DateTime today = DateTime.now();

    // go backwards from todaay to find sunday
    for (int i = 0; i < 7; i++) {
      if (getDayName(today.subtract(Duration(days: i))) == 'Sun') {
        startOfWeek = today.subtract(Duration(days: i));
      }
    }

    return startOfWeek!;
  }

  /*

  convert overall list of expenses into a daily expense summmary

  e.g.

  overallExpenseList =
  [
  
  [ food, 2024/12/17, Rp.50000],
  [ hat, 2024/12/17, Rp.25000],
  [ drinks, 2024/12/17, Rp.20000],
  [ food, 2024/12/17, Rp.5000],
  [ food, 2024/12/17, Rp.6000],
  [ food, 2024/12/17, Rp.7000],

  ]

  ->

  DailyExpenseSummary = 


  [
  
  [ 2024/12/17: Rp.50000 ].
  [ 2024/12/17, Rp.25000 ].
  [ 2024/12/17, Rp.20000 ],
  [ 2024/12/17, Rp.5000 ],
  [ 2024/12/17, Rp.6000 ],
  [ 2024/12/17, Rp.7000 ],
  
  ]


  */

  Map<String, Map<String, double>> calculateDailyExpenseSummary() {
  Map<String, Map<String, double>> dailySummary = {};

  for (var expense in overallExpenseList) {
    String date = convertDateTimeToString(expense.dateTime);

    if (!dailySummary.containsKey(date)) {
      dailySummary[date] = {'income': 0, 'outcome': 0};
    }

    if (expense.isIncome) {
      dailySummary[date]!['income'] =
          dailySummary[date]!['income']! + double.parse(expense.amount);
    } else {
      dailySummary[date]!['outcome'] =
          dailySummary[date]!['outcome']! + double.parse(expense.amount);
    }
  }

  return dailySummary;
}


// Total pemasukan
double getTotalIncome() {
  double total = 0;
  for (var expense in overallExpenseList) {
    if (expense.isIncome) {
      total += double.parse(expense.amount);
    }
  }
  return total;
}

// Total pengeluaran
double getTotalExpense() {
  double total = 0;
  for (var expense in overallExpenseList) {
    if (!expense.isIncome) {
      total += double.parse(expense.amount);
    }
  }
  return total;
}

}
