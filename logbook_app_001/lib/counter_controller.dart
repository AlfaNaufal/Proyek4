class CounterController {
  int _counter = 0;
  int _step = 1; //default step value

  final List<String> _logs = ["", "", "", "", ""];

  int get value => _counter;
  int get step => _step;

  void setStep(value) {
    _step = value;
  }

  void stepIncrement() {
    _counter += step;
    addLog("Menambah");
  }

  void stepDecrement() {
    if (_counter >= step) _counter -= step;
    addLog("Mengurangi");
  }

  void stepReset() {
     _counter = 0;
     addLog("Mereset");
     }

  List<String> get logs => _logs;

  void addLog(String action) {
    final timeStamp = DateTime.now().hour.toString().padLeft(2, '0');

    _logs.insert(
      0,
      "User $action nilai sebesar $step pada pukul $timeStamp",
    ); // _logs.add('$timestamp: $action to $_counter');
  }
}
