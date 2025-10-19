import 'package:flutter/material.dart';
import 'package:frontend/main.dart';

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const Color secondaryColor = Color(0xFF808080);
const double homePadding = 20.0;
const double spacingSmall = 15.0;
const double spacingMedium = 20.0;

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        //TOP
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Row(
            children: [
              Image.asset('assets/home_logo.png', width: 40, height: 40),
              const SizedBox(width: 10),
              const Text(
                'RESQ',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'REM',
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.redAccent,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
