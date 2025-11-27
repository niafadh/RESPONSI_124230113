import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userC = TextEditingController();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();

    final existingEmail = prefs.getString('email');
    final newUser = _userC.text.trim();
    final newEmail = _emailC.text.trim();

    // Jika email sudah terdaftar, beri tahu user untuk login saja.
    // Username boleh sama (diperbolehkan oleh permintaan pengguna).
    if (existingEmail != null && existingEmail == newEmail) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Email already registered'),
          content: const Text('Email tersebut sudah terdaftar. Silakan login menggunakan email atau username Anda.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
      return;
    }

    // Simpan akun baru dan tandai logged in
    await prefs.setString('username', newUser);
    await prefs.setString('email', newEmail);
    await prefs.setString('password', _passC.text);
    await prefs.setBool('is_logged_in', true);

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
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
                const Icon(
                  Icons.newspaper_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),

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
                              "Register",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),

                            const SizedBox(height: 20),

                            TextFormField(
                              controller: _userC,
                              decoration: _input("Username"),
                              validator: (v) =>
                                  v!.trim().isEmpty ? 'Enter username' : null,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _emailC,
                              decoration: _input("Email"),
                              validator: (v) {
                                if (v!.trim().isEmpty) return "Enter email";
                                if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v)) {
                                  return "Invalid email";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _passC,
                              obscureText: true,
                              decoration: _input("Password"),
                              validator: (v) =>
                                  v!.length < 4 ? "Password >= 4 chars" : null,
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _register,
                                style: _button(),
                                child: const Text("Register & Login"),
                              ),
                            ),

                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                              child: const Text(
                                "Already have account? Login",
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

  InputDecoration _input(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFF3E0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  ButtonStyle _button() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFA000),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
