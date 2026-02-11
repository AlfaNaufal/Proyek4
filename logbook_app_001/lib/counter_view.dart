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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Hitungan: ", style: TextStyle(fontSize: 25)),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),
            // TextField(
            //   controller: stepController,
            //   textAlign: TextAlign.center,
            //   style: const TextStyle(fontSize: 20),
            //   keyboardType: TextInputType.number,
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     hintText: 'Masukkan nilai step',
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
                return ListTile(
                    title: Text(
                      _controller.logs[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: () => setState(() => _controller.stepDecrement()),
              child: const Icon(Icons.remove),
            ),
            FloatingActionButton(
              onPressed: () => setState(() => _controller.stepReset()),
              child: const Icon(Icons.refresh),
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() => _controller.stepIncrement());
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
