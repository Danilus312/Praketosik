import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/calculator.dart';
import '../logic/currency.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.title,
    required this.expression,
    required this.rawQuery,
    required this.backPath,
    required this.type,
  });

  final String title;
  final String expression;
  final Map<String, String> rawQuery;
  final String backPath;
  final String type;

  @override
  Widget build(BuildContext context) {
    final result = _resolveResult();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ResultContent(result: result, expression: expression),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () => context.go(backPath),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Назад'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ResultViewData _resolveResult() {
    return switch (type) {
      'calculator' => switch (calculate(
        rawQuery['a'],
        rawQuery['op'],
        rawQuery['b'],
      )) {
        CalcSuccess(:final value) => _ResultSuccess(value),
        CalcFailure(:final message) => _ResultFailure(message),
      },
      'converter' => switch (convert(
        rawQuery['amount'],
        rawQuery['from'],
        rawQuery['to'],
      )) {
        ConvertSuccess(:final value) => _ResultSuccess(value),
        ConvertFailure(:final message) => _ResultFailure(message),
      },
      _ => const _ResultFailure('Неизвестный тип операции'),
    };
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.result, required this.expression});

  final _ResultViewData result;
  final String expression;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (result) {
      _ResultSuccess(:final value) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 20),
          SelectableText(
            value.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Исходное выражение',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          SelectableText(
            expression,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      _ResultFailure(:final message) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    };
  }
}

sealed class _ResultViewData {
  const _ResultViewData();
}

final class _ResultSuccess extends _ResultViewData {
  const _ResultSuccess(this.value);

  final double value;
}

final class _ResultFailure extends _ResultViewData {
  const _ResultFailure(this.message);

  final String message;
}
