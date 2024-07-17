import 'package:ashlink/pages/main_pages/create_page.dart';
import 'package:ashlink/pages/main_pages/discover.dart';
import 'package:ashlink/pages/main_pages/feed_page.dart';
import 'package:ashlink/pages/main_pages/notifications.dart';
import 'package:ashlink/pages/main_pages/profile_page.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  final int initialIndex;
  const CustomNavBar({super.key, required this.initialIndex});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late int selectedIndex;
  List pages = [
    const FeedPage(),
    const DiscoverPage(),
    const CreatePage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex =
        widget.initialIndex; // Initialize _selectedIndex from widget parameter
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<String> pageTexts = [
    'Home',
    'Discover',
    'Create',
    'Notifications',
    'Profile'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(255, 70, 111, 201),
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: 'Notifications',
            ),
                        BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]),
    );
  }
}
