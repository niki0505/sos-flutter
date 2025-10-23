import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class FirestoreService {
  // get collection of sos
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );
  final CollectionReference sos = FirebaseFirestore.instance.collection('sos');

  // CREATE USER
  Future<void> addUser(
    String firstname,
    String lastname,
    String sex,
    String birthdate,
    String mobilenum,
    String username,
    String password,
  ) {
    DateTime birthdateParsed = DateFormat('MM-dd-yyyy').parse(birthdate);

    int age = _calculateAge(birthdateParsed);
    return users.add({
      'firstname': firstname,
      'lastname': lastname,
      'sex': sex,
      'birthdate': birthdate,
      'age': age,
      'mobilenum': mobilenum,
      'username': username,
      'password': password,
      'isAdmin': false,
      'createdAt': Timestamp.now(),
    });
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // VALIDATE USER CREDENTIALS
  Future<String?> getPasswordByUsername(String username) async {
    try {
      final querySnapshot = await users
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return data['password'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // CHECK IF ITS ADMIN
  Future<Map<String, Object?>?> getRole(String username) async {
    try {
      final querySnapshot = await users
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return {'userID': doc.id, 'isAdmin': data['isAdmin'] as bool?};
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // CREATE SOS
  Future<void> addSOS(String? userID, Position currentPosition) {
    return sos.add({
      'userID': userID,
      'status': "Pending",
      'requestedAt': Timestamp.now(),
      'location': GeoPoint(currentPosition.latitude, currentPosition.longitude),
      'responders': [],
    });
  }

  // CHECK FOR THE ONGOING SOS
  Future<Map<String, dynamic>?> getOngoingSOS(String userID) async {
    try {
      final querySnapshot = await sos
          .where('userID', isEqualTo: userID)
          .where('status', whereIn: ['Pending', 'Ongoing'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['docID'] = doc.id;
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // CANCEL SOS
  Future<bool> cancelSOS(String sosID) async {
    try {
      final docRef = sos.doc(sosID);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update({
          'status': 'Cancelled',
          'completedAt': Timestamp.now(),
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // FETCH PENDING AND ONGOING REPORTS
  Future<List<Map<String, dynamic>>> fetchPendingReports() async {
    try {
      final querySnapshot = await sos
          .where('status', whereIn: ['Pending', 'Ongoing'])
          .get();

      final reports = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;
          data['docID'] = doc.id;

          // Fetch corresponding user info
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userID'])
              .get();

          if (userDoc.exists) {
            data['user'] = userDoc.data();
          }

          final GeoPoint loc = data['location'];
          final address = await getAddressFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          data['address'] = address;

          return data;
        }),
      );

      return reports;
    } catch (e) {
      print('Error fetching pending reports: $e');
      return [];
    }
  }

  // TRANSLATE COORDINATES TO READABLE ADDRESS
  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      Placemark place = placemarks.first;

      return "${place.street}, ${place.subLocality}, ${place.locality}, "
          "${place.administrativeArea}, ${place.country}";
    } catch (e) {
      print("Error in reverse geocoding: $e");
      return "Unknown location";
    }
  }

  // HEADING SOS
  Future<void> headingSOS(String? userID, String sosID) async {
    final sosDoc = await sos.doc(sosID).get();

    if (!sosDoc.exists) return;

    // Cast to Map<String, dynamic>
    final currentData = sosDoc.data() as Map<String, dynamic>;
    final List<dynamic> responders = currentData['responders'] ?? [];
    bool userFound = false;

    // Check if anyone has already headed
    final hasAnyHeading = responders.any((r) => r['status'] == 'Heading');

    // Update existing responder if exists
    final updatedResponders = responders.map((r) {
      if (r['userID'] == userID) {
        userFound = true;
        return {...r, 'status': 'Heading', 'arrivedAt': null};
      }
      return r;
    }).toList();

    // If not found, add new responder
    if (!userFound) {
      updatedResponders.add({
        'userID': userID,
        'status': 'Heading',
        'isHead': !hasAnyHeading,
      });
    }

    // Update status if Pending
    final updateData = {
      'responders': updatedResponders,
      if (currentData['status'] == 'Pending') 'status': 'Ongoing',
    };

    await sos.doc(sosID).update(updateData);
  }

  // ARRIVED SOS
  Future<void> arrivedSOS(String? userID, String sosID) async {
    final sosDoc = await sos.doc(sosID).get();

    if (!sosDoc.exists) return;

    // Cast to Map<String, dynamic>
    final currentData = sosDoc.data() as Map<String, dynamic>;
    final List<dynamic> responders = currentData['responders'] ?? [];

    // Update existing responder if exists
    final updatedResponders = responders.map((r) {
      if (r['userID'] == userID) {
        return {...r, 'status': 'Arrived', 'arrivedAt': Timestamp.now()};
      }
      return r;
    }).toList();
    await sos.doc(sosID).update({'responders': updatedResponders});
  }

  // DID NOT ARRIVE SOS
  Future<void> didntArriveSOS(String? userID, String sosID) async {
    final sosDoc = await sos.doc(sosID).get();

    if (!sosDoc.exists) return;

    // Cast to Map<String, dynamic>
    final currentData = sosDoc.data() as Map<String, dynamic>;
    final List<dynamic> responders = currentData['responders'] ?? [];

    // Update existing responder if exists
    final updatedResponders = responders.map((r) {
      if (r['userID'] == userID) {
        final updated = {...r, 'status': 'Did Not Arrive'};
        updated.remove('isHead');
        return updated;
      }
      return r;
    }).toList();
    await sos.doc(sosID).update({'responders': updatedResponders});
  }

  // VERIFY SOS
  Future<void> verifySOS(String sosID, String reportDetails) async {
    final sosDoc = await sos.doc(sosID).get();

    if (!sosDoc.exists) return;

    final currentData = sosDoc.data() as Map<String, dynamic>;
    final updateData = {
      if (currentData['status'] == 'Ongoing') 'status': 'Resolved',
      'reportdetails': reportDetails,
      'completedAt': Timestamp.now(),
    };

    await sos.doc(sosID).update(updateData);
  }

  // FALSE ALARM SOS
  Future<void> falseAlarmSOS(String sosID, String reportDetails) async {
    final sosDoc = await sos.doc(sosID).get();

    if (!sosDoc.exists) return;

    final currentData = sosDoc.data() as Map<String, dynamic>;
    final updateData = {
      if (currentData['status'] == 'Ongoing') 'status': 'False Alarm',
      'reportdetails': reportDetails,
      'completedAt': Timestamp.now(),
    };

    await sos.doc(sosID).update(updateData);
  }

  // FETCH COMPLETED REPORTS
  Future<List<Map<String, dynamic>>> fetchCompletedReports() async {
    try {
      final querySnapshot = await sos
          .where('status', whereIn: ['Resolved', 'False Alarm'])
          .get();

      final reports = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;
          data['docID'] = doc.id;

          // Fetch corresponding user info
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userID'])
              .get();

          if (userDoc.exists) {
            data['user'] = userDoc.data();
          }

          final GeoPoint loc = data['location'];
          final address = await getAddressFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          data['address'] = address;

          return data;
        }),
      );

      return reports;
    } catch (e) {
      print('Error fetching completed reports: $e');
      return [];
    }
  }

  // FETCH SOS HISTORY
  Future<List<Map<String, dynamic>>> getSOSHistory(String userID) async {
    try {
      final querySnapshot = await sos
          .where('userID', isEqualTo: userID)
          .where('status', whereIn: ['Cancelled', 'False Alarm', 'Resolved'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> reports = [];

        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['docID'] = doc.id;
          final GeoPoint loc = data['location'];
          final address = await getAddressFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          data['address'] = address;
          reports.add(data);
        }

        return reports;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
