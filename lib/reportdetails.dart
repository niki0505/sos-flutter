import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/services/firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ReportDetailsApp());
}

class ReportDetailsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Report Details',
      debugShowCheckedModeBanner: false,
      home: ReportDetailsPage(pendingReport: {}),
    );
  }
}

class ReportDetailsPage extends StatefulWidget {
  final Map<String, dynamic> pendingReport;
  const ReportDetailsPage({super.key, required this.pendingReport});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  final FirestoreService fireStoreService = FirestoreService();
  String? userID;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color.fromRGBO(250, 82, 70, 1);
    final report = widget.pendingReport ?? {};
    final name = report['name'] ?? 'Unknown Reporter';
    final age = '${report['user']['age']} years old' ?? 'N/A';
    final sex = report['user']['sex'] ?? 'N/A';
    final address = report['address'] ?? 'Unknown location';
    final lat = report['latitude'] ?? 14.5995;
    final lon = report['longitude'] ?? 120.9842;
    final sosID = report['sosID'] ?? "N/A";
    final LatLng reportLocation = LatLng(lat, lon);

    final responders =
        (report['responders'] as List<dynamic>?)
            ?.map((r) => r as Map<String, dynamic>)
            .toList() ??
        [];

    Map<String, dynamic>? responderInfo;
    try {
      responderInfo = responders.firstWhere((r) => r['userID'] == userID);
    } catch (e) {
      responderInfo = null;
    }

