import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            tooltip: themeNotifier.isDarkTheme
                ? 'Включить светлую тему'
                : 'Включить тёмную тему',
            onPressed: themeNotifier.toggleTheme,
            icon: Icon(
              themeNotifier.isDarkTheme
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go('/calculator'),
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Калькулятор'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/converter'),
                    icon: const Icon(Icons.currency_exchange_outlined),
                    label: const Text('Конвертер'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
