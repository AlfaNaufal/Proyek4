import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  final stepController = TextEditingController();

  @override
  void dispose() {
    stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook: Versi SRP"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80,),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16), 
                  child: Column(
                    children: [
                      const Text("Total Hitungan: ", style: TextStyle(fontSize: 25)),
                      Text('${_controller.value}', style: const TextStyle(fontSize: 40)),
        
                    ]
                  )),
              ),
              // TextField(
              //   controller: stepController,
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(fontSize: 20),
              //   keyboardType: TextInputType.number,
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //     hintText: 'Masukkan nilai step (Max 100)',
              //   ),
              //   onChanged: (value) => setState(() {
              //     final stepValue = int.tryParse(value);
              //     if (stepValue != null && stepValue > 0) {
              //       _controller.setStep(stepValue);
              //     }
              //   }),
              // ),
              Slider(
                value: _controller.step.toDouble(),
                max: 100,
                onChanged: (double value) {
                  setState(() {
                    _controller.setStep(value.toInt());
                  });
                },
              ),
              Text("Nilai Step: ", style: TextStyle(fontSize: 20)),
              Text('${_controller.step}', style: const TextStyle(fontSize: 40)),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    Color textColor = Colors.black;
        
                    if (_controller.logs[index].contains("Menambah")) {
                      textColor = Colors.green;
                    } else if (_controller.logs[index].contains("Mengurangi")) {
                      textColor = Colors.red;
                    } else if (_controller.logs[index].contains("Mereset")) {
                      textColor = Colors.blue;
                    }
        
                    return ListTile(
                      title: Text(
                        _controller.logs[index],
                        style: TextStyle(fontSize: 14, color: textColor),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () => setState(() => _controller.stepDecrement()),
                      child: Icon(Icons.remove),
                      backgroundColor: Colors.red,
                    ),
                    SizedBox(width: 30),
                    FloatingActionButton(
                      onPressed: () {
                        final snackBar = SnackBar(
                          content: Text('Counter Akan direset ke 0'),
                          duration: Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'Reset',
                            onPressed: () => setState(() => _controller.stepReset()),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      child: Icon(Icons.refresh),
                      backgroundColor: Colors.blue,
                    ),
                    SizedBox(width: 30),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() => _controller.stepIncrement());
                      },
                      child: Icon(Icons.add),
                      backgroundColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}
