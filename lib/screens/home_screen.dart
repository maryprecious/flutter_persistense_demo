import 'package:flutter/material.dart';
import 'shared_preferences_screen.dart';
import 'hive_screen.dart';
import 'sqlite_screen.dart';
import 'file_storage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Persistence'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildCard(
            context,
            title: 'SharedPreferences',
            description: 'Simple key-value pairs storage',
            icon: Icons.settings_rounded,
            color: const Color(0xFF2563EB), // Blue
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SharedPreferencesScreen(color: Color(0xFF2563EB)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            context,
            title: 'Hive',
            description: 'High-performance NoSQL database',
            icon: Icons.storage_rounded,
            color: const Color(0xFFF97316), // Orange
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HiveScreen(color: Color(0xFFF97316)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            context,
            title: 'SQLite',
            description: 'Robust relational database',
            icon: Icons.table_chart_rounded,
            color: const Color(0xFF0D9488), // Teal
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SQLiteScreen(color: Color(0xFF0D9488)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            context,
            title: 'File Storage',
            description: 'Direct file system access',
            icon: Icons.folder_rounded,
            color: const Color(0xFF0891B2), // Cyan
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FileStorageScreen(color: Color(0xFF0891B2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
