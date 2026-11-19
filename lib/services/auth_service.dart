import '../models/app_user.dart';

class AuthResult {
  final bool success;
  final String? message;
  final AppUser? user;

  AuthResult({
    required this.success,
    this.message,
    this.user,
  });
}

abstract class AuthService {
  Future<AuthResult> register({
    required String nama,
    required String email,
    required String password,
  });

  Future<AuthResult> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<AppUser?> getCurrentUser();

  Future<bool> isLoggedIn();
}