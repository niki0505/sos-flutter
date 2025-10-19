import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const ReportDetailsApp());
}

class ReportDetailsApp extends StatelessWidget {
  const ReportDetailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Report Details',
      debugShowCheckedModeBanner: false,
      home: const ReportDetailsPage(),
    );
  }
}

class ReportDetailsPage extends StatefulWidget {
  const ReportDetailsPage({super.key});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  static const LatLng _defaultLocation =
      LatLng(14.4401, 120.9822);

  @override
  Widget build(BuildContext context) {
    const redColor = Color.fromRGBO(250, 82, 70, 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/back_red.png",
                    height: 35,
                  ),
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
                            color: Colors.grey.shade400, width: 1.5),
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
                              Image.asset(
                                "assets/person.png",
                                height: 26,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Juana Marie A. Cruz",
                                style: TextStyle(
                                  color:
                                      const Color.fromRGBO(250, 82, 70, 0.72),
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
                                "22 years old",
                                style: TextStyle(
                                  color:
                                      const Color.fromRGBO(250, 82, 70, 0.72),
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
                                "Female",
                                style: TextStyle(
                                  color:
                                      const Color.fromRGBO(250, 82, 70, 0.72),
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
                                  "123 Reyes St., Pasay City",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color.fromRGBO(250, 82, 70, 0.72),
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
                                    initialCenter: _defaultLocation,
                                    initialZoom: 15,
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: const ['a', 'b', 'c'],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _defaultLocation,
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
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Heading to location...")),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(48, 240, 48, 1),
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
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Marked as Can't Respond.")),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: redColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: const Text(
                                    "Can't Respond",
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
