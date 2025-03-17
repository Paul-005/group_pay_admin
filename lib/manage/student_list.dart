import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> students = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchStudentRequests();
  }

  Future<void> fetchStudentRequests() async {
    final User? user = _auth.currentUser;
    final String adminUid = user?.uid ?? 'null';

    DocumentSnapshot adminDoc =
        await _firestore.collection('admin').doc(adminUid).get();

    if (adminDoc.exists) {
      List<dynamic>? studentRequests =
          adminDoc.get('student_requests') as List<dynamic>?;

      if (studentRequests != null) {
        setState(() {
          students = studentRequests.map((request) {
            return Student(
              name: request['email'] ?? 'No Email',
              amount: 0.0,
              category: request['createdAt'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                          request['createdAt'].seconds * 1000)
                      .toString()
                  : 'No Date',
              uid: request['uid'] ?? 'null',
            );
          }).toList();
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await fetchStudentRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students Requests',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share link to invite')));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: students.isEmpty
            ? Center(
                child: Lottie.asset(
                  'assets/empty_list.json', // Path to your Lottie JSON file
                  width: 200,
                  height: 200,
                  repeat: true,
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return StudentCard(
                    student: students[index],
                    onConfirm: () => _confirmStudent(students[index]),
                    onReject: () => _rejectStudent(students[index]),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _confirmStudent(Student student) async {
    final String adminUid = _auth.currentUser?.uid ?? 'null';

    await _firestore.runTransaction((transaction) async {
      DocumentReference adminDocRef =
          _firestore.collection('admin').doc(adminUid);
      DocumentSnapshot adminDoc = await transaction.get(adminDocRef);

      if (!adminDoc.exists) {
        throw Exception("Admin document does not exist!");
      }

      List<dynamic>? studentRequests =
          adminDoc.get('student_requests') as List<dynamic>?;

      if (studentRequests == null) {
        throw Exception("No student requests found!");
      }

      int studentIndex =
          studentRequests.indexWhere((req) => req['email'] == student.name);

      if (studentIndex == -1) {
        throw Exception("Student not found in requests!");
      }

      var studentData = studentRequests[studentIndex];
      studentRequests.removeAt(studentIndex);

      transaction.update(adminDocRef, {
        'student_requests': studentRequests,
        'students': FieldValue.arrayUnion([
          {
            'email': studentData['email'],
            'uid': studentData['uid'],
            'createdAt': studentData['createdAt'],
          }
        ]),
      });

      DocumentReference studentDocRef =
          _firestore.collection('students').doc(student.uid);
      transaction.update(studentDocRef, {'accepted': 1});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student Confirmed'),
        backgroundColor: Colors.green,
      ),
    );

    await _refreshData();
  }

  Future<void> _rejectStudent(Student student) async {
    final String adminUid = _auth.currentUser?.uid ?? 'null';

    await _firestore.runTransaction((transaction) async {
      DocumentReference adminDocRef =
          _firestore.collection('admin').doc(adminUid);
      DocumentSnapshot adminDoc = await transaction.get(adminDocRef);

      if (!adminDoc.exists) {
        throw Exception("Admin document does not exist!");
      }

      List<dynamic>? studentRequests =
          adminDoc.get('student_requests') as List<dynamic>?;

      if (studentRequests == null) {
        throw Exception("No student requests found!");
      }

      int studentIndex =
          studentRequests.indexWhere((req) => req['email'] == student.name);

      if (studentIndex == -1) {
        throw Exception("Student not found in requests!");
      }

      studentRequests.removeAt(studentIndex);

      transaction.update(adminDocRef, {
        'student_requests': studentRequests,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student Rejected'),
        backgroundColor: Colors.red,
      ),
    );

    await _refreshData();
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const StudentCard({
    Key? key,
    required this.student,
    required this.onConfirm,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text(
                      student.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Name and Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          student.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  onPressed: onConfirm,
                  icon: Icons.check,
                  color: Colors.green,
                  label: 'Confirm',
                ),
                SizedBox(width: 12),
                _ActionButton(
                  onPressed: onReject,
                  icon: Icons.close,
                  color: Colors.red,
                  label: 'Reject',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final String label;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Student {
  final String name;
  final double amount;
  final String category;
  final String uid;

  Student({
    required this.name,
    required this.amount,
    required this.category,
    required this.uid,
  });
}
