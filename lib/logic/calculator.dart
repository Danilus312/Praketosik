sealed class CalcResult {
  const CalcResult();
}

final class CalcSuccess extends CalcResult {
  const CalcSuccess(this.value);

  final double value;
}

final class CalcFailure extends CalcResult {
  const CalcFailure(this.message);

  final String message;
}

CalcResult calculate(String? rawA, String? rawOp, String? rawB) {
  if (rawA == null || rawOp == null || rawB == null) {
    return const CalcFailure('В адресе переданы не числа');
  }

  final a = _tryParseNumber(rawA);
  final b = _tryParseNumber(rawB);

  if (a == null || b == null) {
    return const CalcFailure('В адресе переданы не числа');
  }

  final double result;

  switch (rawOp.trim()) {
    case '+':
      result = a + b;
    case '-':
      result = a - b;
    case '*':
      result = a * b;
    case '/':
      if (b == 0) {
        return const CalcFailure('Деление на ноль невозможно');
      }
      result = a / b;
    default:
      return const CalcFailure('Неизвестная операция');
  }

  if (!result.isFinite) {
    return const CalcFailure('Результат вычисления некорректен');
  }

  final roundedResult = double.parse(result.toStringAsFixed(4));
  return CalcSuccess(roundedResult);
}

double? _tryParseNumber(String rawValue) {
  final value = double.tryParse(rawValue.trim().replaceAll(',', '.'));
  return value != null && value.isFinite ? value : null;
}
