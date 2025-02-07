// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jm_senior/services/firestore_service.dart';
class AuthService{

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {

    try {

       await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );


    } on FirebaseAuthException catch(e) {
      
      if (e.code == 'invalid-email' || e.code =='user-not-found') {
        throw Exception('No User found for that Email');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Wrong password provided for that user.');
      }else{
        throw Exception('Error logging in: $e');
      }
    }catch(e){
      throw Exception('An Error Occured: $e');
    }
  }
  Future<void> signup({
    required String username,
    required String email,
    required String password,

    required BuildContext context
  }) async {

    try {

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      String userId = userCredential.user!.uid;

       await FirestoreService().addUser(
        userId: userId,
        username: username,
        email: email,
      );



    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists with that email.');
      }else{
        throw Exception('Error creating account: $e');
      }

    }
  }

  Future<void> signout({
    required BuildContext context
  }) async {
    await FirebaseAuth.instance.signOut();
  }
}

