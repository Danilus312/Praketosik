import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/currency.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  static const String _fromCurrencyKey = 'converter_from_currency';
  static const String _toCurrencyKey = 'converter_to_currency';

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  late final SharedPreferences _preferences;
  late String _fromCurrency;
  late String _toCurrency;

  List<String> get _currencies => currencyRates.keys.toList(growable: false);

  @override
  void initState() {
    super.initState();
    _preferences = context.read<SharedPreferences>();
    _fromCurrency = _readCurrency(_fromCurrencyKey, fallback: 'USD');
    _toCurrency = _readCurrency(_toCurrencyKey, fallback: 'RUB');
  }

  String _readCurrency(String key, {required String fallback}) {
    final savedCurrency = _preferences.getString(key)?.trim().toUpperCase();
    return savedCurrency != null && currencyRates.containsKey(savedCurrency)
        ? savedCurrency
        : fallback;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final rawAmount = value?.trim() ?? '';
    if (rawAmount.isEmpty) {
      return 'Введите сумму';
    }

    final amount = double.tryParse(rawAmount.replaceAll(',', '.'));
    if (amount == null || !amount.isFinite) {
      return 'Введите корректное число';
    }
    if (amount <= 0) {
      return 'Сумма должна быть больше нуля';
    }

    return null;
  }

  Future<void> _saveCurrencyPair() async {
    await Future.wait([
      _preferences.setString(_fromCurrencyKey, _fromCurrency),
      _preferences.setString(_toCurrencyKey, _toCurrency),
    ]);
  }

  void _setFromCurrency(String? currency) {
    if (currency == null) return;

    setState(() => _fromCurrency = currency);
    unawaited(_saveCurrencyPair());
  }

  void _setToCurrency(String? currency) {
    if (currency == null) return;

    setState(() => _toCurrency = currency);
    unawaited(_saveCurrencyPair());
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _saveCurrencyPair();
    if (!mounted) return;

    final amount = Uri.encodeQueryComponent(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    final from = Uri.encodeQueryComponent(_fromCurrency);
    final to = Uri.encodeQueryComponent(_toCurrency);
    context.go('/converter/result?amount=$amount&from=$from&to=$to');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          tooltip: 'На главную',
          icon: const Icon(Icons.home_outlined),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      hintText: 'Например, 100',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Из валюты',
                      border: OutlineInputBorder(),
                    ),
                    items: _buildCurrencyItems(),
                    onChanged: _setFromCurrency,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _toCurrency,
                    decoration: const InputDecoration(
                      labelText: 'В валюту',
                      border: OutlineInputBorder(),
                    ),
                    items: _buildCurrencyItems(),
                    onChanged: _setToCurrency,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.currency_exchange),
                    label: const Text('Конвертировать'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('На главную'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildCurrencyItems() {
    return _currencies
        .map(
          (currency) =>
              DropdownMenuItem<String>(value: currency, child: Text(currency)),
        )
        .toList(growable: false);
  }
}