import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'features/models/log_model.dart';
import 'log_controller.dart';
import 'features/auth/login_view.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleColntroller = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<String> _categories = ["Penting", "Pribadi", "Pekerjaan", "umum"];
  String _selectedCategory = "umum";

  void _showAddLogDialog() {
    _selectedCategory = "umum";
    print("masuk");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Tambah Catatan Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleColntroller,
                decoration: const InputDecoration(hintText: "Judul Catatan"),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(hintText: "Isi Deskripsi"),
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: "Kategori"),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setDialogState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.addLog(
                  _titleColntroller.text,
                  _contentController.text,
                  _selectedCategory,
                );
                setState(() {});

                _titleColntroller.clear();
                _contentController.clear();
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLogDialog(int index, LogModel log) {
    _titleColntroller.text = log.title;
    _contentController.text = log.description;

    _selectedCategory = _categories.contains(log.category)
        ? log.category
        : 'Lainnya';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Catatan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleColntroller),
              TextField(controller: _contentController),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: "Kategori"),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setDialogState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.updateLog(
                  index,
                  _titleColntroller.text,
                  _contentController.text,
                  _selectedCategory,
                );

                setState(() {});

                _titleColntroller.clear();
                _contentController.clear();
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LogBook"),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextField(
              onChanged: (Text) {
                _controller.searchLog(Text);
              },
              decoration: InputDecoration(
                hintText: "Cari catatan...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, currentLogs, child) {
                if (currentLogs.isEmpty)
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 100,
                          color: Colors.grey,
                        ),
                        Text("Belum ada catatan."),
                      ],
                    ),
                  );
                return ListView.builder(
                  itemCount: currentLogs.length,
                  itemBuilder: (context, index) {
                    final log = currentLogs[index];
                    Color textColor = Colors.white;
      
                    if (log.category == "Penting") {
                      textColor = Colors.red;
                    } else if (log.category == "Pribadi") {
                      textColor = Colors.blue;
                    } else if (log.category == "Pekerjaan") {
                      textColor = Colors.orange;
                    }

                    return Dismissible(
                      key: Key(log.date),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _controller.removeLog(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Catatan dihapus")),
                        );
                      },
                      child: Card(
                        color: textColor,
                        child: ListTile(
                          leading: const Icon(Icons.note),
                          title: Text(log.title, style: TextStyle(fontSize: 30),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.category),
                              Text(log.description, style: TextStyle(fontSize: 20),),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit,),
                            onPressed: () => _showEditLogDialog(index, log),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
