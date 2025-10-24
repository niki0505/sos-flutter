import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const Color secondaryColor = Color(0xFF808080);
const double spacingSmall = 5.0;
const double spacingMedium = 10.0;
const double spacingLarge = 20.0;

class HistoryDetailsScreen extends StatelessWidget {
  const HistoryDetailsScreen({
    super.key,
    required this.historyEntry,
    required this.isAdmin,
  });
  final Map<String, dynamic> historyEntry;
  final bool isAdmin;

  List<dynamic> get responders {
    final allResponders = historyEntry['responders'] ?? [];
    return allResponders
        .where((responder) => responder['status'] == 'Arrived')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final GeoPoint loc = historyEntry['location'] as GeoPoint;
    double latitude = loc.latitude?.toDouble() ?? 0.0;
    double longitude = loc.longitude?.toDouble() ?? 0.0;

    final statusColors = _getStatusColors(historyEntry['status']);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Image.asset('assets/back_red.png', width: 40, height: 40),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REQUEST DETAILS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: 'REM',
              ),
            ),
            const SizedBox(height: spacingLarge),
            _buildStatusCard(statusColors),
            const SizedBox(height: spacingMedium),
            _buildInfoCard('Type & Address', historyEntry),
            const SizedBox(height: spacingMedium),
            _buildRespondersCard(),
            const SizedBox(height: spacingMedium),
            _buildMapSection(latitude, longitude),
          ],
        ),
      ),
    );
  }

  // STATUS COLORS
  Map<String, Color> _getStatusColors(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'resolved':
        return {
          'bg': const Color(0xFF00BA00).withOpacity(0.5),
          'border': const Color(0xFF00BA00),
        };
      case 'false alarm':
        return {
          'bg': const Color(0xFFF0D210).withOpacity(0.6),
          'border': const Color(0xFFE3C610),
        };
      case 'cancelled':
        return {
          'bg': secondaryColor.withOpacity(0.6),
          'border': secondaryColor,
        };
      default:
        return {
          'bg': Colors.blueGrey.withOpacity(0.5),
          'border': Colors.blueGrey,
        };
    }
  }

  // STATUS CARD
  Widget _buildStatusCard(Map<String, Color> statusColors) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor, width: 1.5),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 10),
            const Text(
              'Status: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
                color: primaryColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                color: statusColors['bg'],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColors['border']!, width: 1.5),
              ),
              child: Text(
                historyEntry['status'] ?? 'N/A',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INFO BUILDER
  Widget _buildInfoCard(String title, Map<String, dynamic> data) {
    Timestamp completedAt = data['completedAt'];
    DateTime dateTime = completedAt.toDate();
    String formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: primaryColor, width: 2),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin) ...[
              _infoRow(
                Icons.person,
                '${data['user']['firstname'] ?? ''} ${data['user']['lastname'] ?? ''}'
                        .trim()
                        .isNotEmpty
                    ? '${data['user']['firstname']} ${data['user']['lastname']}'
                    : 'N/A',
              ),
              const SizedBox(height: spacingMedium),
            ],
            _infoRow(Icons.calendar_today, formattedDate ?? 'N/A'),
            const SizedBox(height: spacingMedium),
            _infoRow(Icons.location_on, data['address'] ?? 'N/A'),
            const SizedBox(height: spacingMedium),
            _infoRow(Icons.description, data['reportdetails'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  // RESPONDERS BUILDER
  Widget _buildRespondersCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: primaryColor, width: 2),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Responder/s',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'REM',
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 5),

            Column(
              children: List.generate(responders.length, (index) {
                final rescuer = responders[index];
                Timestamp arrivedAt = rescuer['arrivedAt'];
                DateTime dateTime = arrivedAt.toDate();
                String formattedTime = DateFormat('h:mm a').format(dateTime);
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${rescuer['userDetails']['firstname']} ${rescuer['userDetails']['lastname']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontFamily: 'REM',
                            ),
                          ),
                          const SizedBox(height: 10),
                          _infoRow(
                            Icons.access_time,
                            'Time of Arrival: $formattedTime',
                          ),
                          const SizedBox(height: 10),
                          _infoRow(
                            Icons.phone,
                            rescuer['userDetails']['mobilenum']!,
                          ),
                        ],
                      ),
                    ),

                    if (index < responders.length - 1)
                      const Divider(
                        color: primaryColor,
                        thickness: 1,
                        height: 10,
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // MAP
  Widget _buildMapSection(double latitude, double longitude) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: primaryColor, width: 1.5),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'REM',
                color: primaryColor,
              ),
            ),
            const SizedBox(height: spacingMedium),
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
          ],
        ),
      ),
    );
  }

  // REUSABLE INFO ROW
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Quicksand',
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
