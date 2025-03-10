import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'TermPage.dart';
import 'LoginPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool agreeToTerms = false;

  // Controllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to handle user registration
  void createUserWithEmailAndPassword() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordMismatch)),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(_usernameController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.registrationSuccess)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(prefilledEmail: email, onLocaleChange: (Locale ) {  },),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? AppLocalizations.of(context)!.registrationFailed(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust screen when keyboard appears
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.register),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermPage()),
              );
            },
          ),
        ],
      ),
      body: Center( // Centers the form
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView( // Allows scrolling when keyboard appears
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                // Username TextField
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.userName,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                // Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                // Confirm Password TextField
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.confirmPassword,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                // Terms and Conditions Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          agreeToTerms = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.acceptTerms),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: agreeToTerms ? createUserWithEmailAndPassword : null,
                    child: Text(AppLocalizations.of(context)!.createAccount),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
