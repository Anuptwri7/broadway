import 'dart:developer';
import 'package:classboradway/extraDose/getWeather.dart';
import 'package:classboradway/loginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    signInOption: SignInOption.standard,
  );

  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      googleUser ??= await _googleSignIn.signIn();
      if (googleUser == null) {
        log("Google sign-in was cancelled by the user.");
        return null;
      }
      log("Google User Selected:");
      log("Email: ${googleUser.email}");
      log("Display Name: ${googleUser.displayName}");
      log("ID: ${googleUser.id}");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        log("Firebase User Info:");
        log("UID: ${user.uid}");
        log("Email: ${user.email}");
        log("Name: ${user.displayName}");
        log("Photo URL: ${user.photoURL}");
      }
      return userCredential;
    } catch (e, stacktrace) {
      print("Google Sign-In Error: $e");
      print("StackTrace: $stacktrace");
      return null;
    }
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;



  Future<void> registerUser(String email,String password,String name,String phone,String gender) async {
    try {

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      final User? user = userCredential.user;


    } catch (e, stacktrace) {
      print("Registration Error: $e");
      print("StackTrace: $stacktrace");
    }
  }
  Future<User?> loginUser(String email, String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

    preferences.setString("email", email);
    preferences.setString("password", password);
      final User? user = userCredential.user;

      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      final userData = userSnapshot.data() as Map<String, dynamic>?;
      log("user email:"+userData.toString());
      print("Login successful: ${user?.email}");
      return user;
    } catch (e, stacktrace) {
      print("Login Error: $e");
      print("StackTrace: $stacktrace");
      return null;
    }
  }
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
      log(" User signed out successfully.");
    } catch (e, stacktrace) {
      log(" Sign-Out Error: $e");
      log("StackTrace: $stacktrace");
    }
  }
}
