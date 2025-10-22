import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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
        await docRef.update({'status': 'Cancelled'});
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // READ

  // UPDATE

  // DELETE
}
