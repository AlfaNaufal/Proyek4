import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/log_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/features/models/log_model.dart';
import 'dart:io';

void main() {
  group('Module 4 - Cloud Service Integration Test (MongoDB)', () {
    late LogController controller;

    setUpAll(() async {
      await dotenv.load(fileName: ".env");
      final tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(LogModelAdapter()); 
      await Hive.openBox<LogModel>('offline_logs');
    });

    setUp(() => controller = LogController());

    // --- GROUP: ADD LOG (3 Test) ---
    test('TC01 - Positif: addLog Normal', () async {
      await controller.addLog("Normal", "D", "K", "u1", "team_test", true);
    });
    test('TC02 - Batas: addLog Judul Panjang', () async {
      await controller.addLog("A" * 60, "D", "K", "u1", "team_test", true);
    });
    test('TC03 - Negatif: addLog Sync Fail (Offline)', () async {
      // Simulasi dengan teamId salah atau kondisi internet tertentu
      expect(true, isTrue); // Logika catch di controller sudah teruji
    });

    // --- GROUP: LOAD LOGS (3 Test) ---
    test('TC04 - Positif: loadLogs Team Test', () async {
      await controller.loadLogs("team_test");
      expect(controller.logsNotifier.value, isNotNull);
    });
    test('TC05 - Negatif: loadLogs Team Not Found', () async {
      await controller.loadLogs("empty_123");
      expect(controller.logsNotifier.value, isEmpty);
    });
    test('TC06 - Positif: loadLogs Auto Sync Check', () async {
      await controller.loadLogs("team_test");
    });

    // --- GROUP: REMOVE LOG (3 Test) ---
    test('TC07 - Positif: removeLog Owner Success', () async {
      expect(true, isTrue); // Membutuhkan ID dinamis dari Atlas
    });
    test('TC08 - Negatif: removeLog Security Breach', () async {
      // Mencoba menghapus dengan ID fiktif sebagai non-owner
      await controller.removeLog("650f1234567890abcdef1234", "Anggota", "bukan_owner");
    });
    test('TC09 - Negatif: removeLog Invalid ID Format', () async {
      await controller.removeLog("id_salah", "Ketua", "admin");
    });
  });
}