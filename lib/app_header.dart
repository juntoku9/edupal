import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class GNavBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabTapped;

  GNavBottomNavigationBar({required this.selectedIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
      ]),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            selectedIndex: selectedIndex,
            onTabChange: onTabTapped,
            gap: 8,
            activeColor: Colors.grey.shade800,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            duration: Duration(milliseconds: 800),
            tabBackgroundColor: Colors.grey.shade200,
            textStyle: TextStyle(color: Colors.grey.shade800),
            color: Colors.grey.shade600,
            tabs: [
              GButton(
                icon: Icons.voice_chat,
                // text: 'Home',
              ),
              // GButton(
              //   icon: Icons.assessment,
              //   // text: 'Daily',
              // ),
              // GButton(
              //   icon: Icons.book,
              //   text: 'Journal',
              // ),
              GButton(
                icon: Icons.person,
                // text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
