import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  bool inputIsValid = true;

  Future<void> _saveProfile() async {
    // update user name and lhone number in firebase
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user!.updateDisplayName('$firstName $lastName');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Profile updated successfully!'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.message ?? 'An unknown error occurred.'),
        ),
      );
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
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Update your personal information",
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
                      hintText: "First Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: inputIsValid
                            ? BorderSide.none
                            : const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: inputIsValid
                            ? BorderSide.none
                            : const BorderSide(color: Colors.red, width: 2),
                      ),
                      fillColor: inputIsValid
                          ? Colors.purple.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: inputIsValid ? Colors.grey : Colors.red,
                      ),
                      // Optional: Add error text below the field
                      errorText: inputIsValid ? null : 'Invalid input',
                    ),
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: TextStyle(
                      color: inputIsValid ? Colors.black : Colors.red,
                    ),
                    decoration: InputDecoration(
                      hintText: "Last Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // TextField(
                  //   style: TextStyle(
                  //     color: inputIsValid ? Colors.black : Colors.red,
                  //   ),
                  //   decoration: InputDecoration(
                  //     hintText: "Phone Number",
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(18),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //     fillColor: Colors.purple.withOpacity(0.1),
                  //     filled: true,
                  //     prefixIcon: const Icon(Icons.phone),
                  //   ),
                  //   keyboardType: TextInputType.phone,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       phoneNumber = value;
                  //     });
                  //   },
                  // ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 3, left: 3),
                child: ElevatedButton(
                  onPressed: () {
                    if (firstName.isEmpty ||
                        lastName.isEmpty ||
                        phoneNumber.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Please fill in all fields'),
                        ),
                      );
                      return;
                    } else {
                      _saveProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.purple, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
