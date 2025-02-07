import 'package:flutter/material.dart';
import 'package:jm_senior/Pages/exams_page.dart';
import 'package:jm_senior/Pages/profile_page.dart';
import 'package:jm_senior/Pages/quiz_me_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.question_mark_sharp), label: 'Quiz Me'),
          const NavigationDestination(icon: Icon(Icons.book), label: 'My Exams'),
          const NavigationDestination(icon: Icon(Icons.person), label: 'My Profile'),
        ],
      ),
      body: [
        const QuizMePage(),
        const ExamsPage(),
        const ProfilePage(),
      ][currentPageIndex],
    );
  }
}

