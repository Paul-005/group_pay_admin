import 'package:flutter/material.dart';
import 'package:group_pay_admin/auth/forgot_password.dart';
import 'package:group_pay_admin/auth/login_page.dart';
import 'package:group_pay_admin/auth/signup_page.dart';

class AuthController extends StatefulWidget {
  const AuthController({Key? key}) : super(key: key);

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          LoginPage(),
          SignupPage(),
          ForgotPasswordPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_add), label: 'Signup'),
          BottomNavigationBarItem(
              icon: Icon(Icons.lock_reset), label: 'Forgot Password'),
        ],
      ),
    );
  }
}
