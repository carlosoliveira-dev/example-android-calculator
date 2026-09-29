import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF3B82F6);

    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  String? _operator;
  double? _storedValue;
  bool _waitingForOperand = false;
  bool _hasError = false;

  void _press(String value) {
    setState(() {
      if (_hasError && value != 'AC') {
        _clear();
      }

      switch (value) {
        case 'AC':
          _clear();
        case '⌫':
          _deleteLastDigit();
        case '±':
          _toggleSign();
        case '%':
          _percentage();
        case '+':
        case '−':
        case '×':
        case '÷':
          _setOperator(value);
        case '=':
          _calculate();
        case ',':
          _addDecimalSeparator();
        default:
          _addDigit(value);
      }
    });
  }

  void _clear() {
    _display = '0';
    _expression = '';
    _operator = null;
    _storedValue = null;
    _waitingForOperand = false;
    _hasError = false;
  }

  void _addDigit(String digit) {
    if (_waitingForOperand) {
      _display = digit;
      _waitingForOperand = false;
      return;
    }

    if (_display == '0') {
      _display = digit;
    } else if (_display.length < 14) {
      _display += digit;
    }
  }

  void _addDecimalSeparator() {
    if (_waitingForOperand) {
      _display = '0,';
      _waitingForOperand = false;
    } else if (!_display.contains(',')) {
      _display += ',';
    }
  }

  void _deleteLastDigit() {
    if (_waitingForOperand) return;
    _display = _display.length > 1
        ? _display.substring(0, _display.length - 1)
        : '0';
    if (_display == '-') _display = '0';
  }

  void _toggleSign() {
    if (_display == '0') return;
    _display = _display.startsWith('-') ? _display.substring(1) : '-$_display';
  }

  void _percentage() {
    final value = _readDisplay();
    if (value == null) return;
    _display = _formatNumber(value / 100);
  }

  void _setOperator(String operator) {
    final currentValue = _readDisplay();
    if (currentValue == null) return;

    if (_operator != null && !_waitingForOperand && _storedValue != null) {
      final result = _applyOperation(_storedValue!, currentValue, _operator!);
      if (result == null) return;
      _display = _formatNumber(result);
    }

    _storedValue = _readDisplay();
    _operator = operator;
    _expression = '${_formatNumber(_storedValue!)} $operator';
    _waitingForOperand = true;
  }

  void _calculate() {
    final operator = _operator;
    final storedValue = _storedValue;
    final currentValue = _readDisplay();
    if (operator == null || storedValue == null || currentValue == null) return;

    final result = _applyOperation(storedValue, currentValue, operator);
    if (result == null) return;

    _expression =
        '${_formatNumber(storedValue)} $operator '
        '${_formatNumber(currentValue)} =';
    _display = _formatNumber(result);
    _operator = null;
    _storedValue = null;
    _waitingForOperand = true;
  }

  double? _applyOperation(double left, double right, String operator) {
    if (operator == '÷' && right == 0) {
      _display = 'Erro';
      _expression = 'Não é possível dividir por zero';
      _hasError = true;
      _operator = null;
      _storedValue = null;
      _waitingForOperand = true;
      return null;
    }

    return switch (operator) {
      '+' => left + right,
      '−' => left - right,
      '×' => left * right,
      '÷' => left / right,
      _ => null,
    };
  }

  double? _readDisplay() => double.tryParse(_display.replaceAll(',', '.'));

  String _formatNumber(double number) {
    if (!number.isFinite) return 'Erro';
    if (number == 0) return '0';

    final rounded = double.parse(number.toStringAsPrecision(12));
    var formatted = rounded.toString();
    if (formatted.endsWith('.0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }
    return formatted.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Calculadora',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.more_horiz_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 28, top: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 28,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _expression,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 88,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _display,
                                key: const Key('calculator-display'),
                                maxLines: 1,
                                style: textTheme.displayLarge?.copyWith(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -2,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildRow(['AC', '±', '%', '÷']),
                    _buildRow(['7', '8', '9', '×']),
                    _buildRow(['4', '5', '6', '−']),
                    _buildRow(['1', '2', '3', '+']),
                    _buildRow(['⌫', '0', ',', '=']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels) {
    return Expanded(
      child: Row(
        children: [
          for (final label in labels)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: _CalculatorKey(
                  label: label,
                  onPressed: () => _press(label),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalculatorKey extends StatelessWidget {
  const _CalculatorKey({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEquals = label == '=';
    final isOperator = const {'÷', '×', '−', '+'}.contains(label);
    final isUtility = const {'AC', '±', '%', '⌫'}.contains(label);
    final backgroundColor = isEquals
        ? colors.primary
        : isOperator
        ? colors.primaryContainer
        : isUtility
        ? colors.surfaceContainerHighest
        : colors.surfaceContainerLow;
    final foregroundColor = isEquals
        ? colors.onPrimary
        : isOperator
        ? colors.onPrimaryContainer
        : isUtility
        ? colors.onSurfaceVariant
        : colors.onSurface;
    final displayLabel = label == '⌫'
        ? const Icon(Icons.backspace_outlined, size: 23)
        : Text(label);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.zero,
        textStyle: TextStyle(
          fontSize: label == 'AC' ? 19 : 25,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: displayLabel,
    );
  }
}
