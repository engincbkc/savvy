import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/errors/app_exception.dart';
import 'package:savvy/core/providers/firebase_providers.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
    });
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final credential =
          await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
                email: email.trim(),
                password: password,
              );
      await credential.user?.updateDisplayName(name.trim());
    });
  }

  Future<void> resetPassword({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthProvider).sendPasswordResetEmail(
            email: email.trim(),
          );
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final googleUser = await googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await ref.read(firebaseAuthProvider).signInWithCredential(credential);
    });
  }

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await ref
          .read(firebaseAuthProvider)
          .signInWithCredential(oauthCredential);

      // Apple only sends name on first sign-in
      if (appleCredential.givenName != null) {
        final name =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (name.isNotEmpty) {
          await userCredential.user?.updateDisplayName(name);
        }
      }
    });
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signOut() async {
    // Use FirebaseAuth.instance directly to avoid ref disposal race condition.
    // When signOut triggers authStateChanges, the router redirects and
    // this provider gets disposed before the await completes.
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }

  String mapFirebaseError(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'user-not-found' => 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.',
        'wrong-password' => 'Şifre hatalı.',
        'email-already-in-use' => 'Bu e-posta zaten kullanılıyor.',
        'weak-password' => 'Şifre en az 6 karakter olmalıdır.',
        'invalid-email' => 'Geçerli bir e-posta adresi giriniz.',
        'too-many-requests' =>
          'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.',
        'network-request-failed' => 'İnternet bağlantınızı kontrol edin.',
        _ => 'Bir hata oluştu. Tekrar deneyin.',
      };
    }
    if (error is AuthException) return error.message;
    return 'Beklenmeyen bir hata oluştu.';
  }
}
