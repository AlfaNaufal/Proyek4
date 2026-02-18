import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1; //default step value
  List<String> _logs = [];

  int get value => _counter;
  int get step => _step;


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

  void setStep(int value) {
    _step = value;
  }

  void stepIncrement() {
    _counter += step;
    addLog("Menambah");
    saveLastValue(_counter, _logs);
  }

  void stepDecrement() {
    if (_counter >= step) _counter -= step;
    addLog("Mengurangi");
    saveLastValue(_counter, _logs);
  }

  void stepReset() {
    _counter = 0;
    addLog("Mereset");
    saveLastValue(_counter, _logs);
  }

  List<String> get logs => _logs;

  void addLog(String action) {
    final Hour = DateTime.now().hour.toString().padLeft(2, '0');
    final Minute = DateTime.now().minute.toString().padLeft(2, '0');
    final Second = DateTime.now().second.toString().padLeft(2, '0');

    _logs.insert(
      0,
      "User $action nilai sebesar $step pada pukul $Hour:$Minute:$Second",
    );
  }
}
