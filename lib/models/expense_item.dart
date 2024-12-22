class ExpenseItem {
  final String name;
  final String amount;
  final DateTime dateTime;
  final bool isIncome;

  ExpenseItem({
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.isIncome,
  });

  get id => null;
}
