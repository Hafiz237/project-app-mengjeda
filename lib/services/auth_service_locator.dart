import 'auth_service.dart';
import 'local_auth_service.dart';

class AuthServiceLocator {
  static AuthService instance = LocalAuthService();
}