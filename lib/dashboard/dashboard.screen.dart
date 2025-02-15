import 'package:flutter/material.dart';
import 'package:group_pay_admin/dashboard/manage_post.screen.dart';
import 'package:group_pay_admin/dashboard/post.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String description;
  final double totalAmount;
  final int totalMembers;
  final int paidMembers;

  const PostCard({
    Key? key,
    required this.title,
    required this.description,
    required this.totalAmount,
    required this.totalMembers,
    required this.paidMembers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    'Rs. ${totalAmount.toStringAsFixed(0)}',
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
                      '$paidMembers/$totalMembers paid',
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
                    value: paidMembers / totalMembers,
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
                        builder: (context) => PostDetailsScreen(),
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
class DashboardScreen extends StatelessWidget {
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
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          PostCard(
            title: 'Team Lunch',
            description:
                'Monthly team lunch at Restaurant XYZ. Please pay your share by Friday.',
            totalAmount: 2500,
            totalMembers: 10,
            paidMembers: 6,
          ),
          SizedBox(height: 16),
          PostCard(
            title: 'Office Party Decorations',
            description:
                'Collection for Christmas party decorations and snacks.',
            totalAmount: 5000,
            totalMembers: 15,
            paidMembers: 8,
          ),
        ],
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
