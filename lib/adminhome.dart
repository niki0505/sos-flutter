import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/main.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'historydetails.dart';
import 'package:frontend/services/firestore.dart';
import 'reportdetails.dart';

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const Color secondaryColor = Color(0xFF808080);
const double homePadding = 20.0;
const double spacingSmall = 15.0;
const double spacingMedium = 20.0;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirestoreService fireStoreService = FirestoreService();
  String _selectedFilter = 'Newest';
  List<Map<String, dynamic>> pendingReports = [];
  List<Map<String, dynamic>> completedReports = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchPendingReports();
    fetchCompletedReports();
  }

  // FILTERED DEFAULT HISTORY ENTRIES
  List<Map<String, dynamic>> get _filteredHistory {
    List<Map<String, dynamic>> sortedList = List.from(completedReports);
    if (_selectedFilter == 'Newest') {
      // Sort descending (most recent first)
      sortedList.sort(
        (a, b) =>
            b['completedAt'].toDate().compareTo(a['completedAt'].toDate()),
      );
    } else if (_selectedFilter == 'Oldest') {
      // Sort ascending (oldest first)
      sortedList.sort(
        (a, b) =>
            a['completedAt'].toDate().compareTo(b['completedAt'].toDate()),
      );
    }
    return sortedList;
  }

  Future<void> fetchPendingReports() async {
    final result = await fireStoreService.fetchPendingReports();

    if (mounted) {
      setState(() {
        pendingReports = result;
        isLoading = false;
      });
    }
  }

  Future<void> fetchCompletedReports() async {
    final result = await fireStoreService.fetchCompletedReports();

    if (mounted) {
      setState(() {
        completedReports = result;
        isLoading = false;
      });
      print('Completed Reports fetched: $completedReports');
    }
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
  Widget _buildHistoryCard({required Map<String, dynamic> entry}) {
    Map<String, dynamic> user = entry['user'] ?? <String, dynamic>{};
    String name = '${user['firstname']} ${user['lastname']}' ?? 'Unknown';
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailsScreen(historyEntry: entry),
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: "REM",
                        color: primaryColor,
                      ),
                    ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(homePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: spacingSmall),
            Text(
              'SOS Requests',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: "REM",
              ),
            ),
            SizedBox(height: spacingSmall),
            SOSRequestsSection(pendingReports: pendingReports),
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
                  _buildFilterButton('Newest'),
                  _buildFilterButton('Oldest'),
                ],
              ),
            ),
            const SizedBox(height: spacingMedium),

            // HISTORY LIST
            Column(
              children: _filteredHistory
                  .map((entry) => _buildHistoryCard(entry: entry))
                  .toList(),
            ),
            SizedBox(height: spacingMedium),
          ],
        ),
      ),
    );
  }
}

class SOSRequestsSection extends StatelessWidget {
  final List<Map<String, dynamic>> pendingReports;
  const SOSRequestsSection({required this.pendingReports, super.key});

  @override
  Widget build(BuildContext context) {
    if (pendingReports.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No active SOS requests.',
            style: TextStyle(color: secondaryColor),
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pendingReports.length,
        itemBuilder: (context, index) {
          final sos = pendingReports[index];
          final GeoPoint loc = sos['location'];
          final user = sos['user'] ?? {};

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SOSCard(
              entry: {
                'name': '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}'
                    .trim(),
                'date':
                    sos['requestedAt']?.toDate().toString().substring(0, 16) ??
                    'Unknown',
                'address': sos['address'] ?? 'No address provided',
                'latitude': loc.latitude,
                'longitude': loc.longitude,
                'status': sos['status'],
                'user': user,
                'sosID': sos['docID'],
                'responders': sos['responders'],
              },
            ),
          );
        },
      ),
    );
  }
}

class SOSCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  const SOSCard({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).primaryColor;

    final String name = entry['name'] as String;
    final String date = entry['date'] as String;
    final List<dynamic> responders = entry['responders'] as List<dynamic>;
    final String address = entry['address'] as String;
    final double latitude = entry['latitude'] as double;
    final double longitude = entry['longitude'] as double;

    return GestureDetector(
      onTap: () {
        // Navigate to report details page
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => ReportDetailsPage(pendingReport: entry),
          ),
        );
      },
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              height: 250,
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
                  children: <Widget>[
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.frontend',
                    ),
                    MarkerLayer(
                      markers: <Marker>[
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
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "REM",
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10.0,
                      ), // Added padding
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    ReportDetailsPage(pendingReport: entry),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text('${responders.length} Responder/s'),
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
}

/// A button for filtering history entries, integrated into the filter/sort section.
class HistoryFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<String> onSetSort;

  const HistoryFilterButton({
    required this.label,
    required this.isSelected,
    required this.onSetSort,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: primaryColor.withOpacity(0.45),
                width: 2,
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                onSetSort(label);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                minimumSize: Size.zero,
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
      ),
    );
  }
}
