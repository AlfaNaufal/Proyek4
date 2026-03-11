import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'features/models/log_model.dart';
import 'log_controller.dart';
import 'features/auth/login_view.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/features/logbook/log_editor_page.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'package:logbook_app_001/services/access_control_service.dart';

class LogView extends StatefulWidget {
  final dynamic currentUser;
  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late LogController _controller;

  late Future<List<LogModel>> _logFuture;

  final TextEditingController _titleColntroller = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<String> _categories = ["Penting", "Pribadi", "Pekerjaan", "umum"];
  String _selectedCategory = "umum";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = LogController();

    _controller.loadLogs(widget.currentUser['teamId']);
  }

  // Navigasi ke Halaman Editor (Gantikan Dialog Lama)
  void _goToEditor({LogModel? log, int? index}) {
    print("Tombol ditekan");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          index: index,
          controller: _controller,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  // Future<void> _initDatabase() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     await LogHelper.writeLog(
  //       "UI: Memulai inisialisasi database...",
  //       source: "log_view.dart",
  //     );

  //     // Mencoba koneksi ke MongoDB Atlas (Cloud)
  //     await LogHelper.writeLog(
  //       "UI: Menghubungi MongoService.connect()...",
  //       source: "log_view.dart",
  //     );

  //     // Mengaktifkan kembali koneksi dengan timeout 15 detik (lebih longgar untuk sinyal HP)
  //     await MongoService().connect().timeout(
  //       const Duration(seconds: 15),
  //       onTimeout: () => throw Exception(
  //         "Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.",
  //       ),
  //     );

  //     await LogHelper.writeLog(
  //       "UI: Koneksi MongoService BERHASIL.",
  //       source: "log_view.dart",
  //     );

  //     // Mengambil data log dari Cloud
  //     await LogHelper.writeLog(
  //       "UI: Memanggil controller.loadFromDisk()...",
  //       source: "log_view.dart",
  //     );

  //     await _controller.loadFromDisk();

  //     await LogHelper.writeLog(
  //       "UI: Data berhasil dimuat ke Notifier.",
  //       source: "log_view.dart",
  //     );
  //   } catch (e) {
  //     await LogHelper.writeLog(
  //       "UI: Error - $e",
  //       source: "log_view.dart",
  //       level: 1,
  //     );
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Masalah: $e"), backgroundColor: Colors.red),
  //       );
  //     }
  //   } finally {
  //     // 2. INILAH FINALLY: Apapun yang terjadi (Sukses/Gagal/Data Kosong), loading harus mati
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  // void _showAddLogDialog() {
  //   _selectedCategory = "umum";
  //   print("masuk");

  //   showDialog(
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setDialogState) => AlertDialog(
  //         title: const Text("Tambah Catatan Baru"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: _titleColntroller,
  //               decoration: const InputDecoration(hintText: "Judul Catatan"),
  //             ),
  //             TextField(
  //               controller: _contentController,
  //               decoration: const InputDecoration(hintText: "Isi Deskripsi"),
  //             ),
  //             DropdownButtonFormField<String>(
  //               initialValue: _selectedCategory,
  //               decoration: const InputDecoration(labelText: "Kategori"),
  //               items: _categories.map((String category) {
  //                 return DropdownMenuItem<String>(
  //                   value: category,
  //                   child: Text(category),
  //                 );
  //               }).toList(),
  //               onChanged: (String? newValue) {
  //                 setDialogState(() {
  //                   _selectedCategory = newValue!;
  //                 });
  //               },
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Batal"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               await _controller.addLog(
  //                 _titleColntroller.text,
  //                 _contentController.text,
  //                 _selectedCategory,
  //               );

  //               _refreshData();

  //               _titleColntroller.clear();
  //               _contentController.clear();
  //               Navigator.pop(context);
  //             },
  //             child: const Text("Simpan"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showEditLogDialog(int index, LogModel log) {
  //   _titleColntroller.text = log.title;
  //   _contentController.text = log.description;

  //   _selectedCategory = _categories.contains(log.category)
  //       ? log.category
  //       : 'umum';

  //   showDialog(
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setDialogState) => AlertDialog(
  //         title: const Text("Edit Catatan"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(controller: _titleColntroller),
  //             TextField(controller: _contentController),
  //             DropdownButtonFormField<String>(
  //               initialValue: _selectedCategory,
  //               decoration: const InputDecoration(labelText: "Kategori"),
  //               items: _categories.map((String category) {
  //                 return DropdownMenuItem<String>(
  //                   value: category,
  //                   child: Text(category),
  //                 );
  //               }).toList(),
  //               onChanged: (String? newValue) {
  //                 setDialogState(() {
  //                   _selectedCategory = newValue!;
  //                 });
  //               },
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Batal"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               await _controller.updateLog(
  //                 index,
  //                 _titleColntroller.text,
  //                 _contentController.text,
  //                 _selectedCategory,
  //               );

  //               _refreshData();

  //               _titleColntroller.clear();
  //               _contentController.clear();
  //               Navigator.pop(context);
  //             },
  //             child: const Text("Update"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LogBook : ${widget.currentUser['username']}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadLogs(widget.currentUser['teamId']),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Konfirmasi Logout"),
                    content: Text("Apakah anda yakin akan keluar?"),
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
          // Expanded(
          //   child: ValueListenableBuilder<List<LogModel>>(
          //     valueListenable: _controller.logsNotifier,
          //     builder: (context, currentLogs, child) {
          //       // if (currentLogs.isEmpty) {
          //       //   return const Center(
          //       //     child: Column(
          //       //       mainAxisAlignment: MainAxisAlignment.center,
          //       //       children: [
          //       //         CircularProgressIndicator(),
          //       //         Text("Menghubungkan ke MongoDB Atlas...."),
          //       //       ],
          //       //     ),
          //       //   );
          //       // }
          //       // if (snapshot.hasError) {
          //       //   return Center(
          //       //     child: Column(
          //       //       mainAxisAlignment: MainAxisAlignment.center,
          //       //       children: [
          //       //         Icon(Icons.signal_wifi_off_outlined, size: 100),
          //       //         Text(
          //       //           "Error:\n${snapshot.error}",
          //       //           textAlign: TextAlign.center,
          //       //         ),
          //       //       ],
          //       //     ),
          //       //   );
          //       // }
          //       // if (currentLogs.isEmpty) {
          //       //   final currentLogs = snapshot.data!;

          //       if (currentLogs.isEmpty) {
          //         return const Center(
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Icon(
          //                 Icons.note_alt_outlined,
          //                 size: 100,
          //                 color: Colors.grey,
          //               ),
          //               Text("Belum ada catatan."),
          //             ],
          //           ),
          //         );
          //       }
          //       return RefreshIndicator(
          //         onRefresh: () {
          //           return Future.delayed(Duration(seconds: 1), () {
          //             ScaffoldMessenger.of(context).showSnackBar(
          //               SnackBar(content: const Text('Page Refreshed')),
          //             );
          //           });
          //         },
          //         child: ListView.builder(
          //           itemCount: currentLogs.length,
          //           itemBuilder: (context, index) {
          //             final log = currentLogs[index];
          //             final bool isOwner =
          //                 log.authorId == widget.currentUser['uid'];
          //             Color textColor = Colors.white;

          //             if (log.category == "Penting") {
          //               textColor = Colors.red;
          //             } else if (log.category == "Pribadi") {
          //               textColor = Colors.blue;
          //             } else if (log.category == "Pekerjaan") {
          //               textColor = Colors.orange;
          //             }

          //             return Dismissible(
          //               key: Key(log.date.toString()),
          //               direction: DismissDirection.endToStart,
          //               background: Container(
          //                 color: Colors.red,
          //                 alignment: Alignment.centerRight,
          //                 padding: const EdgeInsets.only(right: 20),
          //                 child: const Icon(Icons.delete, color: Colors.white),
          //               ),
          //               onDismissed: (direction) async {
          //                 await _controller.removeLog(
          //                   index,
          //                   widget.currentUser['role'],
          //                   widget.currentUser['uid'],
          //                 );
          //                 ScaffoldMessenger.of(context).showSnackBar(
          //                   const SnackBar(content: Text("Catatan dihapus")),
          //                 );
          //               },
          //               child: Card(
          //                 color: textColor,
          //                 child: ListTile(
          //                   leading: const Icon(Icons.note),
          //                   title: Text(
          //                     log.title,
          //                     style: TextStyle(fontSize: 30),
          //                   ),
          //                   subtitle: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Text(log.category),
          //                       Text(
          //                         log.description,
          //                         style: TextStyle(fontSize: 20),
          //                       ),
          //                     ],
          //                   ),
          //                   trailing: Row(
          //                     children: [
          //                       if (AccessControlService.canPerform(
          //                         widget.currentUser['role'],
          //                         AccessControlService.actionUpdate,
          //                         isOwner: isOwner,
          //                       ))
          //                         IconButton(
          //                           icon: const Icon(
          //                             Icons.edit,
          //                             color: Colors.blue,
          //                           ),
          //                           onPressed: () =>
          //                               _goToEditor(log: log, index: index),
          //                         ),

          //                       // GATEKEEPER: Tombol Delete hanya muncul kalau diizinkan
          //                       if (AccessControlService.canPerform(
          //                         widget.currentUser['role'],
          //                         AccessControlService.actionDelete,
          //                         isOwner: isOwner,
          //                       ))
          //                         IconButton(
          //                           icon: const Icon(
          //                             Icons.delete,
          //                             color: Colors.red,
          //                           ),
          //                           onPressed: () => _controller.removeLog(
          //                             index,
          //                             widget.currentUser['role'],
          //                             widget.currentUser['uid'],
          //                           ),
          //                         ),
          //                     ],
          //                   ),
          //                   // IconButton(
          //                   //   icon: const Icon(Icons.edit),
          //                   //   onPressed: () => _goToEditor(),
          //                   // ),
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //       );
          //       // }
          //       // return const SizedBox();
          //     },
          //   ),
          // ),
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, currentLogs, child) {
                // Debugging: Melihat jumlah data sebenarnya di terminal
                print("JUMLAH DATA SAAT INI DI HIVE: ${currentLogs.length}");

                if (currentLogs.isEmpty) {
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
                }

                return RefreshIndicator(
                  onRefresh: () {
                    return Future.delayed(const Duration(seconds: 1), () {
                      _controller.loadLogs(widget.currentUser['teamId'] ?? 'no_team');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Halaman diperbarui')),
                      );
                    });
                  },
                  child: ListView.builder(
                    itemCount: currentLogs.length,
                    itemBuilder: (context, index) {
                      final log = currentLogs[index];
                      final bool isOwner = log.authorId == widget.currentUser['uid'];
                      
                      // Fallback warna lembut agar teks hitam tetap terbaca
                      Color cardColor = Colors.white;
                      if (log.category == "Penting") {
                        cardColor = Colors.red.shade100;
                      } else if (log.category == "Pribadi") {
                        cardColor = Colors.blue.shade100;
                      } else if (log.category == "Pekerjaan") {
                        cardColor = Colors.orange.shade100;
                      }

                      return Dismissible(
                        key: Key(log.id?.toString() ?? index.toString()), // Lebih aman dari log.date
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) async {
                          await _controller.removeLog(
                            index, 
                            widget.currentUser['role'], 
                            widget.currentUser['uid'],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Catatan dihapus")),
                          );
                        },
                        child: Card(
                          elevation: 4, // PENTING: Memberi bayangan agar kartu putih tidak menghilang
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          color: cardColor,
                          child: ListTile(
                            leading: const Icon(Icons.note, size: 30),
                            title: Text(
                              log.title.isNotEmpty ? log.title : "Tanpa Judul",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min, // PENTING: Mencegah layar blank (Unbounded Height)
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(log.category, style: const TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  log.description.isNotEmpty ? log.description : "Tidak ada deskripsi",
                                  maxLines: 2, // PENTING: Mencegah teks terlalu panjang
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min, // PENTING: Mencegah error layout Row
                              children: [
                                if (AccessControlService.canPerform(
                                  widget.currentUser['role'],
                                  AccessControlService.actionUpdate,
                                  isOwner: isOwner,
                                ))
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _goToEditor(log: log, index: index),
                                  ),

                                if (AccessControlService.canPerform(
                                  widget.currentUser['role'],
                                  AccessControlService.actionDelete,
                                  isOwner: isOwner,
                                ))
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _controller.removeLog(
                                      index, 
                                      widget.currentUser['role'], 
                                      widget.currentUser['uid'],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
