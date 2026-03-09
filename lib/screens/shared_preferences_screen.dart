import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class SharedPreferencesScreen extends StatefulWidget {
  final Color color;
  const SharedPreferencesScreen({super.key, required this.color});

  @override
  State<SharedPreferencesScreen> createState() =>
      _SharedPreferencesScreenState();
}

class _SharedPreferencesScreenState extends State<SharedPreferencesScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _themeService = ThemeService();
  String _savedName = '';
  int _savedAge = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadName();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedName = prefs.getString('user_name') ?? 'Not set';
      _savedAge = prefs.getInt('user_age') ?? 0;
    });
  }

  Future<void> _loadName() async {
    await _loadData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_nameController.text.isNotEmpty) {
      await prefs.setString('user_name', _nameController.text);
    }
    if (_ageController.text.isNotEmpty) {
      await prefs.setInt('user_age', int.tryParse(_ageController.text) ?? 0);
    }
    _nameController.clear();
    _ageController.clear();
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data saved!'),
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

    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SharedPreferences'),
            backgroundColor: widget.color,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Preferences',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Settings are persisted locally using key-value pairs.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Toggle app-wide theme preference'),
                          value: _themeService.isDarkMode,
                          activeColor: appBarColor,
                          onChanged: (bool value) {
                            _themeService.toggleTheme(value);
                          },
                        ),
                        const Divider(height: 32),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            prefixIcon: Icon(Icons.person_rounded, color: appBarColor),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter your age',
                            prefixIcon: Icon(Icons.cake_rounded, color: appBarColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _saveData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appBarColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Save Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: appBarColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: appBarColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: appBarColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Stored Values',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildDataRow('Name', _savedName, theme),
                      const SizedBox(height: 12),
                      _buildDataRow('Age', _savedAge == 0 ? 'Not set' : _savedAge.toString(), theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
