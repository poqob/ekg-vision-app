import 'package:flutter_test/flutter_test.dart';
import 'package:ekg_vision/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService login', () {
    late AuthService authService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authService = AuthService();
    });

    test('Login with valid credentials fetches and saves user data', () async {
      final result = await authService.login(
        username: 'dag@mail.com',
        password: 'dag123123',
      );
      expect(result['success'], isTrue, reason: result['message']?.toString());
      expect(result['user'], isNotNull);
      expect(result['user']['username'], anyOf(['dag', 'dag@mail.com']));
      expect(result['user']['email'], 'dag@mail.com');
    });
  });
}
