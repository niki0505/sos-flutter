import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<bool?> getRole(String username) async {
    try {
      final querySnapshot = await users
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return data['isAdmin'] as bool?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // READ

  // UPDATE

  // DELETE
}
