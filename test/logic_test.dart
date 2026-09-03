import 'package:calc_web/logic/calculator.dart';
import 'package:calc_web/logic/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculate', () {
    test('adds two numbers', () {
      final result = calculate('2', '+', '3');

      expect(result, isA<CalcSuccess>());
      expect((result as CalcSuccess).value, 5.0);
    });

    test('subtracts two numbers', () {
      final result = calculate('7', '-', '10');

      expect(result, isA<CalcSuccess>());
      expect((result as CalcSuccess).value, -3.0);
    });

    test('multiplies two numbers', () {
      final result = calculate('2.5', '*', '4');

      expect(result, isA<CalcSuccess>());
      expect((result as CalcSuccess).value, 10.0);
    });

    test('returns CalcFailure when dividing by zero', () {
      final result = calculate('8', '/', '0');

      expect(result, isA<CalcFailure>());
    });

    test('returns CalcFailure for non-numeric input', () {
      final result = calculate('not-a-number', '+', '2');

      expect(result, isA<CalcFailure>());
    });

    test('accepts decimal numbers with commas', () {
      final result = calculate('1,25', '+', '2,5');

      expect(result, isA<CalcSuccess>());
      expect((result as CalcSuccess).value, 3.75);
    });
  });

  group('convert', () {
    test('converts USD to RUB using the fixed exchange rate', () {
      final result = convert('2', 'USD', 'RUB');

      expect(result, isA<ConvertSuccess>());
      expect((result as ConvertSuccess).value, 180.0);
    });

    test('returns ConvertFailure for a negative amount', () {
      final result = convert('-10', 'USD', 'RUB');

      expect(result, isA<ConvertFailure>());
    });

    test('returns ConvertFailure for non-numeric input', () {
      final result = convert('not-a-number', 'USD', 'RUB');

      expect(result, isA<ConvertFailure>());
    });

    test('keeps the amount when converting a currency to itself', () {
      final result = convert('42.37', 'USD', 'USD');

      expect(result, isA<ConvertSuccess>());
      expect((result as ConvertSuccess).value, 42.37);
    });
  });
}
