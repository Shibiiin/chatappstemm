import 'package:chatappstemm/Stemm%20Chat%20App/presentation/theme/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/appRoutes.dart';
import '../widget/custom_Toast.dart';
import '../widget/custom_print.dart';

class AuthController with ChangeNotifier {
  final loginEmail = TextEditingController();
  final loginPassword = TextEditingController();

  final registerFullName = TextEditingController();
  final registerEmail = TextEditingController();
  final registerPhone = TextEditingController();
  final registerPassword = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  Future<User?> loginUser() async {
    _setLoading(true);

    try {
      final email = loginEmail.text.trim();
      final password = loginPassword.text.trim();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);
        await fetchCurrentUserDetails();

        customToastMsg("Login Success");
      }

      clearFields();
      return user;
    } on FirebaseAuthException catch (e) {
      customToastMsg("Login Failed: ${e.message}");
      errorPrint("FirebaseAuthException: ${e.code} - ${e.message}");
    } catch (e) {
      customToastMsg("Login Failed: $e");
      errorPrint("General Login Error: $e");
    } finally {
      fetchCurrentUserDetails();
      _setLoading(false);
      notifyListeners();
    }
    return null;
  }

  Future<void> register(
    BuildContext context,
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      _setLoading(true);
      customPrint("Register Started...");

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        customToastMsg("User ID not found after registration.");
        return;
      }

      await storeUserDataToFirestore(
        uid: uid,
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      customToastMsg("User Registered Successfully");

      await Future.delayed(const Duration(milliseconds: 500));
      await clearFields();
      await fetchCurrentUserDetails();
      if (context.mounted) {
        context.go(AppRoutes.dashboard);
      }
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      customToastMsg("Registration Failed: ${e.message}");
      errorPrint("FirebaseAuth Error: ${e.message}");
    } catch (e) {
      customToastMsg("An unexpected error occurred: $e");
      errorPrint("Register Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> storeUserDataToFirestore({
    required String uid,
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        await docRef.set({
          'uid': uid,
          'name': name.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'phoneNumber': phone.trim(),
          'profileImageUrl': '',
          'createdTime': Timestamp.now(),
          'editedTime': Timestamp.now(),
        });
        customPrint("User data stored to Firestore");
      } else {
        customPrint("User already exists in Firestore");
      }
    } catch (e) {
      errorPrint("Failed to store user data: $e");
      throw Exception("Firestore error: $e");
    }
  }

  String? userName;
  String? phoneNumber;
  Future<void> fetchCurrentUserDetails() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (docSnapshot.exists) {
          userName = docSnapshot.data()?['name'];
          phoneNumber = docSnapshot.data()?['phoneNumber'];
          notifyListeners();
        }
      }
      successPrint("Details fetched: Name - $userName, Phone - $phoneNumber");
    } catch (e) {
      errorPrint("Error fetching user details: $e");
      customToastMsg("Error fetching user details: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalStorage.userId);
    context.go(AppRoutes.login);
    notifyListeners();
  }

  clearFields() {
    loginEmail.clear();
    loginPassword.clear();
    registerFullName.clear();
    registerEmail.clear();
    registerPhone.clear();
    registerPassword.clear();
  }
}
