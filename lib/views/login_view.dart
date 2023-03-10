// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:trini/constants/routes.dart';
import 'package:trini/services/auth/auth_exceptions.dart';
import 'package:trini/services/auth/auth_service.dart';

import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
          ),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                // Handling expections
                try {
                  await AuthService.firebase().logIn(
                    email: email,
                    password: password,
                  );
                  // To get current user
                  final user = AuthService.firebase().currentUser;
                  // Either returns true or false
                  if (user?.isEmailVerified ?? false) {
                    // user's email verified
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      dashboardRoute,
                      (route) => false,
                    );
                  } else {
                    // user's email not verified
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                    );
                  }
                } on UserNotFoundAuthException {
                  await showErrorDialog(
                    context,
                    "User not found",
                  );
                } on WrongPasswordAuthException {
                  await showErrorDialog(
                    context,
                    "Wrong credentials",
                  );
                } on GenericAuthException {
                  await showErrorDialog(
                    context,
                    "Authentication Error}",
                  );
                }
              },
              child:
                  const Text("Login", style: TextStyle(color: Colors.black87))),

          // Add register button, child param is always at the end
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not Registered yet? Register here!'))
        ],
      ),
    );
  }
  // Text editing controllers
}
