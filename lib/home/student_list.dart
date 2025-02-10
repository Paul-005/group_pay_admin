import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentListScreen extends StatelessWidget {
  final List<Student> students = [
    Student(name: 'Student 1', amount: 100, category: 'Trip'),
    Student(name: 'Student 2', amount: 150, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
    Student(name: 'Student 3', amount: 200, category: 'Trip'),
  ];

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // navigate to login screen
        Navigator.pushNamed(context, '/login');
      } else {
        print('User is signed in!');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Students', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share link to invite')));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          return StudentCard(student: students[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // got ot create post screen stack
          Navigator.pushNamed(context, '/create-post');
        },
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child: Text(
            student.name[0],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue.shade100,
        ),
        title: Text(
          student.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(student.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // Implement confirm logic
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Confirmed')));
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.green,
                elevation: 2,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Implement reject logic
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Rejected')));
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.red,
                elevation: 2,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Student {
  final String name;
  final double amount;
  final String category;

  Student({
    required this.name,
    required this.amount,
    required this.category,
  });
}
