import 'package:budget_tracker/data/expense_data.dart';
import 'package:budget_tracker/datetime/date_time_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bar_graph/bar_graph.dart';

class ExpenseSummary extends StatelessWidget {
  final DateTime startOfWeek;
  const ExpenseSummary({
    super.key,
    required this.startOfWeek,
  });

  // calculate max amount in bar graph
  double calculateMax(
    ExpenseData value,
    String sunday,
    String monday,
    String tuesday,
    String wednesday,
    String thursday,
    String friday,
    String saturday,
  ) {
    double? max = 100;

    List<double> values = [
    value.calculateDailyExpenseSummary()[sunday]?['outcome'] ?? 0,
    value.calculateDailyExpenseSummary()[monday]?['outcome'] ?? 0,
    value.calculateDailyExpenseSummary()[tuesday]?['outcome'] ?? 0,
    value.calculateDailyExpenseSummary()[wednesday]?['outcome'] ?? 0,
    value.calculateDailyExpenseSummary()[thursday]?['outcome'] ?? 0,
    value.calculateDailyExpenseSummary()[friday]?['outcome'] ?? 0,
    value.calculateDailyExpenseSummary()[saturday]?['outcome'] ?? 0,
  ];


    // sort from smallest to largest
    values.sort();
    // get largest amount
    // and increase the cap slightly so te graph looks almost full
    max = values.last * 1.1;

    return max == 0 ? 100 : max;
  }

  // calculate the week total
  String calculateWeekTotal(
    ExpenseData value,
    String sunday,
    String monday,
    String tuesday,
    String wednesday,
    String thursday,
    String friday,
    String saturday,
  ) {
    List<double> values = [
      value.calculateDailyExpenseSummary()[sunday]?['outcome'] ?? 0,
      value.calculateDailyExpenseSummary()[monday]?['outcome'] ?? 0,
      value.calculateDailyExpenseSummary()[tuesday]?['outcome'] ?? 0,
      value.calculateDailyExpenseSummary()[wednesday]?['outcome'] ?? 0,
      value.calculateDailyExpenseSummary()[thursday]?['outcome'] ?? 0,
      value.calculateDailyExpenseSummary()[friday]?['outcome'] ?? 0,
      value.calculateDailyExpenseSummary()[saturday]?['outcome'] ?? 0,
    ];


    double total = 0;
    for (int i = 0; i < values.length; i++) {
      total += values[i];
    }

    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    //get yyyymmdd for each day of this week
    String sunday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 0)));
    String monday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 1)));
    String tuesday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 2)));
    String wednesday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 3)));
    String thursday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 4)));
    String friday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 5)));
    String saturday =
        convertDateTimeToString(startOfWeek.add(const Duration(days: 6)));

    return Consumer<ExpenseData>(
      builder: (context, value, child) => Column(
        children: [
          // week total
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                const Text(
                  'Week Total: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    'Rp.${calculateWeekTotal(value, sunday, monday, tuesday, wednesday, thursday, friday, saturday)}')
              ],
            ),
          ),

          // bar graph
          SizedBox(
            height: 200,
            child: MyBarGraph(
              maxY: calculateMax(value, sunday, monday, tuesday, wednesday, thursday, friday, saturday),
              sunAmount: value.calculateDailyExpenseSummary()[sunday]?['outcome'] ?? 0,
              monAmount: value.calculateDailyExpenseSummary()[monday]?['outcome'] ?? 0,
              tueAmount: value.calculateDailyExpenseSummary()[tuesday]?['outcome'] ?? 0,
              wedAmount: value.calculateDailyExpenseSummary()[wednesday]?['outcome'] ?? 0,
              thurAmount: value.calculateDailyExpenseSummary()[thursday]?['outcome'] ?? 0,
              friAmount: value.calculateDailyExpenseSummary()[friday]?['outcome'] ?? 0,
              satAmount: value.calculateDailyExpenseSummary()[saturday]?['outcome'] ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
