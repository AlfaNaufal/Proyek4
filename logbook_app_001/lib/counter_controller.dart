class CounterController {
  int _counter = 0;
  int _step = 1; //default step value

  final List<String> _logs = [];

  int get value => _counter;
  int get step => _step;

  void setStep(value) {
    _step = value;
  }

  void stepIncrement() => _counter += step;
  void stepDecrement() {
    if (_counter > 1) _counter -= step;
  }

  void stepReset() => _counter = 0;

  List<String> get logs => _logs;

  void addLog(String action) {
    final timeStamp = DateTime.now().hour.toString().padLeft(2, '0');

    _logs.insert(
      0,
      "User menambahkan nilai sebesar $step pada pukul $timeStamp",
    ); // _logs.add('$timestamp: $action to $_counter');
  }
}
