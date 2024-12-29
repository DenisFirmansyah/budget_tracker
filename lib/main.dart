import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'data/expense_data.dart';
import 'pages/home_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCu_t0QLvOUKzb6oR6EskLpleUlkFpiAbw",
        authDomain: "budget-tracker-8bc39.firebaseapp.com",
        projectId: "budget-tracker-8bc39",
        storageBucket: "budget-tracker-8bc39.firebasestorage.app",
        messagingSenderId: "965263215869",
        appId: "1:965263215869:web:687a494cfd5d0a52e70294",
        measurementId: "G-JTN71QRT62"
      )
    );
  } else {
    await Firebase.initializeApp();
  }
  
  // // initialize hive
  // await Hive.initFlutter();

  // // open a hive box
  // await Hive.openBox("expense_database");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseData(),
      builder: (context, child) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
