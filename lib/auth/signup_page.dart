import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SignupPage extends StatefulWidget {
  final VoidCallback? onLoginPressed;
  const SignupPage({super.key, this.onLoginPressed});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  String errorMessage = '';
  bool inputIsValid = true;

  Future<void> _signUp() async {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      try {
        // Get current user from Firebase Auth
        User? user = FirebaseAuth.instance.currentUser;

        // Generate random 6-digit number
        Random random = Random();
        int randomNumber = 100000 +
            random.nextInt(900000); // Generates between 100000 and 999999

        // Get current timestamp
        Timestamp createdAt = Timestamp.now();

        // Create the document data
        Map<String, dynamic> userData = {
          'adminCode': randomNumber,
          'bank_upi': '',
          'createdAt': createdAt,
          'email': user?.email,
          'profile_completed': 1,
          'uid': user?.uid,
        };

        // Add the document to Firestore
        await FirebaseFirestore.instance
            .collection('admin')
            .doc(user?.uid)
            .set(userData);

        // add the group code to groups db
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(randomNumber.toString())
            .set({
          'admin': user?.uid,
          'students': [],
          'student_requests': [],
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString()),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Account created successfully!'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.message ?? 'An unknown error occurred.'),
        ),
      );
      setState(() {
        inputIsValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 60.0),
                  const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Create your account",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                        hintText: "Username",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none),
                        fillColor: Colors.deepPurple.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.person)),
                    onChanged: (value) {
                      setState(() {
                        username = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      fillColor: Colors.deepPurple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        confirmPassword = value;
                      });
                    },
                  ),
                ],
              ),
              Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: ElevatedButton(
                    onPressed: () {
                      if (email.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Enter email and password'),
                          ),
                        );
                        return;
                      } else {
                        _signUp();
                      }
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                    ),
                  )),
              TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        if (widget.onLoginPressed != null) {
                          widget.onLoginPressed!();
                        }
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.deepPurple),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
