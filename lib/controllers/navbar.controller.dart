import 'package:flutter/material.dart';
import 'package:group_pay_admin/home/student_list.dart';
import 'package:group_pay_admin/settings/profile.screen.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentSelectedIndex = 0;

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  final pages = [
    StudentListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: updateCurrentIndex,
        currentIndex: currentSelectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              color: inActiveIconColor,
            ),
            activeIcon: Icon(
              Icons.list,
              color: Colors.deepPurple,
            ),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: inActiveIconColor,
            ),
            activeIcon: Icon(
              Icons.person,
              color: Colors.deepPurple,
            ),
            label: 'Favorite',
          )
        ],
      ),
    );
  }
}
