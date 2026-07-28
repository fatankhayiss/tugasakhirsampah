import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/auth_repository.dart';

class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Melakukan login Google Sign-In & Firebase Auth lalu sinkronisasi ke backend MySQL.
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Pastikan Firebase sudah diinisialisasi secara aman
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp();
        } catch (e) {
          throw Exception('Konfigurasi Firebase belum aktif. Pastikan file google-services.json sudah ada.');
        }
      }

      // Mulai alur Google Sign In native
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User membatalkan login
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      final String googleUid = firebaseUser?.uid ?? googleUser.id;
      final String email = firebaseUser?.email ?? googleUser.email;
      final String name = firebaseUser?.displayName ?? googleUser.displayName ?? 'Warga iTrashy';
      final String? photoUrl = firebaseUser?.photoURL ?? googleUser.photoUrl;

      // Kirim data ke backend MySQL (login jika ada, register otomatis jika baru)
      final repo = AuthRepository();
      return await repo.loginWithGoogleBackend(googleUid, email, name, photoUrl);
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Error: ${e.message ?? e.code}');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Gagal masuk dengan Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
  }
}
