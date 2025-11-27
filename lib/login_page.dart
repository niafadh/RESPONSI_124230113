import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userC = TextEditingController();
  final TextEditingController _passC = TextEditingController();
  String _error = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    final storedPass = prefs.getString('password');

    if (storedEmail == null) {
      setState(() => _error = 'No account found. Please register first.');
      return;
    }

    final input = _userC.text.trim();
    // hanya terima email (case-insensitive)
    if (input.toLowerCase() == storedEmail.toLowerCase() && _passC.text == storedPass) {
      await prefs.setBool('is_logged_in', true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = 'Username or password incorrect.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFA000),
              Color(0xFFFFA000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ICON NEWS
                const Icon(
                  Icons.newspaper_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),

                // CARD BOX 
                Container(
                  width: 330,  
                  child: Card(
                    elevation: 10,
                    color: const Color(0xFFFFF8F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(20.0),

                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),

                            const SizedBox(height: 20),

                            TextFormField(
                              controller: _userC,
                              decoration: _input("Email"),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Enter email';
                                if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v.trim())) return 'Enter valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _passC,
                              obscureText: true,
                              decoration: _input("Password"),
                              validator: (v) =>
                                  v!.isEmpty ? "Enter password" : null,
                            ),

                            const SizedBox(height: 12),

                            if (_error.isNotEmpty)
                              Text(
                                _error,
                                style: const TextStyle(color: Colors.red),
                              ),

                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: _button(),
                                child: const Text("Login"),
                              ),
                            ),

                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                              child: const Text(
                                "Create new account",
                                style: TextStyle(color: Color(0xFFFFA000)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // INPUT STYLE
  InputDecoration _input(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFF3E0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  // BUTTON STYLE
  ButtonStyle _button() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFA000),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
