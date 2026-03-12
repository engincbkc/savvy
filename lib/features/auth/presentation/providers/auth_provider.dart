import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:savvy/core/errors/app_exception.dart';
import 'package:savvy/core/providers/firebase_providers.dart';

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

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(firebaseAuthProvider).signOut();
    });
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
