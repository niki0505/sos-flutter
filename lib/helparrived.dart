import 'package:flutter/material.dart';

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const double spacingSmall = 5.0;
const double spacingMedium = 10.0;
const double spacingLarge = 30.0;

class HelpArrivedScreen extends StatefulWidget {
  @override
  _HelpArrivedScreenState createState() => _HelpArrivedScreenState();
}

class _HelpArrivedScreenState extends State<HelpArrivedScreen> {
  final List<Map<String, String>> rescuers = [
    {
      'name': 'Juan Dela Cruz',
      'role': 'Rescuer 1',
      'location': 'Arrived at 19th Street',
      'time': '2:15 AM',
      'contact': '09674451254',
    },
    {
      'name': 'Jose Mariano',
      'role': 'Rescuer 2',
      'location': 'Arrived at 19th Street',
      'time': '2:15 AM',
      'contact': '09674451254',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Image.asset('assets/back.png', width: 40, height: 40),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.6, 1.0],
            colors: [primaryColor, Color(0xFFB63E36)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HELP ARRIVED',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'REM',
                  ),
                ),
                const SizedBox(height: spacingLarge),

                // RESCUER CARDS
                Expanded(
                  child: ListView.builder(
                    itemCount: rescuers.length,
                    itemBuilder: (context, index) {
                      final rescuer = rescuers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NAME & ROLE
                            Text(
                              rescuer['name']!,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontFamily: 'REM',
                              ),
                            ),
                            const SizedBox(height: spacingSmall),
                            Text(
                              rescuer['role']!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: primaryColor,
                                fontFamily: 'REM',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: spacingMedium),

                            // LOCATION
                            _infoRow(Icons.location_on, rescuer['location']!),

                            const SizedBox(height: spacingMedium),

                            // TIME
                            _infoRow(
                              Icons.access_time,
                              'Time of Arrival: ${rescuer['time']}',
                            ),

                            const SizedBox(height: spacingMedium),

                            // CONTACT
                            _infoRow(Icons.phone, rescuer['contact']!),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // REUSABLE INFO ROW FOR LOCATION, TIME, & CONTACT
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
