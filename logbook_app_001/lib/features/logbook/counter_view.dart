import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  final stepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadLastValue().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LogBook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Konfirmasi Logout"),
                    content: Text(
                      "Apakah anda yakin? Data yang belum disimpan mungkin akan hilang.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginView(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Ya, keluar",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text(
              "Selamat Datang, ${widget.username}!",
              style: TextStyle(fontSize: 30),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Text(
                      "Total Hitungan: ",
                      style: TextStyle(fontSize: 25),
                    ),
                    Text(
                      '${_controller.value}',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ],
                ),
              ),
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
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Log History Perubahan", style: TextStyle(fontSize: 20)),
                  IconButton(
                    onPressed: () => setState(() {
                      _controller.logs.clear();
                    }),
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: (_controller.logs.length < 5)
                    ? _controller.logs.length
                    : 5,
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
                    onPressed: () => setState(() {
                      _controller.stepDecrement();
                      _controller.saveLastValue(
                        _controller.value,
                        _controller.logs,
                      );
                    }),
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
                          onPressed: () => setState(() {
                            _controller.stepReset();
                            _controller.saveLastValue(
                              _controller.value,
                              _controller.logs,
                            );
                          }),
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
                      setState(() {
                        _controller.stepIncrement();
                        _controller.saveLastValue(
                          _controller.value,
                          _controller.logs,
                        );
                      });
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
    );
  }
}
