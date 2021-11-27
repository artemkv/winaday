import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleSignInFacade {
  // Source: https://firebase.flutter.dev/docs/auth/social
  static Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  static void subscribeToIdTokenChanges(void Function(String) onSignIn,
      void Function() onSignOut, void Function(String) onSignInFailed) {
    FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (user == null) {
        onSignOut();
      } else {
        user.getIdToken().then((idToken) {
          onSignIn(idToken);
        }).catchError((err) {
          onSignInFailed(err);
        });
      }
    });
  }

  static Future<GoogleSignInAccount> signOut() async {
    return await FirebaseAuth.instance
        .signOut()
        .then((_) => GoogleSignIn().signOut());
  }
}
