abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

class AppFailure extends Failure {
  const AppFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class AudioFailure extends Failure {
  const AudioFailure(super.message, {super.code});
}

class UploadFailure extends Failure {
  const UploadFailure(super.message, {super.code});
}
