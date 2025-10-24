import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const double spacingSmall = 5.0;
const double spacingMedium = 10.0;
const double spacingLarge = 30.0;

class PendingSOSScreen extends StatefulWidget {
  final Map<String, dynamic>? ongoingSOS;
  final String sosID;
  const PendingSOSScreen({
    Key? key,
    required this.sosID,
    required this.ongoingSOS,
  }) : super(key: key);
  @override
  _PendingSOSScreenState createState() => _PendingSOSScreenState();
}

class _PendingSOSScreenState extends State<PendingSOSScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService fireStoreService = FirestoreService();
  double _dragOffset = 0.0;
  final double _cancelThreshold = 100.0;
  List<dynamic> get responders {
    final allResponders = widget.ongoingSOS?['responders'] ?? [];
    return allResponders
        .where((responder) => responder['status'] == 'Arrived')
        .toList();
  }

  late final AnimationController _animationController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onCancelSOS() {
    fireStoreService.cancelSOS(widget.sosID);
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 1,
        leading: IconButton(
          icon: Image.asset('assets/back.png', width: 50, height: 40),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.6, 1.0],
            colors: [primaryColor, Color(0xFFB63E36)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // MAIN CONTENT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    if (responders.isEmpty) ...[
                      const Text(
                        'LOOKING FOR\nRESCUERS...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'REM',
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 400,
                          height: 400,
                          child: Lottie.asset(
                            'assets/ambulance.json',
                            repeat: true,
                            animate: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Help is on the way.\nPlease stay calm and safe.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // SLIDE UP TO CANCEL
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            setState(() {
                              _dragOffset += details.primaryDelta!;
                              if (_dragOffset > 0) _dragOffset = 0;
                            });
                          },
                          onVerticalDragEnd: (details) {
                            if (_dragOffset < -_cancelThreshold) {
                              _onCancelSOS();
                            } else {
                              setState(() => _dragOffset = 0);
                            }
                          },
                          child: AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  _dragOffset + _bounceAnimation.value,
                                ),
                                child: child,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 30),
                              width: 250,
                              height: 70,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                  Text(
                                    'Slide up to cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'REM',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'HELP ARRIVED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'REM',
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // RESCUER CARDS
                      Expanded(
                        child: ListView.builder(
                          itemCount: responders.length,
                          itemBuilder: (context, index) {
                            final rescuer = responders[index];
                            Timestamp arrivedAt = rescuer['arrivedAt'];
                            DateTime dateTime = arrivedAt.toDate();
                            String formattedTime = DateFormat(
                              'h:mm a',
                            ).format(dateTime);
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
                                    '${rescuer['userDetails']['firstname']} ${rescuer['userDetails']['lastname']}',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                      fontFamily: 'REM',
                                    ),
                                  ),

                                  const SizedBox(height: spacingMedium),

                                  // TIME
                                  _infoRow(
                                    Icons.access_time,
                                    'Time of Arrival: $formattedTime',
                                  ),

                                  const SizedBox(height: spacingMedium),

                                  // CONTACT
                                  _infoRow(
                                    Icons.phone,
                                    rescuer['userDetails']['mobilenum']!,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
