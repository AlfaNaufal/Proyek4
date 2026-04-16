// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:logbook_app_001/features/logbook/counter_controller.dart';

// void main() {
//   // Menjamin inisialisasi binding untuk akses SharedPreferences di lingkungan test
//   TestWidgetsFlutterBinding.ensureInitialized();

//   group('Module 1 - CounterController (Excel Based Test)', () {
//     late CounterController controller;
//     const String username = 'admin'; // Sesuai data pada Excel TC01-TC03

//     setUp(() async {
//       // Setup (Arrange, Build)
//       // Menginisialisasi mock storage agar SharedPreferences.getInstance() tidak error
//       SharedPreferences.setMockInitialValues({}); 
//       controller = CounterController();
      
//       // Load initial value sesuai langkah pengujian di Excel
//       await controller.loadLastValue(); 
//     });

//     // TC01: loadLastValue (initial value should be 0)
//     test('initial value should be 0', () {
//       // Act
//       final actual = controller.value;
      
//       // Assert
//       expect(actual, 0, reason: 'Ekspektasi: nilai counter sekarang nol');
//     });

//     // TC02: setStep (Positif - change step value)
//     test('setStep should change step value', () {
//       // Act
//       controller.setStep(5); // Data Test: NewStep = 5
//       final actual = controller.step;
      
//       // Assert
//       expect(actual, 5, reason: 'Ekspektasi: nilai step sekarang 5');
//     });

//     // TC03: setStep (Negatif - ignore negative value)
//     test('setStep should ignore negative value', () {
//       // Arrange
//       controller.setStep(3); // Step sebelumnya = 3
      
//       // Act
//       controller.setStep(-1); // Data Test: NewStep = -1
//       final actual = controller.step;
      
//       // Assert
//       expect(actual, 3, reason: 'Ekspektasi: nilai step tidak berubah (tetap 3)');
//     });

//     // Implementasi tambahan berdasarkan fungsi terbaru di Controller Anda
//     test('stepIncrement should increase counter value by step', () {
//       controller.setStep(2);
//       controller.stepIncrement(username); 
//       expect(controller.value, 2);
//     });

//     test('stepDecrement should decrease counter but not go below zero', () {
//       controller.setStep(5);
//       controller.stepIncrement(username); // value = 5
      
//       controller.stepDecrement(username); 
//       expect(controller.value, 0);
//     });

//     test('stepReset should set counter to 1', () {
//       controller.stepIncrement(username);
//       controller.stepReset(username);
//       expect(controller.value, 1);
//     });

//     test('addLog should record action to logs history', () {
//       controller.addLog(username, "menambah nilai");
//       expect(controller.logs.length, 1);
//       expect(controller.logs.first, contains("menambah nilai"));
//     });

//     test('Persistence test (Save & Load)', () async {
//       await controller.saveLastValue(10, ["Log 1"]);
//       await controller.loadLastValue();
//       expect(controller.value, 10);
//       expect(controller.logs, contains("Log 1"));
//     });
//   });
// }

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';

void main() {
  // Menjamin inisialisasi binding untuk akses SharedPreferences di lingkungan test
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Module 1 - CounterController (Full Excel Integration)', () {
    late CounterController controller;
    const String username = 'admin';

    setUp(() async {
      // Setup (Arrange)
      SharedPreferences.setMockInitialValues({}); 
      controller = CounterController();
      await controller.loadLastValue(); 
    });

    // TC01: loadLastValue (initial value should be 0)
    test('TC01 - initial value should be 0', () {
      // Act
      final actual = controller.value;
      
      // Assert
      expect(actual, 0, reason: 'Ekspektasi: nilai counter sekarang nol');
    });

    // TC02: setStep (Positif)
    test('TC02 - setStep should change step value', () {
      // Act
      controller.setStep(5); 
      final actual = controller.step;
      
      // Assert
      expect(actual, 5, reason: 'Ekspektasi: nilai step sekarang 5');
    });

        // TC03: setStep (Negatif - ignore negative value)
    test('setStep should ignore negative value', () {
      // Arrange
      controller.setStep(3); // Step sebelumnya = 3
      
      // Act
      controller.setStep(-1); // Data Test: NewStep = -1
      final actual = controller.step;
      
      // Assert
      expect(actual, 3, reason: 'Ekspektasi: nilai step tidak berubah (tetap 3)');
    });

    // TC04: stepIncrement (Default step)
    test('TC04 - stepIncrement increase value by 1', () async {
      // Act
      await controller.stepIncrement(username);
      
      // Assert
      expect(controller.value, 1);
    });

    // TC05: stepIncrement (Custom step)
    test('TC05 - stepIncrement increase value by custom step', () async {
      // Arrange
      controller.setStep(5);
      
      // Act
      await controller.stepIncrement(username);
      
      // Assert
      expect(controller.value, 5);
    });

    // TC06: stepDecrement (Result >= 0)
    test('TC06 - stepDecrement decrease value correctly', () async {
      // Arrange
      controller.setStep(2);
      await controller.stepIncrement(username); // value jadi 2
      await controller.stepIncrement(username); // value jadi 4
      
      // Act
      await controller.stepDecrement(username);
      
      // Assert
      // Catatan: Jika ini FAIL (Actual: 2), berarti bug di controller belum diperbaiki
      expect(controller.value, 2); 
    });

    // TC07: stepDecrement (Lower limit / Boundary)
    test('TC07 - stepDecrement lower limit should be 0', () async {
      // Arrange
      controller.setStep(10);
      await controller.stepIncrement(username); // value jadi 10
      
      // Act
      controller.setStep(15);
      await controller.stepDecrement(username); // 10 - 15 = -5 -> harusnya 0
      
      // Assert
      expect(controller.value, 0);
    });

    // TC08: stepReset
    test('TC08 - stepReset reset value to 1', () async {
      // Arrange
      await controller.stepIncrement(username);
      
      // Act
      await controller.stepReset(username);
      
      // Assert
      expect(controller.value, 1);
    });

    // TC09: addLog
    test('TC09 - addLog record action to history', () {
      // Act
      controller.addLog(username, "melakukan tes");
      
      // Assert
      expect(controller.logs.length, 1);
      expect(controller.logs.first, contains("melakukan tes"));
    });

    // TC10: logs limit
    test('TC10 - logs maximum limit of 5 items', () {
      // Act
      for (int i = 0; i < 6; i++) {
        controller.addLog(username, "Log ke-$i");
      }
      
      // Assert
      expect(controller.logs.length, 5);
    });
  });
}