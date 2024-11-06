abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
   final String email;

  Authenticated({required this.email});
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class Unauthenticated extends AuthState {}
