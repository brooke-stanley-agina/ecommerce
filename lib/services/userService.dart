import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:jwt_decode/jwt_decode.dart';

class UserService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FlutterSecureStorage? _storage;

  UserService() {
    initializeFirebaseApp();
  }

  void initializeFirebaseApp() async {
    bool internetConnection = await InternetConnectionChecker().hasConnection;

    if (internetConnection) {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = const FlutterSecureStorage();
    }
  }

  int? statusCode;
  String? msg;

  void storeJWTToken(String idToken, refreshToken) async {
    await _storage!.write(key: "idToken", value: idToken);
    await _storage!.write(key: 'refreshToken', value: refreshToken);
  }

  String validateToken(String token) {
    bool isExpired = Jwt.isExpired(token);

    if (isExpired) {
      return "Token has Expired";
    } else {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      return payload['user_id'];
    }
  }

  Future<void> signUp(userValues) async {
    String email = userValues['emails'];
    String password = userValues['password'];

    await _auth!
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((dynamic user) {
      String uid = user.user.uid;
      _firestore!.collection("users").add({
        'fullName': userValues['fullName'],
        'mobileNumber': userValues["mobileNumber"],
        'userId': uid
      });

      statusCode = 200;
    }).catchError((error) {
      handleAuthErrors(error);
    });
  }

  Future<void> login(userValues) async {
    String email = userValues['emails']!;
    String password = userValues['password'];

    await _auth!
        .signInWithEmailAndPassword(email: email, password: password)
        .then((dynamic user) async {
      final User? currentUser = _auth!.currentUser;
      String? idToken = await currentUser!.getIdToken();
      String? refreshToken = currentUser.refreshToken;

      storeJWTToken(idToken!, refreshToken);

      statusCode = 200;
    }).catchError((error) {
      handleAuthErrors(error);
    });
  }

  Future<String> getUserId() async {
    var token = await _storage!.read(key: "idToken");
    var uid = validateToken(token!);
    return uid;
  }

  void logOut(context) async {
    await _storage!.deleteAll();
    Navigator.pushReplacementNamed(context,'/login');
  }

  void handleAuthErrors(error) {
    String errorCode = error.code;

    switch (errorCode) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
        {
          statusCode = 400;
          msg = "Email ID already exists";
        }
      case "ERROR_WRONG_PASSWORD":
        {
          statusCode = 400;
          msg = "Wrong Password!";
        }
    }
  }


  
}
