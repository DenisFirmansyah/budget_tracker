import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/expense_data.dart';
import '../models/expense_item.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseData()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExpenseData>(
        builder: (context, expenseData, child) {
          final totalIncome = expenseData.getTotalIncome();
          final totalExpense = expenseData.getTotalExpense();
          final balance = totalIncome - totalExpense;

          String formatCurrency(double value) {
            return NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(value);
          }

          return ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF00D09E),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Halo, Selamat Datang",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Yuk Berhemat Kawan",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Total Uang Anda :",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(balance),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SummaryCard(
                          label: "PEMASUKAN",
                          amount: totalIncome,
                          color: Colors.green,
                        ),
                        SummaryCard(
                          label: "PENGELUARAN",
                          amount: totalExpense,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Riwayat Transaksi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...expenseData.getAllExpenseList().map((expense) =>
                        ListTile(
                          leading: Icon(
                            expense.isIncome
                                ? Icons.arrow_circle_down // Ikon untuk pemasukan
                                : Icons.arrow_circle_up, // Ikon untuk pengeluaran
                            color:
                                expense.isIncome ? Colors.green : Colors.red,
                          ),
                          title: Text(expense.name),
                          subtitle: Text(
                            "${expense.dateTime.hour}:${expense.dateTime.minute} - ${expense.dateTime.day}/${expense.dateTime.month}/${expense.dateTime.year}",
                          ),
                          trailing: Text(
                            formatCurrency(double.parse(expense.amount)),
                            style: TextStyle(
                              color:
                                  expense.isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddExpenseDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String formatCurrency(double value) {
      return NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(value);
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(amount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AddExpenseDialog extends StatefulWidget {
  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  String transactionType = 'Income';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Transaksi Baru"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: transactionType,
            onChanged: (value) {
              setState(() {
                transactionType = value!;
              });
            },
            items: const [
              DropdownMenuItem(
                value: 'Income',
                child: Text("Pemasukan"),
              ),
              DropdownMenuItem(
                value: 'Outcome',
                child: Text("Pengeluaran"),
              ),
            ],
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Nama Transaksi"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Jumlah (Rp)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Batal"),
        ),
        TextButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                amountController.text.isNotEmpty) {
              final expense = ExpenseItem(
                userId: FirebaseAuth.instance.currentUser!.uid,
                id: '',
                name: nameController.text,
                amount: amountController.text,
                dateTime: DateTime.now(),
                isIncome: transactionType == 'Income',
              );
              Provider.of<ExpenseData>(context, listen: false).addNewExpense(expense);
              Navigator.pop(context);
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
