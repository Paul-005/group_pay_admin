import 'package:flutter/material.dart';
import 'package:group_pay_admin/dashboard/admin_code.screen.dart';
import 'package:group_pay_admin/dashboard/manage_post.screen.dart';
import 'package:group_pay_admin/dashboard/post.dart';
import 'package:group_pay_admin/settings/notification.screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class PostCard extends StatelessWidget {
  final String title;
  final String description;
  final double amount;
  final int paidCount;
  final int totalStudents;
  final Timestamp? lastDate;
  final String postId;

  const PostCard({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.paidCount,
    required this.totalStudents,
    required this.lastDate,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalStudents > 0 ? paidCount / totalStudents : 0.0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and amount
          Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rs. ${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Last Date
          if (lastDate != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Last Date: ${DateFormat('MMM dd, yyyy').format(lastDate!.toDate())}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 8),

          // Payment progress bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Progress',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$paidCount/$totalStudents paid',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Footer with actions
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailsScreen(postId: postId),
                      ),
                    );
                  },
                  icon: Icon(Icons.visibility, color: Colors.deepPurple),
                  label: Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example usage:
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _adminCode;

  @override
  void initState() {
    super.initState();
    _fetchAdminCode();
  }

  Future<void> _fetchAdminCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not logged in
      return;
    }

    final DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('admin')
        .doc(user.uid)
        .get();

    if (adminDoc.exists) {
      setState(() {
        _adminCode = adminDoc.get('adminCode').toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin document does not exist for user ${user.uid}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            color: Colors.deepPurple,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminCodePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.deepPurple,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EmptyNotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _adminCode == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(_adminCode)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 60, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet!',
                          style:
                              TextStyle(fontSize: 20, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final groupData = snapshot.data!.data() as Map<String, dynamic>;
                final posts = groupData['posts'] as List<dynamic>? ?? [];

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 60, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet!',
                          style:
                              TextStyle(fontSize: 20, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index] as Map<String, dynamic>;
                    return Column(
                      children: [
                        PostCard(
                          title: post['title'] ?? 'No Title',
                          description: post['description'] ?? 'No Description',
                          amount: post['amount']?.toDouble() ?? 0.0,
                          paidCount: post['paid'] ?? 0,
                          totalStudents: post['no_students'] ?? 0,
                          lastDate: post['lastDate'] as Timestamp?,
                          postId: post['postId'] ?? '',
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(),
            ),
          );
        },
      ),
    );
  }
}
