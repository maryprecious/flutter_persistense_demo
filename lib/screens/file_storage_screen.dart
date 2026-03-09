import 'package:flutter/material.dart';
import '../services/file_storage_service.dart';

class FileStorageScreen extends StatefulWidget {
  final Color color;
  const FileStorageScreen({super.key, required this.color});

  @override
  State<FileStorageScreen> createState() => _FileStorageScreenState();
}

class _FileStorageScreenState extends State<FileStorageScreen> {
  final _filenameController = TextEditingController();
  final _contentController = TextEditingController();
  final _fileService = FileStorageService();
  List<String> _files = [];
  String _selectedFileContent = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final files = await _fileService.listFiles();
    setState(() {
      _files = files;
    });
  }

  Future<void> _saveFile() async {
    if (_filenameController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      await _fileService.writeFile(
        _filenameController.text,
        _contentController.text,
      );
      _filenameController.clear();
      _contentController.clear();
      _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('File saved!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _readFile(String filename) async {
    final content = await _fileService.readFile(filename);
    setState(() {
      _selectedFileContent = content;
    });
    if (mounted) {
      final theme = Theme.of(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(filename, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Text(content, style: theme.textTheme.bodyMedium),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteFile(String filename) async {
    await _fileService.deleteFile(filename);
    _loadFiles();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('File deleted!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarColor = widget.color ?? theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Storage'),
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
                  'FileSystem Access',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Read and write files directly to the device storage using path_provider.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _filenameController,
                  decoration: InputDecoration(
                    hintText: 'Filename (e.g., notes.txt)',
                    prefixIcon: Icon(Icons.description_rounded, color: appBarColor),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'File Content',
                    prefixIcon: Icon(Icons.edit_note_rounded, color: appBarColor),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _saveFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBarColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.save_rounded, size: 24),
                    label: const Text('Write to File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _files.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_copy_rounded, size: 64, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        Text(
                          'No files found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _files.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final filename = _files[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: appBarColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.insert_drive_file_rounded, color: appBarColor),
                          ),
                          title: Text(
                            filename,
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, color: Colors.blueAccent),
                                onPressed: () => _readFile(filename),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                onPressed: () => _deleteFile(filename),
                              ),
                            ],
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
    _filenameController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
