import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';

void main() {
  group('Module 2 - Authentication Test (Excel Integration)', () {
    late LoginController authController;

    setUp(() {
      authController = LoginController();
    });

    // TC01: Login Admin (Positif)
    test('TC01 - Should return user map for valid admin credentials', () {
      final result = authController.login('admin', '123');
      expect(result, isNotNull);
      expect(result!['username'], 'admin');
    });

    // TC02: Login Anggota (Positif)
    test('TC02 - Should return user map for valid member credentials', () {
      final result = authController.login('anggota1', '123');
      expect(result, isNotNull);
      expect(result!['role'], 'Anggota');
    });

    // TC03: Salah Password (Negatif)
    test('TC03 - Should return null for wrong password', () {
      final result = authController.login('admin', 'password_salah');
      expect(result, isNull);
    });

    // TC04: User Tidak Terdaftar (Negatif)
    test('TC04 - Should return null for non-existent user', () {
      final result = authController.login('naufal_user', '123');
      expect(result, isNull);
    });

    // TC05: Verifikasi Role (Positif)
    test('TC05 - Should verify Ketua role correctly', () {
      final result = authController.login('ketua', '123');
      expect(result!['role'], 'Ketua');
    });
  });
}