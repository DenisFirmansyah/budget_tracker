class ExpenseItem {
  final String id;
  final String name;
  final String amount;
  final DateTime dateTime;
  final bool isIncome;

  ExpenseItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.isIncome,
  });

  // Untuk menyalin item dengan perubahan
  ExpenseItem copyWith({
    String? id,
    String? name,
    String? amount,
    DateTime? dateTime,
    bool? isIncome,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
