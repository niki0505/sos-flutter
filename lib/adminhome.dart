import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/main.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'historydetails.dart';

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const Color secondaryColor = Color(0xFF808080);
const double homePadding = 20.0;
const double spacingSmall = 15.0;
const double spacingMedium = 20.0;

/// Manages and filters a list of historical entries, notifying listeners of changes.
class AppHistoryManager extends ChangeNotifier {
  String _selectedHistoryFilterStatus =
      'All'; // 'All', 'Responded', 'Completed', 'Cancelled'
  String _selectedHistorySortOrder = 'Newest'; // 'Newest', 'Oldest'

  // HISTORY DEFAULT ENTRIES
  final List<Map<String, dynamic>> _allEntries = <Map<String, dynamic>>[
    {
      'type': 'Medical',
      'date': '10/18/2025',
      'description': 'Blk 123 Street. Aniban 2',
      'status': 'Completed',
      'latitude': 14.5995,
      'longitude': 120.9842,
    },
    {
      'type': 'Fire',
      'date': '10/16/2025',
      'description': 'Blk 123 Street. Aniban 2',
      'status': 'Responded',
      'latitude': 14.6190,
      'longitude': 120.9820,
    },
    {
      'type': 'Earthquake',
      'date': '10/14/2025',
      'description': 'Blk 123 Street. Aniban 2',
      'status': 'Cancelled',
      'latitude': 14.6190,
      'longitude': 120.9820,
    },
    {
      'type': 'Medical',
      'date': '10/21/2025',
      'description': 'Urgent medical assistance needed at Block 456, Road XYZ.',
      'status': 'Responded',
      'latitude': 14.6050,
      'longitude': 120.9860,
    },
  ];

  // SOS requests == responded status not sure here if tama
  List<Map<String, dynamic>> get sosRequests {
    return _allEntries
        .where(
          (Map<String, dynamic> entry) =>
              (entry['status'] as String).toLowerCase() == 'responded',
        )
        .toList();
  }

  String get selectedHistoryFilterStatus => _selectedHistoryFilterStatus;
  String get selectedHistorySortOrder => _selectedHistorySortOrder;

  void setHistoryFilterStatus(String status) {
    _selectedHistoryFilterStatus = status;
    notifyListeners();
  }

  void setHistorySortOrder(String order) {
    _selectedHistorySortOrder = order;
    notifyListeners();
  }

  /// Convert MM/DD/YYYY to DateTime
  DateTime _parseDate(String mmddyyyy) {
    final List<String> parts = mmddyyyy.split('/');
    if (parts.length != 3) return DateTime.now();
    final int month = int.tryParse(parts[0]) ?? 1;
    final int day = int.tryParse(parts[1]) ?? 1;
    final int year = int.tryParse(parts[2]) ?? 1970;
    return DateTime(year, month, day);
  }

  /// Returns a list of history entries filtered by status and sorted by date.
  List<Map<String, dynamic>> get filteredEntries {
    List<Map<String, dynamic>> filtered = _allEntries.toList();

    // Filter by status first
    if (_selectedHistoryFilterStatus != 'All') {
      filtered = filtered
          .where(
            (Map<String, dynamic> entry) =>
                (entry['status'] as String).toLowerCase() ==
                _selectedHistoryFilterStatus.toLowerCase(),
          )
          .toList();
    }

    // Then sort by date
    filtered.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      final DateTime dateA = _parseDate(a['date'] as String);
      final DateTime dateB = _parseDate(b['date'] as String);

      if (_selectedHistorySortOrder == 'Newest') {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    return filtered;
  }

  /// Updates the status of a specific history entry and notifies listeners.
  void updateEntryStatus(Map<String, dynamic> entry, String newStatus) {
    if ((entry['status'] as String) == newStatus) return; // No change needed

    final List<String> validStatuses = <String>[
      'Responded',
      'Completed',
      'Cancelled',
    ];
    if (validStatuses.contains(newStatus)) {
      final int index = _allEntries.indexOf(entry);
      if (index != -1) {
        _allEntries[index]['status'] = newStatus;
        notifyListeners();
      }
    }
  }

  // Helper functions for status colors
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF00BA00).withOpacity(0.50);
      case 'responded':
        return const Color(0xFFF0D210).withOpacity(0.60);
      case 'cancelled':
        return Colors.grey.withOpacity(0.60);
      default:
        return Colors.blueGrey.withOpacity(0.5);
    }
  }

  Color getStatusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF00BA00);
      case 'responded':
        return const Color(0xFFE3C610);
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(homePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
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
            SOSRequestsSection(),
            SizedBox(height: spacingMedium),
            Text(
              'History',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: "REM",
              ),
            ),
            SizedBox(height: spacingSmall),
            HistorySortOrderButtons(),
            SizedBox(height: spacingSmall),
            HistorySection(),
          ],
        ),
      ),
    );
  }
}

class SOSRequestsSection extends StatelessWidget {
  const SOSRequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Provider to access the AppHistoryManager
    final List<Map<String, dynamic>> sosRequests = context
        .watch<AppHistoryManager>()
        .sosRequests;

    if (sosRequests.isEmpty) {
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
      height: 250, // Updated height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sosRequests.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SOSCard(entry: sosRequests[index]),
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

    final String type = entry['type'] as String;
    final String date = entry['date'] as String;
    final String description = entry['description'] as String;
    final double latitude = entry['latitude'] as double;
    final double longitude = entry['longitude'] as double;

    return Container(
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
                    type,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: "REM",
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                                  HistoryDetailsScreen(historyEntry: entry),
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
                        child: const Text('Responder'),
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

class HistorySortOrderButtons extends StatelessWidget {
  const HistorySortOrderButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final AppHistoryManager manager = context.watch<AppHistoryManager>();
    final AppHistoryManager managerWriter = context.read<AppHistoryManager>();
    final String currentSortOrder = manager.selectedHistorySortOrder;

    return Row(
      children: <Widget>[
        HistoryFilterButton(
          label: 'Newest',
          isSelected: currentSortOrder == 'Newest',
          onSetSort: managerWriter.setHistorySortOrder,
        ),
        HistoryFilterButton(
          label: 'Oldest',
          isSelected: currentSortOrder == 'Oldest',
          onSetSort: managerWriter.setHistorySortOrder,
        ),
      ],
    );
  }
}

class HistorySection extends StatelessWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> entries = context
        .watch<AppHistoryManager>()
        .filteredEntries;

    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No history entries found for the current filters.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int idx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: HistoryCard(entry: entries[idx]),
        );
      },
    );
  }
}

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> entry;

  const HistoryCard({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    final AppHistoryManager historyManager = context.read<AppHistoryManager>();

    final String status = entry['status'] as String;
    final String type = entry['type'] as String;
    final String date = entry['date'] as String;
    final String description = entry['description'] as String;
    final double latitude = entry['latitude'] as double;
    final double longitude = entry['longitude'] as double;

    // Use helper methods from AppHistoryManager for colors
    final Color statusColor = historyManager.getStatusColor(status);
    final Color statusBorderColor = historyManager.getStatusBorderColor(status);

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
          border: Border.all(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(12),
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
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: primaryColor, width: 2),
                ),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      type,
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
                      description,
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
}
