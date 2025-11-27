import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: const EntryDecider(),
      routes: {
        '/home': (ctx) => const HomePage(),
        '/login': (ctx) => const LoginPage(),
        '/register': (ctx) => const RegisterPage(),
      },
    );
  }
}

 

/// Decide whether user is already logged in (SharedPreferences)
class EntryDecider extends StatefulWidget {
  const EntryDecider({super.key});
  @override
  State<EntryDecider> createState() => _EntryDeciderState();
}

class _EntryDeciderState extends State<EntryDecider> {
  Future<bool> checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Use explicit login flag so app can remember session across restarts
    return prefs.getBool('is_logged_in') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoggedIn(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data == true) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
