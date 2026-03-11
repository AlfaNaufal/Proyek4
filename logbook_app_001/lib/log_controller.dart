import 'dart:convert'; // Wajib ditambahkan untuk jsonEncode & jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Box;
import 'package:logbook_app_001/features/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/services/access_control_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  // List<LogModel> _cachedLogs = [];

  late final Box<LogModel> _myBox;

  LogController() {
    // Hubungkan controller dengan box Hive lokal
    _myBox = Hive.box<LogModel>('offline_logs');
  }

  Future<void> loadLogs(String teamId) async {
    // Langkah 1: Ambil data dari Hive (Sangat Cepat/Instan)
    logsNotifier.value = _myBox.values.toList();

    // Langkah 2: Sync dari Cloud (Background)
    try {
      final cloudData = await MongoService().getLogs(teamId);

      // Update Hive dengan data terbaru dari Cloud agar sinkron
      await _myBox.clear();
      await _myBox.addAll(cloudData);

      // Update UI dengan data Cloud
      logsNotifier.value = cloudData;

      await LogHelper.writeLog(
        "SYNC: Data berhasil diperbarui dari Atlas",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "OFFLINE: Menggunakan data cache lokal",
        level: 2,
      );
    }
  }

  /// 2. ADD DATA (Instant Local + Background Cloud)
  Future<void> addLog(
    String title,
    String desc,
    String category,
    String authorId,
    String teamId,
  ) async {
    final newLog = LogModel(
      id: ObjectId().oid, // Menggunakan .oid (String) untuk Hive
      title: title,
      description: desc,
      category: category,
      date: DateTime.now(),
      authorId: authorId,
      teamId: teamId,
    );

    // ACTION 1: Simpan ke Hive (Instan)
    await _myBox.add(newLog);
    logsNotifier.value = [...logsNotifier.value, newLog];

    // ACTION 2: Kirim ke MongoDB Atlas (Background)
    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog(
        "SUCCESS: Data tersinkron ke Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Data tersimpan lokal, akan sinkron saat online",
        level: 1,
      );
    }
  }

  // 2. Memperbarui data di Cloud (HOTS: Sinkronisasi Terjamin)
  Future<void> updateLog(
    int index,
    String newTitle,
    String newDesc,
    String newCategory,
  ) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id, // ID harus tetap sama agar MongoDB mengenali dokumen ini
      title: newTitle,
      category: newCategory,
      description: newDesc,
      date: DateTime.now(),
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
    );

    currentLogs[index] = updatedLog;
    logsNotifier.value = currentLogs;

    await _myBox.putAt(index, updatedLog);

    try {
      await MongoService().updateLog(updatedLog);
      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR/WARNING: Gagal sinkronisasi Update Cloud - Data aman di lokal",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  // 3. Menghapus data dari Cloud (HOTS: Sinkronisasi Terjamin)
  Future<void> removeLog(int index, String userRole, String userId) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    // 1. GATEKEEPER CHECK (Cegah pembobolan)
    if (!AccessControlService.canPerform(
      userRole,
      'delete',
      isOwner: targetLog.authorId == userId,
    )) {
      await LogHelper.writeLog(
        "SECURITY BREACH: Unauthorized delete attempt",
        level: 1,
      );
      return; // Langsung hentikan proses jika tidak punya izin
    }

    // 2. ACTION 1: Hapus dari lokal (Instan di layar)
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    await _myBox.deleteAt(index);

    // 3. ACTION 2: Hapus dari Cloud (Background)
    try {
      if (targetLog.id != null) {
        // Konversi String ke ObjectId sebelum dikirim ke MongoService
        final objectId = ObjectId.fromHexString(targetLog.id!);
        await MongoService().deleteLog(
          objectId,
        ); // Sesuaikan jika MongoService kamu butuh String

        await LogHelper.writeLog(
          "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
          source: "log_controller.dart",
          level: 2,
        );
      }
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus di Cloud - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  void searchLog(String logTitle) {
    if (logTitle.isEmpty) {
      // Jika kosong, kembalikan seluruh data dari Hive
      logsNotifier.value = _myBox.values.toList();
      return;
    }

    // Filter dari data lokal yang ada di box
    final searchResults = _myBox.values
        .where(
          (log) => log.title.toLowerCase().contains(logTitle.toLowerCase()),
        )
        .toList();
    logsNotifier.value = searchResults;
  }

  // --- BARU: FUNGSI PERSISTENCE (SINKRONISASI JSON) ---

  // // Fungsi untuk menyimpan seluruh List ke penyimpanan lokal
  // Future<void> saveToDisk() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // Mengubah List of Object -> List of Map -> String JSON
  //   final String encodedData = jsonEncode(
  //     _cachedLogs.map((log) => log.toMap()).toList(),
  //   );
  //   await prefs.setString(_storageKey, encodedData);
  // }

  // // Ganti pemanggilan SharedPreferences menjadi MongoService
  // Future<void> loadFromDisk() async {
  //   // Mengambil dari Cloud, bukan lokal
  //   final cloudData = await MongoService().getLogs();
  //   _cachedLogs = cloudData;
  // }
}