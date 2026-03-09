import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class HiveScreen extends StatefulWidget {
  final Color color;
  const HiveScreen({super.key, required this.color});

  @override
  State<HiveScreen> createState() => _HiveScreenState();
}

class _HiveScreenState extends State<HiveScreen> {
  final _taskController = TextEditingController();
  late Box<Task> _taskBox;

  @override
  void initState() {
    super.initState();
    _taskBox = Hive.box<Task>('tasks');
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _taskController.text,
        createdAt: DateTime.now(),
      );
      _taskBox.add(task);
      _taskController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task added!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _toggleTask(int index) {
    final task = _taskBox.getAt(index);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
    }
  }

  void _deleteTask(int index) {
    _taskBox.deleteAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarColor = widget.color ?? theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Tasks'),
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
                  'NoSQL Database',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fast, lightweight NoSQL storage for objects and lists.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        decoration: InputDecoration(
                          hintText: 'What needs to be done?',
                          prefixIcon: Icon(Icons.add_task_rounded, color: appBarColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 54,
                      width: 54,
                      child: IconButton.filled(
                        onPressed: _addTask,
                        style: IconButton.styleFrom(
                          backgroundColor: appBarColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 28),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _taskBox.listenable(),
              builder: (context, Box<Task> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_rounded, size: 64, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: box.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = box.getAt(index);
                    if (task == null) return const SizedBox();

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        onTap: () => _toggleTask(index),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: appBarColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: appBarColor,
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? theme.textTheme.bodyLarge?.color?.withOpacity(0.5) : null,
                          ),
                        ),
                        subtitle: Text(
                          'Added ${task.createdAt.toString().split('.')[0]}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => _deleteTask(index),
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
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
