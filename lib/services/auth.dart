import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static AuthService? _instance;

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhoneSendOtp(String name,
      {void Function(PhoneAuthCredential)? completed,
      void Function(FirebaseAuthException)? failed,
      void Function(String, int?)? codeSent,
      void Function(String)? codeAutoRetriveTimeout}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: name,
      verificationCompleted: completed!,
      verificationFailed: failed!,
      codeSent: codeSent!,
      codeAutoRetrievalTimeout: codeAutoRetriveTimeout!,
    );
  }

  Future<String> verifyAndLogin(
    String verificationId,
    String smsCode,
    String phone,
  ) async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      final uid = userCredential.user!.uid;
      final userSnap =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userSnap.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'phone': phone,
        });
      }

      return uid;
    } else {
      return '';
    }
  }

  Future<String> getCredential(PhoneAuthCredential credential) async {
    final authCredential = await _auth.signInWithCredential(credential);
    return authCredential.user!.uid;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
