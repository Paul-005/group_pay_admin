import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_pay_admin/controllers/navbar.controller.dart'; // Import your BottomNavScreen

class EditUpiIdPage extends StatefulWidget {
  const EditUpiIdPage({Key? key}) : super(key: key);

  @override
  State<EditUpiIdPage> createState() => _EditUpiIdPageState();
}

class _EditUpiIdPageState extends State<EditUpiIdPage> {
  final TextEditingController _upiController = TextEditingController();
  bool _isValidUpi = false;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  void _validateUpi(String value) {
    final RegExp upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+$');
    setState(() {
      _isValidUpi = upiRegex.hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bank Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/google_pay.png', // Replace with your asset path
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Change your Google Pay UPI ID',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will be used for receiving payments in GroupPay',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _upiController,
                  onChanged: _validateUpi,
                  decoration: InputDecoration(
                    labelText: 'UPI ID',
                    hintText: 'example@okicici',
                    prefixIcon: const Icon(Icons.account_balance),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your UPI ID in the format username@bank',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isValidUpi
                      ? () async {
                          final upiId = _upiController.text;

                          try {
                            User? user = FirebaseAuth.instance.currentUser;

                            await FirebaseFirestore.instance
                                .collection('admin')
                                .doc(user?.uid)
                                .update({
                              'bank_upi': upiId,
                              'profile_completed': 2
                            });

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomNavScreen()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error adding UPI ID: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Change UPI ID',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
