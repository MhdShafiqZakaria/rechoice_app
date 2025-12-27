import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  //email sign in/login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //email sign up/register
  Future<UserCredential> register({
    required String email,
    required String password,
    // required String firstName,
    // required String lastName,
    // required String phoneNumber,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //user logout
  Future<void> logout() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  //user reset password
  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
  //
  // Future<void> updateUsername({required String username}) async {
  //   await currentUser!.updateDisplayName(username);
  // }

  // Future<void> deleteAccount({
  //   required String email,
  //   required String password,
  // }) async {
  //   AuthCredential credential = EmailAuthProvider.credential(
  //     email: email,
  //     password: password,
  //   );
  //   await currentUser!.reauthenticateWithCredential(credential);
  //   await currentUser!.delete();
  //   await firebaseAuth.signOut();
  // }
  //user change password
  Future<void> resetPwFromCurrPw({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  //google sign in
  // Future<UserCredential?> signInWithGoogle() async {
  //   await GoogleSignIn.instance.initialize();
  //   //begin interactive sign in process
  //   final GoogleSignInAccount gUser = await GoogleSignIn.instance
  //       .authenticate();

  //   //await auth details from request
  //   final GoogleSignInAuthentication gAuth = gUser.authentication;

  //   //create a new credential for user
  //   final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);

  //   //sign in
  //   return await firebaseAuth.signInWithCredential(credential);
  // } 
}
