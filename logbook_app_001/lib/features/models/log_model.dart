class LogModel { 

  final String title; 
  final String date; 
  final String category;
  final String description; 

 

  LogModel({ 

    required this.title,
    required this.date, 
    required this.category, 
    required this.description, 

  }); 

 

  // Untuk Tugas HOTS: Konversi Map (JSON) ke Object 
  factory LogModel.fromMap(Map<String, dynamic> map) { 

    return LogModel( 

      title: map['title'], 
      date: map['date'],
      category: map['category'],
      description: map['description'], 
    ); 
  } 

 

  // Konversi Object ke Map (JSON) untuk disimpan 
  Map<String, dynamic> toMap() { 

    return { 

      'title': title, 
      'date': date, 
      'category': category,
      'description': description, 
    };

  } 

} 