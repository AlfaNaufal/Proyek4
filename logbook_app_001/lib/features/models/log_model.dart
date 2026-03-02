import 'package:mongo_dart/mongo_dart.dart';


class LogModel { 

  final ObjectId? id;
  final String title; 
  final DateTime date; 
  final String category;
  final String description; 

  LogModel({
    this.id, 
    required this.title, 
    required this.category, 
    required this.description, 
    required this.date,
  });

    // [CONVERT] Memasukkan data ke "Kardus" (BSON/Map) untuk dikirim ke Cloud
  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(), // Buat ID otomatis jika belum ada
      'title': title,
      'description': category,
      'description': description,
      'date': date.toIso8601String(), // Simpan tanggal dalam format standar
    };
  }

  // [REVERT] Membongkar "Kardus" (BSON/Map) kembali menjadi objek Flutter
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
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