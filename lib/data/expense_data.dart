import 'package:budget_tracker/data/hive_database.dart';
import 'package:budget_tracker/datetime/date_time_helper.dart';
import 'package:budget_tracker/models/expense_item.dart';
import 'package:flutter/material.dart';

class ExpenseData extends ChangeNotifier {
  // list of ALl expenses
  List<ExpenseItem> overallExpenseList = [];

  // get expense list
  List<ExpenseItem> getAllExpenseList() {
    return overallExpenseList;
  }

  // prepare data to display
  final db = HiveDataBase();
  void prepareData() {
    // if there exists data, get it
    if (db.readData().isNotEmpty) {
      overallExpenseList = db.readData();
    }
  }

  // add new expense
  void addNewExpense(ExpenseItem newExpense) {
    overallExpenseList.add(newExpense);

    notifyListeners();
    db.saveData(overallExpenseList);
  }

  // delete expense
  void deleteExpense(ExpenseItem Expense) {
    overallExpenseList.remove(Expense);

    notifyListeners();
    db.saveData(overallExpenseList);
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

  Map<String, double> calculateDailyExpenseSummary() {
    Map<String, double> dailyExpenseSummary = {
      // date (yyyymmdd) : amountTotalForDay
    };

    for (var expense in overallExpenseList) {
      String date = convertDateTimeToString(expense.dateTime);
      double amount = double.parse(expense.amount);

      if (dailyExpenseSummary.containsKey(date)) {
        double currentAmount = dailyExpenseSummary[date]!;
        currentAmount += amount;
        dailyExpenseSummary[date] = currentAmount;
      } else {
        dailyExpenseSummary.addAll({date: amount});
      }
    }

    return dailyExpenseSummary;
  }
}
