import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:group_pay_admin/controllers/auth.controller.dart';
import 'package:group_pay_admin/home/post.dart';
import 'package:group_pay_admin/settings/profile.screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Pay Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/profile': (context) => ProfileScreen(),
        'new-post': (context) => CreatePostScreen(),
      },
      home: AuthGate(),
    );
  }
}
