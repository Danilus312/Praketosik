sealed class ConvertResult {
  const ConvertResult();
}

final class ConvertSuccess extends ConvertResult {
  const ConvertSuccess(this.value);

  final double value;
}

final class ConvertFailure extends ConvertResult {
  const ConvertFailure(this.message);

  final String message;
}

/// Number of currency units equivalent to one US dollar.
const Map<String, double> currencyRates = <String, double>{
  'USD': 1.0,
  'RUB': 90.0,
  'EUR': 0.92,
  'CNY': 7.2,
  'KZT': 500.0,
};

ConvertResult convert(String? rawAmount, String? from, String? to) {
  final amount = rawAmount == null
      ? null
      : double.tryParse(rawAmount.trim().replaceAll(',', '.'));

  if (amount == null || !amount.isFinite) {
    return const ConvertFailure('Указана некорректная сумма');
  }
  if (amount <= 0) {
    return const ConvertFailure('Сумма должна быть положительной');
  }

  final fromCode = from?.trim().toUpperCase();
  final toCode = to?.trim().toUpperCase();

  if (fromCode == null || fromCode.isEmpty) {
    return const ConvertFailure('Не указана исходная валюта');
  }
  if (toCode == null || toCode.isEmpty) {
    return const ConvertFailure('Не указана целевая валюта');
  }

  final fromRate = currencyRates[fromCode];
  final toRate = currencyRates[toCode];

  if (fromRate == null) {
    return ConvertFailure('Валюта $fromCode не поддерживается');
  }
  if (toRate == null) {
    return ConvertFailure('Валюта $toCode не поддерживается');
  }

  final convertedValue = amount / fromRate * toRate;
  if (!convertedValue.isFinite) {
    return const ConvertFailure('Сумма слишком велика для конвертации');
  }

  final roundedValue = double.parse(convertedValue.toStringAsFixed(2));
  return ConvertSuccess(roundedValue);
}
