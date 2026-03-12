import 'package:firebase_core/firebase_core.dart';
import 'app_exception.dart';

class ErrorMapper {
  static String toUserMessage(Object error) {
    if (error is AppException) return error.message;

    if (error is FirebaseException) {
      return switch (error.code) {
        'unavailable' => 'İnternet bağlantısı yok',
        'permission-denied' => 'Bu işlem için yetkiniz yok',
        'not-found' => 'Kayıt bulunamadı',
        'already-exists' => 'Bu kayıt zaten mevcut',
        'resource-exhausted' => 'Günlük limit doldu, yarın tekrar dene',
        'unauthenticated' => 'Lütfen tekrar giriş yapın',
        _ => 'Bir hata oluştu. Tekrar dene.',
      };
    }

    return 'Beklenmeyen bir hata oluştu.';
  }
}
