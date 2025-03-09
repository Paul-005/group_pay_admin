import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:group_pay_admin/auth/add_bank.dart';
import 'package:group_pay_admin/controllers/login_signup.auth.controller.dart';
import 'package:group_pay_admin/controllers/navbar.controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return AuthController();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return _buildLoggedInContent(snapshot.data!);
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildLoggedInContent(User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('admin')
          .doc(user.uid)
          .snapshots(), // Use snapshots() for real-time updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final profileCompleted = data?['profile_completed'] as int?;

          if (profileCompleted == 1) {
            return AddUpiIdPage();
          } else {
            return BottomNavScreen();
          }
        } else {
          return BottomNavScreen();
        }
      },
    );
  }
}
