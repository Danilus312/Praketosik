import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: sharedPreferences),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(sharedPreferences),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier(this._sharedPreferences)
    : _isDarkTheme = _sharedPreferences.getBool(_isDarkThemeKey) ?? false;

  static const String _isDarkThemeKey = 'is_dark_theme';

  final SharedPreferences _sharedPreferences;
  bool _isDarkTheme;

  bool get isDarkTheme => _isDarkTheme;

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkTheme(bool value) async {
    if (_isDarkTheme == value) return;

    _isDarkTheme = value;
    notifyListeners();
    await _sharedPreferences.setBool(_isDarkThemeKey, value);
  }

  Future<void> toggleTheme() => setDarkTheme(!_isDarkTheme);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeNotifier>().themeMode;

    return MaterialApp.router(
      title: 'Калькулятор и Конвертер',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
