import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Required for Future/async operations

void main() {
  runApp(const ResqApp());
}

// REUSABLE COLORS & SPACING
const Color primaryColor = Color(0xFFFA5246);
const Color secondaryColor = Color(0xFF808080);
const double homePadding = 20.0;
const double spacingSmall = 15.0;
const double spacingMedium = 20.0;

/// Represents a single historical entry or SOS request.
class HistoryEntry {
  final String type;
  final String date;
  final String description;
  String status; // 'Responded', 'Completed', 'Cancelled'
  final double latitude;
  final double longitude;

  HistoryEntry({
    required this.type,
    required this.date,
    required this.description,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  // Factory constructor to create a HistoryEntry from a map.
  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      type: map['type'] as String,
      date: map['date'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }

  // To convert HistoryEntry back to a map, useful for passing arguments
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'date': date,
      'description': description,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // computed getter for fill colour
  Color get statusColor {
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

  // computed getter for border colour
  Color get statusBorderColor {
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

/// Manages and filters a list of historical entries, notifying listeners of changes.
class AppHistoryManager extends ChangeNotifier {
  String _selectedDateSort = 'Newest'; // Sort for history section status

  final List<HistoryEntry> _allEntries = <HistoryEntry>[
    // History entries matching the new layout's default entries
    HistoryEntry(
      type: 'Medical',
      date: '10/18/2025',
      description: 'Blk 123 Street. Aniban 2',
      status: 'Completed',
      latitude: 14.5995,
      longitude: 120.9842,
    ),
    HistoryEntry(
      type: 'Fire',
      date: '10/16/2025',
      description: 'Blk 123 Street. Aniban 2',
      status: 'Completed',
      latitude: 14.6190,
      longitude: 120.9820,
    ),
    HistoryEntry(
      type: 'Earthquake',
      date: '10/14/2025',
      description: 'Blk 123 Street. Aniban 2',
      status: 'Cancelled',
      latitude: 14.6190,
      longitude: 120.9820,
    ),
    HistoryEntry(
      type: 'Medical',
      date: '10/21/2025',
      description: 'Urgent medical assistance needed at Block 456, Road XYZ.',
      status: 'Responded',
      latitude: 14.6050,
      longitude: 120.9860,
    ),
  ];

  List<HistoryEntry> get sosRequests {
    return _allEntries.toList();
  }

  /// Returns the current status filter for history entries.
  String get selectedDateSort => _selectedDateSort;

  /// Set the current sort type and notify listeners
  void setDateSort(String sortType) {
    _selectedDateSort = sortType;
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

  /// Returns a list of history entries filtered by `_selectedFilter`.
  List<HistoryEntry> get filteredEntries {
    // Define the allowed statuses (lowercase for consistent comparison)
    final List<String> allowedStatuses = <String>['cancelled', 'responded', 'completed'];

    // Filter entries by allowed statuses
    List<HistoryEntry> filtered = _allEntries
        .where((HistoryEntry entry) => allowedStatuses.contains(entry.status.toLowerCase()))
        .toList();

    // Sort by date based on _selectedDateSort
    filtered.sort((HistoryEntry a, HistoryEntry b) {
      final DateTime dateA = _parseDate(a.date);
      final DateTime dateB = _parseDate(b.date);

      if (_selectedDateSort == 'Newest') {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    return filtered;
  }

  /// Updates the status of a specific history entry and notifies listeners.
  void updateEntryStatus(HistoryEntry entry, String newStatus) {
    if (entry.status == newStatus) return; // No change needed

    final List<String> validStatuses = <String>['Responded', 'Completed', 'Cancelled'];
    if (validStatuses.contains(newStatus)) {
      final int index = _allEntries.indexOf(entry);
      if (index != -1) {
        _allEntries[index].status = newStatus;
        notifyListeners();
      }
    }
  }
}

class ResqApp extends StatelessWidget {
  const ResqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppHistoryManager>(
      create: (BuildContext context) => AppHistoryManager(),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFFAFAFA),
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              primary: primaryColor,
              onPrimary: Colors.white,
              secondary: secondaryColor,
              onSecondary: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 1,
              foregroundColor: primaryColor,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
              ),
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(homePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome to RESQ!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'REM',
                ),
              ),
              const SizedBox(height: spacingMedium),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: spacingSmall),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: spacingMedium),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<HomeScreen>(builder: (BuildContext context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: <Widget>[
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
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()),
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
        children: <Widget>[
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(homePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SOS Requests',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFA5246),
                        fontFamily: 'REM',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SOSRequestsSection(),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'History',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFA5246),
                        fontFamily: 'REM',
                      ),
                    ),
                  ),
                  const SizedBox(height: spacingSmall),
                  const HistoryFilterSortButtons(),
                  const SizedBox(height: spacingMedium),
                  const HistorySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PendingSOSScreen extends StatelessWidget {
  const PendingSOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending SOS'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 20),
            const Text(
              'Waiting for help...',
              style: TextStyle(fontSize: 20, color: secondaryColor),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Cancel SOS'),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryDetailsScreen extends StatelessWidget {
  final HistoryEntry historyEntry;

  const HistoryDetailsScreen({required this.historyEntry, super.key});

  @override
  Widget build(BuildContext context) {
    final AppHistoryManager historyManager = context.read<AppHistoryManager>();

    Color buttonColor;
    String buttonText;
    Function()? onPressed;

    switch (historyEntry.status.toLowerCase()) {
      case 'responded':
        buttonColor = const Color.fromARGB(255, 255, 223, 107);
        buttonText = 'Complete Call';
        onPressed = () {
          historyManager.updateEntryStatus(historyEntry, 'Completed');
          Navigator.pop(context);
        };
        break;
      case 'completed':
        buttonColor = const Color.fromARGB(255, 124, 203, 128);
        buttonText = 'Completed';
        onPressed = null;
        break;
      case 'cancelled':
        buttonColor = Colors.grey[400]!;
        buttonText = 'Cancelled';
        onPressed = null;
        break;
      default:
        buttonColor = Colors.grey[300]!;
        buttonText = 'Unknown Status';
        onPressed = null;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(historyEntry.type),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(homePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              historyEntry.type,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: "REM",
              ),
            ),
            const SizedBox(height: spacingSmall),
            Text(
              'Date: ${historyEntry.date}',
              style: const TextStyle(fontSize: 18, color: secondaryColor),
            ),
            const SizedBox(height: spacingSmall / 2),
            Text(
              'Status: ${historyEntry.status}',
              style: TextStyle(
                  fontSize: 18,
                  color: historyEntry.status.toLowerCase() == 'completed'
                      ? Colors.green
                      : historyEntry.status.toLowerCase() == 'responded'
                          ? Colors.orange
                          : Colors.grey),
            ),
            const SizedBox(height: spacingSmall),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              historyEntry.description,
              style: const TextStyle(fontSize: 16, color: secondaryColor),
            ),
            const SizedBox(height: spacingMedium),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(historyEntry.latitude, historyEntry.longitude),
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.frontend',
                    ),
                    MarkerLayer(
                      markers: <Marker>[
                        Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(historyEntry.latitude, historyEntry.longitude),
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
            const SizedBox(height: spacingMedium),
            Center(
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
    final List<HistoryEntry> sosRequests = context.watch<AppHistoryManager>().sosRequests;

    if (sosRequests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No active SOS requests.', style: TextStyle(color: secondaryColor)),
        ),
      );
    }

    return SizedBox(
      height: 250,
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
  final HistoryEntry entry;
  const SOSCard({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).primaryColor;
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
                  initialCenter: LatLng(entry.latitude, entry.longitude),
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: <Widget>[
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.frontend',
                  ),
                  MarkerLayer(
                    markers: <Marker>[
                      Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(entry.latitude, entry.longitude),
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
                    entry.type,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    entry.date,
                    style: const TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => HistoryDetailsScreen(historyEntry: entry),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
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
              border: Border.all(color: primaryColor.withOpacity(0.45), width: 2),
            ),
            child: ElevatedButton(
              onPressed: () {
                onSetSort(label);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
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

class HistoryFilterSortButtons extends StatelessWidget {
  const HistoryFilterSortButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final AppHistoryManager manager = context.watch<AppHistoryManager>();
    final AppHistoryManager managerWriter = context.read<AppHistoryManager>();
    final String currentSort = manager.selectedDateSort;

    return Row(
      children: <Widget>[
        HistoryFilterButton(
          label: 'Newest',
          isSelected: currentSort == 'Newest',
          onSetSort: managerWriter.setDateSort,
        ),
        HistoryFilterButton(
          label: 'Oldest',
          isSelected: currentSort == 'Oldest',
          onSetSort: managerWriter.setDateSort,
        ),
      ],
    );
  }
}

class HistorySection extends StatelessWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<HistoryEntry> entries = context.watch<AppHistoryManager>().filteredEntries;

    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No history entries found for the current filters.', style: TextStyle(color: Colors.grey)),
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
  final HistoryEntry entry;

  const HistoryCard({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => HistoryDetailsScreen(historyEntry: entry),
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
                border: Border(right: BorderSide(color: primaryColor, width: 2)),
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
                    initialCenter: LatLng(entry.latitude, entry.longitude),
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.frontend',
                    ),
                    MarkerLayer(
                      markers: <Marker>[
                        Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(entry.latitude, entry.longitude),
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
                      entry.type,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: "REM",
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.description,
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
                          color: entry.statusColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: entry.statusBorderColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          entry.status.toUpperCase(),
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