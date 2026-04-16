// import 'package:shared_preferences/shared_preferences.dart';

// class CounterController {
//   int _counter = 0;
//   int _step = 1; //default step value
//   List<String> _logs = [];

//   int get value => _counter;
//   int get step => _step;


//   Future<void> saveLastValue(int value, List<String> logs) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('lastCounter', value);
//     await prefs.setStringList('logs', logs);
//   }

//   Future<void> loadLastValue() async {
//     final prefs = await SharedPreferences.getInstance();
//     _counter = prefs.getInt('lastCounter') ?? 0;
//     _logs = prefs.getStringList('logs') ?? [];
//   }

//   void setStep(int value) {
//     _step = value;
//   }

//   void stepIncrement() {
//     _counter += step;
//     addLog("Menambah");
//     saveLastValue(_counter, _logs);
//   }

//   void stepDecrement() {
//     if (_counter >= step) _counter -= step;
//     addLog("Mengurangi");
//     saveLastValue(_counter, _logs);
//   }

//   void stepReset() {
//     _counter = 0;
//     addLog("Mereset");
//     saveLastValue(_counter, _logs);
//   }

//   List<String> get logs => _logs;

//   void addLog(String action) {
//     final Hour = DateTime.now().hour.toString().padLeft(2, '0');
//     final Minute = DateTime.now().minute.toString().padLeft(2, '0');
//     final Second = DateTime.now().second.toString().padLeft(2, '0');

//     _logs.insert(
//       0,
//       "User $action nilai sebesar $step pada pukul $Hour:$Minute:$Second",
//     );
//   }
// }


import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0; // Variabel private (Enkapsulasi)
  int _step = 1; // default step = 1

  List<String> _logs = []; // variable riwayat penambahan step

  int get value => _counter; // Getter untuk akses data
  int get step => _step; // Getter untuk akses nilai step
  List<String> get logs => _logs; // Getter akses data riwayat

  // load data dari counter
  Future<void> loadCounter(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt("counter_$username") ?? 0;
  }

  // simpan ke storage
  Future<void> saveCounter(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("counter_$username", _counter);
  }

    Future<void> saveLastValue(int value, List<String> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastCounter', value);
    await prefs.setStringList('logs', logs);
  }

    Future<void> loadLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('lastCounter') ?? 0;
    _logs = prefs.getStringList('logs') ?? [];
  }


  // Atur nilai step
  void setStep(int value) {
    if (value > 0) {
      _step = value;
    }
  }

  // add history counter
  void addLog(String username, String message) {
    DateTime now = DateTime.now();
    String time =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    _logs.insert(0, "User $username $message pada jam $time");

    if (_logs.length > 5) {
      _logs.removeLast();
    }
  }

  //void increment() => _counter++;
  // Increment menggunakan step
  Future<void> stepIncrement(String username) async {
    _counter += _step;
    addLog(username, "menambah nilai sebesar $_step");

    await saveCounter(username); // simpan counter ke data lokal
  }

  // Decrement menggunakan step
  Future<void> stepDecrement(String username) async {
    if (_counter - _step >= 0) {
      _counter = _step;
    } else {
      _counter = 0;
    }
    addLog(username, "mengurangi nilai sebesar $_step");

    await saveCounter(username); // simpan counter ke data lokal
  }

  Future<void> stepReset(String username) async {
    _counter = 1;
    addLog(username, "mereset counter");

    await saveCounter(username); // simpan counter ke data lokal
  }
}
