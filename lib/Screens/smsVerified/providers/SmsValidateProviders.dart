import 'package:aparcamientoszaragoza/Models/user-register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_autodetect/sms_autodetect.dart';

class SmsValidateState extends StateNotifier<AsyncValue<bool?>> {
  SmsValidateState() : super(const AsyncData(null));

  Future<bool?> verifiedSMS(String phoneNumber) async {

    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      authSecondFactor(phoneNumber);
    });
    return null;
  }
}

void authSecondFactor (String phoneNumber) async {
  final session = await FirebaseAuth.instance.currentUser?.multiFactor.getSession();
  final auth = FirebaseAuth.instance;
  await auth.verifyPhoneNumber(
    multiFactorSession: session,
    phoneNumber: phoneNumber,
    verificationCompleted: (_) {},
    verificationFailed: (_) {},
    codeSent: (String verificationId, int? resendToken) async {
      // See `firebase_auth` example app for a method of retrieving user's sms code:
      // https://github.com/firebase/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart#L591
      await SmsAutoDetect().listenForCode;
      var codeString = await SmsAutoDetect().code.single;
      // Create a PhoneAuthCredential with the code
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: codeString.toString(),
      );

      try {
        await FirebaseAuth.instance.currentUser?.multiFactor.enroll(
          PhoneMultiFactorGenerator.getAssertion(
            credential,
          ),
        );
      } on FirebaseAuthException catch (e) {
        print(e.message);
      }
    },
    codeAutoRetrievalTimeout: (_) {},
  );
}

final smsValidateProvider = StateNotifierProvider<
    SmsValidateState, AsyncValue<bool?>>((ref) {
  return SmsValidateState();
});
