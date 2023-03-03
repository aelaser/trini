// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:trini/constants/routes.dart';
import 'package:trini/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  _VerifyEmailViewState createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("verify Email"),
      ),
      body: Column(
        children: [
          const Text(
              "We have sent you an email verification. Please open it to verify your account"),
          const Text(
              "If you haven't receieved a verfication email yet, press the button below"),
          TextButton(
            onPressed: () async {
              // user cannot be null
              AuthService.firebase().sendEmailVerification();
            },
            child: const Text("Send email verification"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
