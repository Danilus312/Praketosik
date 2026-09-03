import 'package:go_router/go_router.dart';

import 'screens/calculator_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/result_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/calculator',
      builder: (context, state) => const CalculatorScreen(),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final queryParameters = state.uri.queryParameters;
            final a = queryParameters['a'] ?? '';
            final operation = queryParameters['op'] ?? '';
            final b = queryParameters['b'] ?? '';
            final rawQuery = {'a': a, 'op': operation, 'b': b};

            return ResultScreen(
              title: 'Результат вычислений',
              expression: '$a $operation $b',
              rawQuery: rawQuery,
              type: 'calculator',
              backPath: '/calculator',
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/converter',
      builder: (context, state) => const ConverterScreen(),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final queryParameters = state.uri.queryParameters;
            final amount = queryParameters['amount'] ?? '';
            final from = queryParameters['from'] ?? '';
            final to = queryParameters['to'] ?? '';
            final rawQuery = {'amount': amount, 'from': from, 'to': to};

            return ResultScreen(
              title: 'Результат конвертации',
              expression: '$amount $from → $to',
              rawQuery: rawQuery,
              type: 'converter',
              backPath: '/converter',
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
);
