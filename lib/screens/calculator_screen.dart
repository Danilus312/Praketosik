import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const List<String> _operations = ['+', '-', '*', '/'];

  final _formKey = GlobalKey<FormState>();
  final _firstNumberController = TextEditingController();
  final _secondNumberController = TextEditingController();

  String _operation = '+';

  @override
  void dispose() {
    _firstNumberController.dispose();
    _secondNumberController.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    final normalizedValue = value?.trim().replaceAll(',', '.');

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return 'Введите число';
    }

    final number = double.tryParse(normalizedValue);
    if (number == null || !number.isFinite) {
      return 'Введите корректное число';
    }

    return null;
  }

  void _calculate() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final a = Uri.encodeQueryComponent(
      _firstNumberController.text.trim().replaceAll(',', '.'),
    );
    final b = Uri.encodeQueryComponent(
      _secondNumberController.text.trim().replaceAll(',', '.'),
    );
    final operation = _operation;

    context.go(
      '/calculator/result?a=$a&op=${Uri.encodeComponent(operation)}&b=$b',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        leading: IconButton(
          tooltip: 'На главную',
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home_outlined),
        ),
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _firstNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Первое число',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _validateNumber,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _operation,
                      decoration: const InputDecoration(
                        labelText: 'Операция',
                        border: OutlineInputBorder(),
                      ),
                      items: _operations
                          .map(
                            (operation) => DropdownMenuItem<String>(
                              value: operation,
                              child: Text(operation),
                            ),
                          )
                          .toList(),
                      onChanged: (operation) {
                        if (operation != null) {
                          setState(() => _operation = operation);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _secondNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Второе число',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: _validateNumber,
                      onFieldSubmitted: (_) => _calculate(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Вычислить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}