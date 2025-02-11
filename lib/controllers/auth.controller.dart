import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_pay_admin/auth/login_page.dart';
import 'package:group_pay_admin/home/student_list.dart';

class AuthController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginPage();
          } else {
            return StudentListScreen();
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
