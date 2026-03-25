import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_001/features/models/log_model.dart';
import 'package:logbook_app_001/log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late List<String> _categories = ["Mechanical", "Electronic", "Software", "umum"];
  String _selectedCategory = "umum";
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(
      text: widget.log?.description ?? '',
    );
    String initialCategory = widget.log?.category ?? 'umum';
    if (!_categories.contains(initialCategory)) {
      initialCategory = 'umum';
    }
    _selectedCategory = initialCategory;
    _isPublic = widget.log?.isPublic ?? false;

    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (widget.log == null) {
      widget.controller.addLog(
        _titleController.text,
        _descController.text,
        _selectedCategory,
        widget.currentUser['uid'],
        widget.currentUser['teamId'],
        _isPublic,
      );
    } else {
      widget.controller.updateLog(
        widget.log!.id!,
        _titleController.text,
        _descController.text,
        _selectedCategory,
        _isPublic,
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau"),
            ],
          ),
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Editor
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul"),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Tulis laporan dengan format Markdown...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Kategori",
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) {
                          _selectedCategory = newValue;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text("Bagikan secara Publik"),
                    subtitle: Text(_isPublic ? "Rekan tim bisa melihat catatan ini" : "Hanya Anda yang bisa melihat catatan ini"),
                    value: _isPublic,
                    activeThumbColor: Colors.blue,
                    onChanged: (bool value) {
                      setState(() { 
                        _isPublic = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Tab 2: Markdown Preview
            Markdown(data: _descController.text),
          ],
        ),
      ),
    );
  }
}
