import 'package:aparcamientoszaragoza/Models/user-register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sms_autodetect/sms_autodetect.dart';

part 'RegisterProviders.g.dart';

class UserRegisterState extends StateNotifier<AsyncValue<UserCredential?>> {
  UserRegisterState() : super(const AsyncData(null));

  Future<UserCredential?> register(UserRegister user) async {

    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.mail,
        password: user.password
      );

      userCredential.user?.sendEmailVerification();
      userCredential.user?.updateDisplayName(user.username);
      userCredential.user?.updatePhotoURL(user.urlProfile);

      return userCredential;
    });
    return null;
  }
}

void authSecondFactor (UserCredential userCredential, UserRegister userToRegister) async {
  final session = await userCredential.user?.multiFactor.getSession();
  final auth = FirebaseAuth.instance;
  await auth.verifyPhoneNumber(
    multiFactorSession: session,
    phoneNumber: userToRegister.phoneNumber,
    verificationCompleted: (_) {},
    verificationFailed: (_) {},
    codeSent: (String verificationId, int? resendToken) async {
      // See `firebase_auth` example app for a method of retrieving user's sms code:
      // https://github.com/firebase/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart#L591
      final smsCode = await SmsAutoDetect().listenForCode;

      /*if (smsCode != null) {
        // Create a PhoneAuthCredential with the code
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        try {
          await user.multiFactor.enroll(
            PhoneMultiFactorGenerator.getAssertion(
              credential,
            ),
          );
        } on FirebaseAuthException catch (e) {
          print(e.message);
        }
      }*/
    },
    codeAutoRetrievalTimeout: (_) {},
  );
}

final registerUserProvider = StateNotifierProvider<
    UserRegisterState, AsyncValue<UserCredential?>>((ref) {
  return UserRegisterState();
});

@Riverpod(keepAlive: true)
Future<UserCredential?> fetchRegisterUser(FetchRegisterUserRef ref,
                                          String? mail,
                                          String? password) async {

  UserCredential userCredential;

  if (mail == null || password == null) {
    return null;
  }

  try {
    userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: mail,
      password: password
    );

    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
      return Future.error(e);
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
      return Future.error(e);
    }
  } catch (e) {
    print(e);
    return Future.error(e);
  }
  return null;
}
