import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/log_controller.dart';
import 'package:logbook_app_001/features/models/log_model.dart';
import 'dart:io';

void main() {
  group('Module 3 - LogController Storage Test (Hive)', () {
    late LogController controller;
    late Box<LogModel> mockBox;
    const String testBoxName = 'offline_logs';

    setUp(() async {
      // 1. Inisialisasi DotEnv secara Manual (Bypass method testLoad)
      // Kita menggunakan loadData agar tidak perlu method testLoad
      // dotenv.testLoad(fileInput: 'MONGO_URL=test\nDB_NAME=test');
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        // Jika file tidak ada, biarkan saja agar tidak crash
      }

      // 2. Inisialisasi Hive dengan direktori Temp
      final tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);

      // 3. Registrasi Adapter
      if (!Hive.isAdapterRegistered(0)) { 
        Hive.registerAdapter(LogModelAdapter()); 
      }

      // 4. Buka Box secara bersih
      mockBox = await Hive.openBox<LogModel>(testBoxName);
      await mockBox.clear();

      controller = LogController();
    });

    tearDown(() async {
      await Hive.close();
    });

    // --- TEST CASES ---

    test('TC01 - addLog should save data to Hive box', () async {
      // exercise
      await controller.addLog("Judul Tes", "Desc", "Kat", "user1", "team1", true);
      
      // verify
      expect(mockBox.length, 1);
      expect(mockBox.values.first.title, "Judul Tes");
    });

    test('TC04 - updateLog should modify existing data in Hive', () async {
      // setup
      await controller.addLog("Lama", "D", "K", "u1", "t1", true);
      String id = mockBox.values.first.id!;
      
      // exercise
      await controller.updateLog(id, "Baru", "New Desc", "New Kat", false);
      
      // verify
      expect(mockBox.values.first.title, "Baru");
    });

    test('TC08 - removeLog should fail if unauthorized (Security Check)', () async {
      // setup
      await controller.addLog("Log Admin", "D", "K", "admin", "t1", true);
      String id = mockBox.values.first.id!;
      
      // exercise: Dihapus oleh user lain
      await controller.removeLog(id, "Anggota", "user_lain");
      
      // verify
      expect(mockBox.length, 1);
      expect(mockBox.values.first.title, "Log Admin");
    });
  });
}