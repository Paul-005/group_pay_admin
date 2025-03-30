import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_pay_admin/settings/notification.screen.dart';
import 'package:group_pay_admin/settings/profile_edit.sreen.dart';
import 'package:group_pay_admin/settings/update_bank.screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Profile',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          final name = user?.displayName ?? 'User';

          return Column(
            children: [
              // Profile Header
              Container(
                padding: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    ProfilePic(name: name),
                    const SizedBox(height: 16),
                    Text(
                      "Hi, $name",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Items
              ProfileMenu(
                icon: Icons.person_outline,
                text: "My Account",
                press: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditPage(),
                    ),
                  );
                },
              ),
              ProfileMenu(
                icon: Icons.notifications_outlined,
                text: "Notifications",
                press: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EmptyNotificationsScreen(),
                    ),
                  );
                },
              ),
              ProfileMenu(
                icon: Icons.account_balance,
                text: "Change Bank Details",
                press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EditUpiIdPage();
                  }));
                },
              ),

              ProfileMenu(
                icon: Icons.logout_outlined,
                text: "Log Out",
                isDestructive: true,
                press: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  final String name;
  const ProfilePic({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        height: 115,
        width: 115,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
    this.isDestructive = false,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final VoidCallback? press;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: press,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isDestructive ? Colors.red : Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDestructive ? Colors.red : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDestructive ? Colors.red : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
