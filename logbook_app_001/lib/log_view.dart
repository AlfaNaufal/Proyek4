import 'package:flutter/material.dart';
import 'features/models/log_model.dart';
import 'log_controller.dart';
import 'features/auth/login_view.dart';
import 'package:logbook_app_001/features/logbook/log_editor_page.dart';
import 'package:logbook_app_001/services/access_control_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogView extends StatefulWidget {
  final dynamic currentUser;
  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}
class _LogViewState extends State<LogView> {
  late LogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LogController();

    _controller.loadLogs(widget.currentUser['teamId']);
  }

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
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, currentLogs, child) {

                final displayLogs = currentLogs.where((log) {
                  return log.authorId == widget.currentUser['uid'] || log.isPublic == true;
                }).toList();

                if (displayLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'lib/assets/Empty.svg',
                          width: 200,
                          height: 200,
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
                    itemCount: displayLogs.length,
                    itemBuilder: (context, index) {
                      final log = displayLogs[index];
                      final bool isOwner = log.authorId == widget.currentUser['uid'];
                      
                      // Fallback warna lembut agar teks hitam tetap terbaca
                      Color cardColor = Colors.white;
                      if (log.category == "Mechanical") {
                        cardColor = Colors.orange.shade100;
                      } else if (log.category == "Electronic") {
                        cardColor = Colors.red.shade100;
                      } else if (log.category == "Software") {
                        cardColor = Colors.blue.shade100;
                      }

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        color: cardColor,
                        child: ListTile(
                          leading: const Icon(Icons.note, size: 30),
                          title: Text(
                            log.title.isNotEmpty ? log.title : "Tanpa Judul",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                      
                              Tooltip(
                                message: log.isSynced ? "Tersinkronisasi" : "Menunggu Sinyal...",
                                child: Icon(
                                  log.isSynced ? Icons.cloud_done : Icons.cloud_off,
                                  color: log.isSynced ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                      
                              if (AccessControlService.canPerform(
                                widget.currentUser['role'],
                                AccessControlService.actionUpdate,
                                isOwner: isOwner,
                              ))
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _goToEditor(log: log),
                                ),
                      
                              if (AccessControlService.canPerform(
                                widget.currentUser['role'],
                                AccessControlService.actionDelete,
                                isOwner: isOwner,
                              ))
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _controller.removeLog(
                                    log.id!, 
                                    widget.currentUser['role'], 
                                    widget.currentUser['uid'],
                                  ),
                                ),
                            ],
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
