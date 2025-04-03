import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> sendGroupNotification({
    required String title,
    required String description,
    required String groupCode,
    String amount = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.10:3000/send-group-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'amount': amount,
          'groupCode': groupCode,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
      } else {
        print('Error sending notification: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _descriptionController.text.isNotEmpty) {
      // Get the values from the form
      String title = _titleController.text;
      String description = _descriptionController.text;
      double amount = double.parse(_amountController.text);
      DateTime lastDate = _selectedDate!;
      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Get the admin document from the 'admins' collection
      DocumentSnapshot adminDoc =
          await FirebaseFirestore.instance.collection('admin').doc(uid).get();

      // Get the adminCode and bank_upi from the document
      String adminCode = adminDoc['adminCode'].toString();
      String bankUpi = adminDoc['bank_upi'].toString();

      // Get the group document and accepted students
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(adminCode)
          .get();

      // Get all accepted students from admin document
      List<dynamic> acceptedStudents = adminDoc['students'] ?? [];

      // Create unpaid array with all accepted students
      List<Map<String, dynamic>> unpaidStudents = acceptedStudents
          .map((student) => {
                'email': student['email'],
                'uid': student['uid'],
              })
          .toList();

      String noOfStudents = acceptedStudents.length.toString();

      // Generate a unique ID for the post
      String postId = FirebaseFirestore.instance.collection('posts').doc().id;

      // Create a new post document in the 'posts' collection
      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'postId': postId,
        'title': title,
        'description': description,
        'amount': amount,
        'lastDate': lastDate,
        'createdAt': DateTime.now(),
        'createdBy': FirebaseAuth.instance.currentUser!.uid,
        'status': 'active',
        'adminCode': adminCode,
        'paid': [],
        'unpaid': unpaidStudents,
        'confirm': [],
        'bank_upi': bankUpi,
        'no_of_students': noOfStudents,
      });

      // Update the 'groups' collection
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(adminCode)
          .update({
        'posts': FieldValue.arrayUnion([
          {
            'postId': postId,
            'title': title,
            'amount': amount,
            'description': description,
            'adminCode': adminCode,
            'lastDate': lastDate,
            'no_of_students': noOfStudents,
          }
        ])
      });

      // Send a notification to all accepted students
      await sendGroupNotification(
        title: title,
        description: description,
        groupCode: adminCode,
        amount: amount.toString(),
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post created successfully!'),
        ),
      );

      // Navigate to the manage students screen
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Create Collection',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputCard(
                      title: 'Collection Title',
                      hint: 'Enter collection title',
                      icon: Icons.title,
                      controller: _titleController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildInputCard(
                      title: 'Amount per Person',
                      hint: 'Enter amount',
                      icon: Icons.currency_rupee,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixText: 'Rs. ',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter an amount';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.deepPurple,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Last Date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDate != null
                                          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                          : "Select last date",
                                      style: TextStyle(
                                        color: _selectedDate != null
                                            ? Colors.black
                                            : Colors.grey[400],
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_month,
                                      color: Colors.deepPurple,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInputCard(
                      title: 'Description',
                      hint: 'Enter collection description',
                      icon: Icons.description,
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _submitForm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.post_add,
                              size: 24,
                              color: Colors.white,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    String? prefixText,
    int maxLines = 1,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Colors.deepPurple,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: controller,
              validator: validator,
              maxLines: maxLines,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixText: prefixText,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
