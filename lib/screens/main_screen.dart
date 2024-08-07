import 'package:echo_emotions/screens/inspire_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
// import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const InspireScreen(),
    const ProfileScreen(),
    // const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.settings),
              //   label: 'Settings',
              // ),
            ],
            currentIndex: _selectedIndex > 0 ? _selectedIndex - 1 : _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: (index) {
              if (index == 0) {
                _onItemTapped(0);
              } else if (index > 0) {
                _onItemTapped(index + 1);
              } else {
                _onItemTapped(index);
              }
            },
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
          ),
          Positioned(
            top: -20, // Adjust the position to move the icon upwards
            left: MediaQuery.of(context).size.width * 0.33,
            right: MediaQuery.of(context).size.width * 0.33,
            child: GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedIndex == 1 ? Colors.amber[800] : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.lightbulb,
                        size: 40,
                        color: _selectedIndex == 1 ? Colors.white : Colors.amber[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5), // Space between icon and label
                  Text(
                    'Inspire',
                    style: TextStyle(
                      color: _selectedIndex == 1 ? Colors.amber[800] : Colors.grey,
                      fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
