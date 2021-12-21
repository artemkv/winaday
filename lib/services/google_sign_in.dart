import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
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
    // This only fires once when user signs in initially
    // When id_token expires, this callback does not fire unless you are
    // requesting id_token explicitly and forcing it to refresh
    FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (user == null) {
        onSignOut();
      } else {
        user.getIdToken().then((idToken) {
          onSignIn(idToken);
        }).catchError((err) {
          onSignInFailed(err.toString());
        });
      }
    });
  }

  static Future<GoogleSignInAccount> signOut() async {
    return await FirebaseAuth.instance
        .signOut()
        .then((_) => GoogleSignIn().signOut());
  }

  static Future<String> getIdToken() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.getIdToken(false);
    }
    throw "Current user is NULL";
  }
}
