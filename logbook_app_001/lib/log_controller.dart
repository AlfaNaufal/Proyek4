// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'features/models/log_model.dart';

// class LogController {
//   final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
//   static const String _storageKey = 'user_logs_data';

//   LogController() {
//     loadFromDisk();
//   }

//   void addLog(String title, String desc, String category) {
//     final newLog = LogModel(
//       title: title,
//       description: desc,
//       category: category,
//       date: DateTime.now(),
//     );
//     logsNotifier.value = [...logsNotifier.value, newLog];

//     saveToDisk();
//   }

//   void updateLog(int index, String title, String desc, String category) {
//     final currentLogs = List<LogModel>.from(logsNotifier.value);
//     currentLogs[index] = LogModel(
//       title: title,
//       description: desc,
//       category: category,
//       date: DateTime.now(),
//     );
//     logsNotifier.value = currentLogs;

//     saveToDisk();
//   }

//   void removeLog(int index) {
//     final currentLogs = List<LogModel>.from(logsNotifier.value);
//     currentLogs.removeAt(index);
//     logsNotifier.value = currentLogs;

//     saveToDisk();
//   }

//   void searchLog(String logTitle) {
//     final currentLogs = List<LogModel>.from(logsNotifier.value);
//     final searchResults = currentLogs.where((log) => log.title.toLowerCase().contains(logTitle.toLowerCase())).toList();
//     logsNotifier.value = searchResults;
//   }

//   // List cadangan untuk hasil pencarian
//   // ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

//   // void searchLog(String query) {
//   //   if (query.isEmpty) {
//   //     filteredLogs.value = logsNotifier.value;
//   //   } else {
//   //     filteredLogs.value = logsNotifier.value
//   //         .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
//   //         .toList();
//   //   }
//   // }


//   Future<void> saveToDisk() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String encodedData = jsonEncode(
//       logsNotifier.value.map((e) => e.toMap()).toList(),
//     );

//     await prefs.setString(_storageKey, encodedData);
//   }

//   Future<void> loadFromDisk() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? data = prefs.getString(_storageKey);

//     if (data != null) {
//       final List decoded = jsonDecode(data);
//       logsNotifier.value = decoded.map((e) => LogModel.fromMap(e)).toList();
//     }
//   }
// }


import 'dart:convert'; // Wajib ditambahkan untuk jsonEncode & jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_001/features/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  // Kunci unik untuk penyimpanan lokal di Shared Preferences
  static const String _storageKey = 'user_logs_data';

  // Getter untuk mempermudah akses list data saat ini
  List<LogModel> get logs => logsNotifier.value;

  // --- BARU: KONSTRUKTOR ---
  // Saat Controller dibuat, ia otomatis mencoba mengambil data lama
  LogController() {
    loadFromDisk();
  }

  // 1. Menambah data ke Cloud
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId(),
      title: title,
      category: category,
      description: desc,
      date: DateTime.now(),
    );

    try {
      // 2. Kirim ke MongoDB Atlas
      await MongoService().insertLog(newLog);

      // 3. Update UI Lokal (Data sekarang sudah punya ID asli)
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Tambah data dengan ID lokal",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Add - $e", level: 1);
    }
  }

  // 2. Memperbarui data di Cloud (HOTS: Sinkronisasi Terjamin)
  Future<void> updateLog(int index, String newTitle, String newDesc, String newCategory) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id, // ID harus tetap sama agar MongoDB mengenali dokumen ini
      title: newTitle,
      category: newCategory,
      description: newDesc,
      date: DateTime.now(),
    );

    try {
      // 1. Jalankan update di MongoService (Tunggu konfirmasi Cloud)
      await MongoService().updateLog(updatedLog);

      // 2. Jika sukses, baru perbarui state lokal
      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Update - $e",
        source: "log_controller.dart",
        level: 1,
      );
      // Data di UI tidak berubah jika proses di Cloud gagal
    }
  }

  // 3. Menghapus data dari Cloud (HOTS: Sinkronisasi Terjamin)
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception(
          "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
        );
      }

      // 1. Hapus data di MongoDB Atlas (Tunggu konfirmasi Cloud)
      await MongoService().deleteLog(targetLog.id!);

      // 2. Jika sukses, baru hapus dari state lokal
      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

    void searchLog(String logTitle) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final searchResults = currentLogs.where((log) => log.title.toLowerCase().contains(logTitle.toLowerCase())).toList();
    logsNotifier.value = searchResults;
  }

  // --- BARU: FUNGSI PERSISTENCE (SINKRONISASI JSON) ---

  // Fungsi untuk menyimpan seluruh List ke penyimpanan lokal
  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengubah List of Object -> List of Map -> String JSON
    final String encodedData = jsonEncode(
      logsNotifier.value.map((log) => log.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  // Ganti pemanggilan SharedPreferences menjadi MongoService
  Future<void> loadFromDisk() async {
    // Mengambil dari Cloud, bukan lokal
    final cloudData = await MongoService().getLogs();
    logsNotifier.value = cloudData;
  }
}
