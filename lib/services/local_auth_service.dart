import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../models/app_user.dart';
import 'auth_service.dart';

class LocalAuthService implements AuthService {
  static const String _sessionKey = 'logged_in_user_id';

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<AuthResult> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        return AuthResult(success: false, message: 'Email sudah terdaftar');
      }

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final salt = DateTime.now().microsecondsSinceEpoch.toString();
      final passwordHash = _hashPassword(password, salt);

      await db.insert('users', {
        'id': id,
        'nama': nama,
        'email': email,
        'password': passwordHash,
        'salt': salt,
      });

      return login(email: email, password: password);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan sistem');
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isEmpty) {
        return AuthResult(success: false, message: 'Email tidak ditemukan');
      }

      final userMap = result.first;
      final salt = userMap['salt'] as String;
      final passwordHash = _hashPassword(password, salt);

      if (userMap['password'] != passwordHash) {
        return AuthResult(success: false, message: 'Password salah');
      }

      final user = AppUser(
        id: userMap['id'] as String,
        nama: userMap['nama'] as String,
        email: userMap['email'] as String,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, user.id);

      return AuthResult(success: true, user: user);
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan sistem');
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_sessionKey);
      if (userId == null) return null;

      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) return null;

      final userMap = result.first;
      return AppUser(
        id: userMap['id'] as String,
        nama: userMap['nama'] as String,
        email: userMap['email'] as String,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}