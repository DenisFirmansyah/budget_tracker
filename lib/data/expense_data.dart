import 'package:budget_tracker/datetime/date_time_helper.dart';
import 'package:budget_tracker/models/expense_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpenseData extends ChangeNotifier {
  // Referensi ke koleksi Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  
  // list of ALl expenses
  List<ExpenseItem> overallExpenseList = [];

  // get expense list
  List<ExpenseItem> getAllExpenseList() {
    return overallExpenseList;
  }

  ExpenseData() {
    fetchExpenses(); // Ambil data saat ExpenseData diinisialisasi
  }

  // Ambil daftar pengeluaran dari Firestore
  Future<void> fetchExpenses() async {
    try {
      final snapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .get();
      overallExpenseList = snapshot.docs.map((doc) {
        final data = doc.data();
        return ExpenseItem(
          userId: data['userId'],
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

  // Tambahkan pengeluaran baru
  Future<void> addNewExpense(ExpenseItem expense) async {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Ambil userId
    if (userId != null) {
      final newExpense = expense.copyWith(userId: userId); // Tambahkan userId ke item
      await FirebaseFirestore.instance.collection('expenses').add({
        'userId': userId,
        'id' : newExpense.id,
        'name': newExpense.name,
        'amount': newExpense.amount,
        'date': newExpense.dateTime.toIso8601String(),
        'isIncome': newExpense.isIncome,
      });
      
      overallExpenseList.add(newExpense);
      notifyListeners();
    } else {
      throw Exception('User not authenticated');
    }
  }

  // Perbarui pengeluaran
  Future<void> updateExpense(ExpenseItem expense, Map<String, dynamic> updatedData) async {
    try {
      // Pastikan tidak mengirimkan data 'date' jika tidak ada perubahan pada tanggal
      if (updatedData.containsKey('date')) {
        updatedData.remove('date');  // Hapus 'date' dari data yang akan diperbarui
      }

      // Perbarui data di Firestore
      await _firestore.collection('expenses').doc(expense.id).update(updatedData);

      // Perbarui data di daftar lokal
      final index = overallExpenseList.indexWhere((item) => item.id == expense.id);
      if (index != -1) {
        overallExpenseList[index] = ExpenseItem(
          userId: expense.userId,
          id: expense.id,
          name: updatedData['name'] ?? expense.name,
          amount: updatedData['amount'] ?? expense.amount,
          dateTime: expense.dateTime,
          isIncome: updatedData['isIncome'] ?? expense.isIncome,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating expense: $e');
    }
  }

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
