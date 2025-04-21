import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> students = [];
  List<Student> acceptedStudents = []; // New list for accepted students
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchStudentRequests();
    fetchAcceptedStudents(); // Add this
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
              name: request['name'] ?? 'No name',
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

  Future<void> fetchAcceptedStudents() async {
    final User? user = _auth.currentUser;
    final String adminUid = user?.uid ?? 'null';

    DocumentSnapshot adminDoc =
        await _firestore.collection('admin').doc(adminUid).get();

    if (adminDoc.exists) {
      List<dynamic>? acceptedStudentsList =
          adminDoc.get('students') as List<dynamic>?;

      if (acceptedStudentsList != null) {
        setState(() {
          acceptedStudents = acceptedStudentsList.map((student) {
            return Student(
              name: student['name'] ?? 'No Name',
              amount: 0.0,
              category: student['email'] ?? 'No Name',
              uid: student['uid'] ?? 'null',
            );
          }).toList();
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      fetchStudentRequests(),
      fetchAcceptedStudents(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Manage Students',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.deepPurple)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            students = [];
            acceptedStudents = [];
          });
          await Future.wait([
            fetchStudentRequests(),
            fetchAcceptedStudents(),
          ]);
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only show Student Requests section if there are pending requests
                if (students.isNotEmpty) ...[
                  Text(
                    'Student Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return StudentCard(
                        student: students[index],
                        onConfirm: () => _confirmStudent(students[index]),
                        onReject: () => _rejectStudent(students[index]),
                      );
                    },
                  ),
                  SizedBox(height: 32),
                ],

                // Accepted Students Section
                Text(
                  'Accepted Students',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 16),
                acceptedStudents.isEmpty
                    ? Center(
                        child: Text(
                          'No accepted students yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: acceptedStudents.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.deepPurple.shade100,
                                    child: Text(
                                      acceptedStudents[index]
                                          .name[0]
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          acceptedStudents[index].name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          acceptedStudents[index].category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _ActionButton(
                                    onPressed: () => _removeAcceptedStudent(
                                        acceptedStudents[index]),
                                    icon: Icons.close,
                                    color: Colors.red,
                                    label: 'Remove',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmStudent(Student student) async {
    final String adminUid = _auth.currentUser?.uid ?? 'null';

    try {
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
            studentRequests.indexWhere((req) => req['uid'] == student.uid);

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
              'name': studentData['name'],
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

      // Reload both lists
      await Future.wait([
        fetchStudentRequests(),
        fetchAcceptedStudents(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error confirming student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Future<void> _removeAcceptedStudent(Student student) async {
    final String adminUid = _auth.currentUser?.uid ?? 'null';

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference adminDocRef =
            _firestore.collection('admin').doc(adminUid);
        DocumentSnapshot adminDoc = await transaction.get(adminDocRef);

        if (!adminDoc.exists) {
          throw Exception("Admin document does not exist!");
        }

        List<dynamic>? acceptedStudentsList =
            adminDoc.get('students') as List<dynamic>?;

        if (acceptedStudentsList == null) {
          throw Exception("No accepted students found!");
        }

        int studentIndex =
            acceptedStudentsList.indexWhere((std) => std['uid'] == student.uid);

        if (studentIndex == -1) {
          throw Exception("Student not found in accepted list!");
        }

        acceptedStudentsList.removeAt(studentIndex);

        transaction.update(adminDocRef, {
          'students': acceptedStudentsList,
        });

        DocumentReference studentDocRef =
            _firestore.collection('students').doc(student.uid);
        transaction.update(studentDocRef, {'accepted': 0});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student Removed'),
          backgroundColor: Colors.red,
        ),
      );

      // Reload both lists
      await Future.wait([
        fetchStudentRequests(),
        fetchAcceptedStudents(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const StudentCard({
    super.key,
    required this.student,
    required this.onConfirm,
    required this.onReject,
  });

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
