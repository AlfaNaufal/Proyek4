import 'package:mongo_dart/mongo_dart.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel { 

  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title; 
  
  @HiveField(2)
  final DateTime date; 

  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final String description; 

  @HiveField(5)
  final String authorId; // BARU

  @HiveField(6)
  final String teamId; // BARU


  LogModel({
    this.id, 
    required this.title, 
    required this.category, 
    required this.description, 
    required this.date,
    required this.authorId,
    required this.teamId,

  });

    // [CONVERT] Memasukkan data ke "Kardus" (BSON/Map) untuk dikirim ke Cloud
  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(), // Buat ID otomatis jika belum ada
      'title': title,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'authorId': authorId,
      'teamId': teamId,
    };
  }

  // [REVERT] Membongkar "Kardus" (BSON/Map) kembali menjadi objek Flutter
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: (map['_id'] as ObjectId?)?.oid,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      authorId: map['authorId'] ?? 'unknown_user', // Cegah error null
      teamId: map['teamId'] ?? 'no_team',

    );
  }

  // LogModel({ 

  //   required this.title,
  //   required this.date, 
  //   required this.category, 
  //   required this.description, 

  // }); 

 

  // // Untuk Tugas HOTS: Konversi Map (JSON) ke Object 
  // factory LogModel.fromMap(Map<String, dynamic> map) { 

  //   return LogModel( 

  //     title: map['title'], 
  //     date: map['date'],
  //     category: map['category'],
  //     description: map['description'], 
  //   ); 
  // } 

 

  // // Konversi Object ke Map (JSON) untuk disimpan 
  // Map<String, dynamic> toMap() { 

  //   return { 

  //     'title': title, 
  //     'date': date, 
  //     'category': category,
  //     'description': description, 
  //   };

  // } 

} 