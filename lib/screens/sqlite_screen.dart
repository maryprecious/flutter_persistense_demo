import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class SQLiteScreen extends StatefulWidget {
  final Color color;
  const SQLiteScreen({super.key, required this.color});

  @override
  State<SQLiteScreen> createState() => _SQLiteScreenState();
}

class _SQLiteScreenState extends State<SQLiteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final data = await _dbHelper.getAllNotes();
    setState(() {
      _notes = data;
    });
  }

  Future<void> _addNote() async {
    if (_titleController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      await _dbHelper.createNote({
        'title': _titleController.text,
        'content': _contentController.text,
        'created_at': DateTime.now().toIso8601String(),
      });
      _titleController.clear();
      _contentController.clear();
      _refreshNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note added!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarColor = widget.color ?? theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Notes'),
        backgroundColor: widget.color,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relational Schema',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'SQLite provides a robust relational database for structured data storage on device.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Note Title',
                    prefixIcon: Icon(Icons.title_rounded, color: appBarColor),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Note Content',
                    prefixIcon: Icon(Icons.notes_rounded, color: appBarColor),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _addNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBarColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 24),
                    label: const Text('Add Note', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_document, size: 64, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        Text(
                          'No notes found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      final isCompleted = note['is_completed'] == 1;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                        ),
                        child: ListTile(
                          onTap: () async {
                            await _dbHelper.updateNote(note['id'], {
                              'is_completed': isCompleted ? 0 : 1,
                            });
                            _refreshNotes();
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: appBarColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isCompleted ? Icons.check_circle_rounded : Icons.note_rounded,
                              color: appBarColor,
                            ),
                          ),
                          title: Text(
                            note['title'] ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? theme.textTheme.bodyLarge?.color?.withOpacity(0.5) : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note['content'] ?? '',
                                style: TextStyle(
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateTime.parse(note['created_at']).toString().split('.')[0],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () async {
                              await _dbHelper.deleteNote(note['id']);
                              _refreshNotes();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
