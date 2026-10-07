import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'recompenses_screen.dart';
import 'parcours_screen.dart';
import 'profil_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    RecompensesScreen(),
    ParcoursScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 15,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Accueil',
                  index: 0,
                ),

                _buildNavItem(
                  icon: Icons.emoji_events_rounded,
                  label: 'Récompenses',
                  index: 1,
                ),

                _buildNavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Parcours',
                  index: 2,
                ),

                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool selected = _index == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _index = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFBEAF0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected
                  ? const Color(0xFFD4537E)
                  : const Color(0xFF9B9895),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? const Color(0xFFD4537E)
                    : const Color(0xFF9B9895),
              ),
            ),
          ],
        ),
      ),
    );
  }
}