import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCodePage extends StatefulWidget {
  const AdminCodePage({Key? key}) : super(key: key);

  @override
  State<AdminCodePage> createState() => _AdminCodePageState();
}

class _AdminCodePageState extends State<AdminCodePage> {
  // Generate a random 6-digit code for display
  bool _codeCopied = false;

  String? _adminCode = "000000";

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: _adminCode!));
    setState(() {
      _codeCopied = true;
    });

    // Reset the copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _codeCopied = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAdminCode();
  }

  Future<void> _fetchAdminCode() async {
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not logged in
      return;
    }

    // Get the document from Firestore
    final DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('admin')
        .doc(user.uid)
        .get();

    // If the document exists, get the adminCode
    if (adminDoc.exists) {
      setState(() {
        _adminCode = adminDoc.get('adminCode').toString();
      });
    } else {
      // Handle the case where the document does not exist
      // You might want to create a new document for the user
      print('Admin document does not exist for user ${user.uid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Your Admin Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share this code with your students to let them join your group.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...(_adminCode ?? '------').split('').map((digit) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 32,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              digit,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _adminCode != null ? _copyCodeToClipboard : null,
                  icon: Icon(_codeCopied ? Icons.check : Icons.copy),
                  label: Text(_codeCopied ? 'Copied!' : 'Copy Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _codeCopied ? Colors.green : Colors.white,
                    foregroundColor: _codeCopied
                        ? Colors.white
                        : Colors.indigo, // Corrected typo here
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_codeCopied)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Code copied to clipboard',
                      style: TextStyle(
                        color: Colors.green.shade100,
                        fontWeight: FontWeight.w500,
                      ),
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
