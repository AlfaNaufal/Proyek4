import 'dart:convert';
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

  late final Box<LogModel> _myBox;

  LogController() {
    _myBox = Hive.box<LogModel>('offline_logs');
  }

  Future<void> loadLogs(String teamId) async {
    logsNotifier.value = _myBox.values.toList();

    try {
      final unsyncedLogs = _myBox.values.where((log) => log.isSynced == false).toList();
      
      for (var log in unsyncedLogs) {
        try {
          try {
            await MongoService().insertLog(log);
          } catch (e) {
            await MongoService().updateLog(log);
          }
          
          log.isSynced = true;
          final index = _myBox.values.toList().indexWhere((l) => l.id == log.id);
          if (index != -1) {
            await _myBox.putAt(index, log);
          }
        } catch (e) {
          print("Push tertunda untuk: ${log.title}");
        }
      }

      final cloudData = await MongoService().getLogs(teamId);

      final remainingUnsynced = _myBox.values.where((log) => log.isSynced == false).toList();

      await _myBox.clear();
      await _myBox.addAll(cloudData);

      if (remainingUnsynced.isNotEmpty) {
        await _myBox.addAll(remainingUnsynced);
      }

      logsNotifier.value = _myBox.values.toList();
      await LogHelper.writeLog("SYNC: Data berhasil diperbarui dari Atlas", level: 2);
    } catch (e) {
      await LogHelper.writeLog("OFFLINE: Menggunakan data cache lokal", level: 2);
    }
  }

  Future<void> addLog(
    String title,
    String desc,
    String category,
    String authorId,
    String teamId,
    bool isPublic,
  ) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      category: category,
      date: DateTime.now(),
      authorId: authorId,
      teamId: teamId,
      isSynced: false,
      isPublic: isPublic,
    );

    await _myBox.add(newLog);
    logsNotifier.value = _myBox.values.toList();

    try {
      await MongoService().insertLog(newLog);

      newLog.isSynced = true;

      final index = _myBox.values.toList().indexWhere((log) => log.id == newLog.id);
      if (index != -1) {
        await _myBox.putAt(index, newLog);
        logsNotifier.value = _myBox.values.toList();
      }

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

  Future<void> updateLog(
    String logId,
    String newTitle,
    String newDesc,
    String newCategory,
    bool isPublic
  ) async {
    final logsInBox = _myBox.values.toList();
    final boxIndex = logsInBox.indexWhere((log) => log.id == logId);

    if (boxIndex == -1) return;

    final oldLog = logsInBox[boxIndex];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: newTitle,
      category: newCategory,
      description: newDesc,
      date: DateTime.now(),
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      isSynced: false,
      isPublic: isPublic,
    );

    await _myBox.putAt(boxIndex, updatedLog);
    logsNotifier.value = _myBox.values.toList();


    try {
      if (oldLog.isSynced == false) {
        await MongoService().insertLog(updatedLog);
      } else {
        await MongoService().updateLog(updatedLog);
      }
      
      updatedLog.isSynced = true;

      await _myBox.putAt(boxIndex, updatedLog);
      logsNotifier.value = _myBox.values.toList();

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

  Future<void> removeLog(String logId, String userRole, String userId) async {
    final logsInBox = _myBox.values.toList();
    final boxIndex = logsInBox.indexWhere((log) => log.id == logId);

    if (boxIndex == -1) return;

    final targetLog = logsInBox[boxIndex];

    if (!AccessControlService.canPerform(
      userRole,
      'delete',
      isOwner: targetLog.authorId == userId,
    )) {
      await LogHelper.writeLog(
        "SECURITY BREACH: Unauthorized delete attempt",
        level: 1,
      );
      return;
    }

      await _myBox.deleteAt(boxIndex);
      logsNotifier.value = _myBox.values.toList();

    try {
      if (targetLog.id != null) {
        final objectId = ObjectId.fromHexString(targetLog.id!);
        await MongoService().deleteLog(
          objectId,
        );

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
      logsNotifier.value = _myBox.values.toList();
      return;
    }

    final searchResults = _myBox.values
        .where(
          (log) => log.title.toLowerCase().contains(logTitle.toLowerCase()),
        )
        .toList();
    logsNotifier.value = searchResults;
  }
}