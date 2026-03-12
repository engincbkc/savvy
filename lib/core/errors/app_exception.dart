sealed class AppException implements Exception {
  const AppException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  const NetworkException()
      : super('İnternet bağlantısı yok', code: 'NETWORK');
}

class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Bu işlem için giriş yapınız', code: 'UNAUTHORIZED');
}

class ValidationException extends AppException {
  final String field;
  const ValidationException(super.message, {required this.field});
}

class AiException extends AppException {
  const AiException(super.message, {super.code});
}

class AiRateLimitException extends AppException {
  const AiRateLimitException()
      : super('AI analizi şu an kullanılamıyor. Daha sonra tekrar dene.',
            code: 'AI_RATE_LIMIT');
}
