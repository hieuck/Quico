sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class PermissionException extends AppException {
  const PermissionException(super.message);
}

class OcrException extends AppException {
  const OcrException(super.message);
}

class SpeechException extends AppException {
  const SpeechException(super.message);
}

class ParserException extends AppException {
  const ParserException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