    final isHeading =
        responderInfo != null && responderInfo['status'] == 'Heading';
    final isArrivedOrDidNotArrive =
        responderInfo != null &&
        (responderInfo['status'] == 'Arrived' ||
            responderInfo['status'] == 'Did Not Arrive');
    final isHead = responderInfo != null && responderInfo['isHead'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset("assets/back_red.png", height: 35),
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "REPORT DETAILS",
                      style: TextStyle(
                        fontFamily: "REM",
                        color: redColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please ensure the reported incident is legitimate before confirming any response.",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: "Quicksand",
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "REPORTER DETAILS",
                            style: TextStyle(
                              fontFamily: "REM",
                              color: redColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 15),

                          Row(
                            children: [
                              const SizedBox(width: 15),
                              Image.asset("assets/person.png", height: 26),
                              const SizedBox(width: 10),
                              Text(
                                name,
                                style: TextStyle(
                                  color: const Color.fromRGBO(
                                    250,
                                    82,
                                    70,
                                    0.72,
                                  ),
                                  fontFamily: "REM",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),

                          Row(
                            children: [
                              const SizedBox(width: 14),
                              Image.asset(
                                "assets/calendar.png",
                                height: 26,
                                color: redColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                age,
                                style: TextStyle(
                                  color: const Color.fromRGBO(
                                    250,
                                    82,
                                    70,
                                    0.72,
                                  ),
                                  fontFamily: "REM",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Image.asset(
                                "assets/gender.png",
                                height: 28,
                                color: redColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                sex,
                                style: TextStyle(
                                  color: const Color.fromRGBO(
                                    250,
                                    82,
                                    70,
                                    0.72,
                                  ),
                                  fontFamily: "REM",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),

                          Row(
                            children: [
                              const SizedBox(width: 15),
                              Image.asset(
                                "assets/home.png",
                                height: 26,
                                color: redColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  address,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color.fromRGBO(
                                      250,
                                      82,
                                      70,
                                      0.72,
                                    ),
                                    fontFamily: "REM",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // MAP
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 170,
                                width: MediaQuery.of(context).size.width * 0.7,
                                decoration: BoxDecoration(
                                  border: Border.all(color: redColor, width: 3),
                                ),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: reportLocation,
                                    initialZoom: 15,
                                    interactionOptions:
                                        const InteractionOptions(
                                          flags: InteractiveFlag.all,
                                        ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: reportLocation,
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_pin,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          Column(
                            children: [
                              if (responderInfo == null)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Show confirm dialog
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Confirm Heading"),
                                          content: const Text(
                                            "Are you sure you want to head to this location?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text("Confirm"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await fireStoreService.headingSOS(
                                          userID,
                                          sosID,
                                        );
                                        setState(() {
                                          final responders =
                                              (report['responders']
                                                      as List<dynamic>?)
                                                  ?.map(
                                                    (r) =>
                                                        r
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >,
                                                  )
                                                  .toList() ??
                                              [];

                                          final index = responders.indexWhere(
                                            (r) => r['userID'] == userID,
                                          );
                                          if (index != -1) {
                                            responders[index]['status'] =
                                                'Heading';
                                            responders[index]['headingAt'] =
                                                DateTime.now();
                                          } else {
                                            responders.add({
                                              'userID': userID,
                                              'status': 'Heading',
                                              'headingAt': DateTime.now(),
                                              'arrivedAt': null,
                                              'isHead': responders.isEmpty,
                                            });
                                          }

                                          report['responders'] = responders;
                                          responderInfo = responders.firstWhere(
                                            (r) => r['userID'] == userID,
                                          );
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                        48,
                                        240,
                                        48,
                                        1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: const Text(
                                      "Heading",
                                      style: TextStyle(
                                        fontFamily: "REM",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(2, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (isHeading)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Show confirm dialog
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Confirm Arrived"),
                                          content: const Text(
                                            "Are you sure you arrived to this location?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text("Confirm"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await fireStoreService.arrivedSOS(
                                          userID,
                                          sosID,
                                        );
                                        setState(() {
                                          final responders =
                                              (report['responders']
                                                      as List<dynamic>?)
                                                  ?.map(
                                                    (r) =>
                                                        r
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >,
                                                  )
                                                  .toList() ??
                                              [];

                                          final index = responders.indexWhere(
                                            (r) => r['userID'] == userID,
                                          );
                                          if (index != -1) {
                                            responders[index]['status'] =
                                                'Arrived';
                                            responders[index]['arrivedAt'] =
                                                DateTime.now();
                                          }
                                          report['responders'] = responders;
                                          responderInfo = responders.firstWhere(
                                            (r) => r['userID'] == userID,
                                          );
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                        48,
                                        240,
                                        48,
                                        1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: const Text(
                                      "Arrived",
                                      style: TextStyle(
                                        fontFamily: "REM",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(2, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              if (isHeading)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        final responders =
                                            (report['responders']
                                                    as List<dynamic>?)
                                                ?.map(
                                                  (r) =>
                                                      r as Map<String, dynamic>,
                                                )
                                                .toList() ??
                                            [];

                                        final index = responders.indexWhere(
                                          (r) => r['userID'] == userID,
                                        );
                                        if (index != -1) {
                                          responders[index]['status'] =
                                              'Did Not Arrive';
                                        }
                                        report['responders'] = responders;
                                        responderInfo = responders.firstWhere(
                                          (r) => r['userID'] == userID,
                                        );
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                        250,
                                        82,
                                        70,
                                        1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: const Text(
                                      "Did Not Arrive",
                                      style: TextStyle(
                                        fontFamily: "REM",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(2, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              if (isArrivedOrDidNotArrive && isHead)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Heading to location...",
                                          ),
                                        ),
                                      );
                                      // Optionally call your headingSOS() function here
                                      // await FirestoreService().headingSOS(userID, report['docID']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                        48,
                                        240,
                                        48,
                                        1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: const Text(
                                      "Verify",
                                      style: TextStyle(
                                        fontFamily: "REM",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(2, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              if (isArrivedOrDidNotArrive && isHead)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Heading to location...",
                                          ),
                                        ),
                                      );
                                      // Optionally call your headingSOS() function here
                                      // await FirestoreService().headingSOS(userID, report['docID']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                        250,
                                        82,
                                        70,
                                        1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: const Text(
                                      "False Alarm",
                                      style: TextStyle(
                                        fontFamily: "REM",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(2, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
