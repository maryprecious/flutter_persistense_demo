import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // i am initializing Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  final themeService = ThemeService();

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Persistence Demo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}