import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/user_model.dart';
import 'package:expense_tracker/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Authentication Logic & UserModel Tests', () {
    test('UserModel serialization and deserialization', () {
      final user = UserModel(
        id: 'usr_123',
        name: 'Jane Doe',
        email: 'jane@example.com',
        token: 'sample_jwt_token',
      );

      final map = user.toMap();
      expect(map['id'], 'usr_123');
      expect(map['name'], 'Jane Doe');
      expect(map['email'], 'jane@example.com');
      expect(map['token'], 'sample_jwt_token');

      final revived = UserModel.fromMap(map);
      expect(revived.id, user.id);
      expect(revived.name, user.name);
      expect(revived.email, user.email);
      expect(revived.token, user.token);
    });

    test('AuthProvider Guest Mode & Logout transitions', () async {
      final auth = AuthProvider();
      expect(auth.isAuthenticated, false);

      auth.continueAsGuest();
      expect(auth.isAuthenticated, true);
      expect(auth.isGuest, true);
      expect(auth.currentUser?.name, 'Guest User');

      await auth.logout();
      expect(auth.isAuthenticated, false);
      expect(auth.currentUser, null);
    });
  });
}
