import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/services/firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/main.dart';
import 'pendingsos.dart';
import 'helparrived.dart';
import 'historydetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const Color secondaryColor = Color(0xFF808080);
const double homePadding = 20.0;
const double spacingSmall = 15.0;
const double spacingMedium = 20.0;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService fireStoreService = FirestoreService();
  Map<String, dynamic>? ongoingSOS;
  List<Map<String, dynamic>> completedReports = [];
  String? userID;
  bool _showBanner = false;
  String _dots = '';
  Timer? _dotTimer;
  String _selectedFilter = 'All';
  bool isLoading = true;
  bool? isAdmin;

  // SOS CIRCLE PROGRESS
  double _sosProgress = 0.0;
  Timer? _sosTimer;

  @override
  void initState() {
    super.initState();
    _loadUserID(); // Call async function
  }

  // GET USER ID
  Future<void> _loadUserID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID');
      isAdmin = prefs.getBool('isAdmin');
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permissions are permanently denied, enable them in settings.",
          ),
        ),
      );
      return;
    }

    _checkOngoingSOS();
    fetchCompletedReports();
  }

  Future<void> fetchCompletedReports() async {
    final result = await fireStoreService.getSOSHistory(userID!);

    if (mounted) {
      setState(() {
        completedReports = result;
        isLoading = false;
      });
      print('Completed Reports fetched: $completedReports');
    }
  }

  // Check ongoing SOS for current user
  Future<void> _checkOngoingSOS() async {
    if (userID == null) return;

    ongoingSOS = await fireStoreService.getOngoingSOS(userID!);

    if (ongoingSOS != null) {
      setState(() {
        _showBanner = true;
        _dots = '';
      });
      _startDotAnimation();
    } else {
      setState(() {
        _showBanner = false;
      });
    }
  }

  // GET LOCATION
  Future<void> _getCurrentLocation() async {
    // Get current position
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    fireStoreService.addSOS(userID, currentPosition);
  }

  // FILTERED DEFAULT HISTORY ENTRIES
  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedFilter == 'All') return completedReports;
    return completedReports
        .where(
          (entry) =>
              entry['status'].toString().toLowerCase() ==
              _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  // SOS DOT ANIMATION FOR BANNER
  void _startDotAnimation() {
    _dotTimer?.cancel();
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_showBanner) {
        setState(() {
          _dots = _dots.length < 3 ? '$_dots.' : '';
        });
      }
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _sosTimer?.cancel();
    super.dispose();
  }

  // SOS ACTION
  Future<void> _onSOSTapped() async {
    setState(() {
      // _showBanner = true;
      _sosProgress = 0.0;
    });

    await _getCurrentLocation();

    await Future.delayed(const Duration(seconds: 3), () async {
      await _checkOngoingSOS();
      setState(() {
        _showBanner = true;
        _dots = "";
      });
      _startDotAnimation();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PendingSOSScreen(
            sosID: ongoingSOS?['docID'],
            ongoingSOS: ongoingSOS,
          ),
        ),
      );
    });
  }

  // FILTER BUTTON BUILDER
  Widget _buildFilterButton(String label) {
    bool isSelected = _selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: primaryColor.withOpacity(0.45), width: 2),
          ),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedFilter = label;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : primaryColor,
                fontFamily: "REM",
              ),
            ),
          ),
        ),
      ),
    );
  }

  // HISTORY CARD
  Widget _buildHistoryCard({
    required Map<String, dynamic> entry,
    required int index,
  }) {
    String date = entry['completedAt'] != null
        ? (entry['completedAt'] as Timestamp).toDate().toString().substring(
            0,
            16,
          )
        : 'Unknown';
    String address = entry['address'] ?? 'No address';
    String status = entry['status'] ?? 'Pending';
    final GeoPoint loc = entry['location'] as GeoPoint;
    double latitude = loc.latitude?.toDouble() ?? 0.0;
    double longitude = loc.longitude?.toDouble() ?? 0.0;

    Color borderColor = primaryColor;
    Color statusColor;
    Color statusBorderColor;

    // STATUS COLORS
    switch (status.toLowerCase()) {
      case 'resolved':
        statusColor = const Color(0xFF00BA00).withOpacity(0.50);
        statusBorderColor = const Color(0xFF00BA00);
        break;
      case 'false alarm':
        statusColor = const Color(0xFFF0D210).withOpacity(0.60);
        statusBorderColor = const Color(0xFFE3C610);
        break;
      case 'cancelled':
        statusColor = secondaryColor.withOpacity(0.60);
        statusBorderColor = secondaryColor;
        break;
      default:
        statusColor = Colors.blueGrey.withOpacity(0.5);
        statusBorderColor = Colors.blueGrey;
    }

    return GestureDetector(
      onTap: () {
        print('Tapped SOS entry: ${_filteredHistory[index]}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailsScreen(
              historyEntry: _filteredHistory[index],
              isAdmin: isAdmin!,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // MAP
            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: borderColor, width: 2)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(latitude, longitude),
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.frontend',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(latitude, longitude),
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // RIGHT CONTAINER
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: secondaryColor,
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusBorderColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Quicksand",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
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
      body: Column(
        children: [
          if (_showBanner)
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PendingSOSScreen(
                      sosID: ongoingSOS?['docID'],
                      ongoingSOS: ongoingSOS,
                    ),
                  ),
                );
                if (result == false) {
                  setState(() {
                    _showBanner = false;
                  });
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'HELP IS ON THE WAY $_dots',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'REM',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(homePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // SOS BUTTON
                  GestureDetector(
                    onTapDown: _showBanner
                        ? null
                        : (_) {
                            _sosProgress = 0.0;
                            _sosTimer?.cancel();
                            const duration = Duration(milliseconds: 30);
                            _sosTimer = Timer.periodic(duration, (timer) {
                              if (!mounted) return;
                              setState(() {
                                _sosProgress += 30 / 3000;
                                if (_sosProgress >= 1.0) {
                                  _sosProgress = 1.0;
                                  _sosTimer?.cancel();
                                  _onSOSTapped();
                                }
                              });
                            });
                          },
                    onTapUp: _showBanner
                        ? null
                        : (_) {
                            if (_sosProgress < 1.0) {
                              _sosTimer?.cancel();
                              setState(() {
                                _sosProgress = 0.0;
                              });
                            }
                          },
                    onTapCancel: _showBanner
                        ? null
                        : () {
                            _sosTimer?.cancel();
                            setState(() {
                              _sosProgress = 0.0;
                            });
                          },
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // OUTER CIRCLE
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: _showBanner
                                  ? Colors.grey[400]
                                  : const Color(0xFFFFDDDB),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // MIDDLE CIRCLE
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              color: _showBanner
                                  ? Colors.grey[500]
                                  : const Color(0xFFFFC3BE),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // INNER CIRCLE
                          Container(
                            width: 205,
                            height: 205,
                            decoration: BoxDecoration(
                              color: _showBanner
                                  ? Colors.grey
                                  : const Color(0xFFFA5246),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // PROGRESS INDICATOR
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: CircularProgressIndicator(
                              value: _sosProgress,
                              strokeWidth: 6,
                              backgroundColor: _showBanner
                                  ? Colors.grey[300]
                                  : Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _showBanner
                                    ? Colors.grey[700]!
                                    : Colors.redAccent,
                              ),
                            ),
                          ),
                          Text(
                            'SOS',
                            style: TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                              color: _showBanner
                                  ? Colors.grey[700]
                                  : Colors.white,
                              fontFamily: "REM",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: spacingSmall),
                  const Text(
                    'Press & hold SOS button for 3 seconds to ask for help.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryColor,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: spacingMedium),

                  // Help Arrived Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpArrivedScreen(),
                        ),
                      );
                    },
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Help Arrived',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'REM',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'History',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: 'REM',
                      ),
                    ),
                  ),

                  const SizedBox(height: spacingSmall),

                  // FILTER BUTTONS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterButton('All'),
                        _buildFilterButton('Responded'),
                        _buildFilterButton('Completed'),
                        _buildFilterButton('Cancelled'),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacingMedium),

                  // HISTORY LIST
                  Column(
                    children: List.generate(
                      _filteredHistory.length,
                      (index) => _buildHistoryCard(
                        entry: _filteredHistory[index],
                        index: index,
                      ),
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
