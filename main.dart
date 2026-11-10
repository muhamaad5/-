import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الآلة الحاسبة',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F8C),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101820),
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
  String expression = '0';
  String result = '0';
  bool justCalculated = false;

  final List<String> buttons = const [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  void press(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '0';
        result = '0';
        justCalculated = false;
        return;
      }
      if (value == '⌫') {
        if (justCalculated) {
          expression = '0';
          result = '0';
          justCalculated = false;
        } else {
          expression = expression.length <= 1
              ? '0'
              : expression.substring(0, expression.length - 1);
          _preview();
        }
        return;
      }
      if (value == '=') {
        _calculate();
        return;
      }
      if (value == '±') {
        if (expression == '0') return;
        if (expression.startsWith('-')) {
          expression = expression.substring(1);
        } else {
          expression = '-$expression';
        }
        _preview();
        return;
      }
      if (value == '%') {
        try {
          final number = _evaluate(expression) / 100;
          expression = _format(number);
          result = expression;
        } catch (_) {}
        justCalculated = false;
        return;
      }

      final isOperator = ['+', '−', '×', '÷'].contains(value);
      final isDigit = RegExp(r'^[0-9]$').hasMatch(value);

      if (justCalculated && (isDigit || value == '.')) {
        expression = '0';
        result = '0';
      }
      justCalculated = false;

      if (isOperator) {
        if (['+', '−', '×', '÷'].contains(expression[expression.length - 1])) {
          expression = expression.substring(0, expression.length - 1) + value;
        } else {
          expression += value;
        }
      } else if (value == '.') {
        final currentNumber = expression.split(RegExp(r'[+−×÷]')).last;
        if (!currentNumber.contains('.')) {
          expression += currentNumber.isEmpty ? '0.' : '.';
        }
      } else if (isDigit) {
        expression = expression == '0' ? value : expression + value;
      }
      _preview();
    });
  }

  void _preview() {
    try {
      result = _format(_evaluate(expression));
    } catch (_) {
      result = '';
    }
  }

  void _calculate() {
    try {
      final value = _evaluate(expression);
      result = _format(value);
      expression = result;
      justCalculated = true;
    } catch (_) {
      result = 'خطأ';
    }
  }

  String _format(double value) {
    if (!value.isFinite) return 'خطأ';
    if (value.abs() < 1e-10) value = 0;
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsPrecision(10).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double _evaluate(String input) {
    final normalized = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(' ', '');
    final tokens = RegExp(r'\d+\.?\d*|[+\-*/]').allMatches(normalized)
        .map((m) => m.group(0)!)
        .toList();
    if (tokens.isEmpty) throw const FormatException();
    int index = 0;

    double parseExpression() {
      double value = parseTerm();
      while (index < tokens.length &&
          (tokens[index] == '+' || tokens[index] == '-')) {
        final op = tokens[index++];
        final right = parseTerm();
        value = op == '+' ? value + right : value - right;
      }
      return value;
    }

    double parseTerm() {
      double value = parseNumber();
      while (index < tokens.length &&
          (tokens[index] == '*' || tokens[index] == '/')) {
        final op = tokens[index++];
        final right = parseNumber();
        if (op == '/' && right == 0) throw const FormatException();
        value = op == '*' ? value * right : value / right;
      }
      return value;
    }

    double parseNumber() {
      if (index >= tokens.length) throw const FormatException();
      if (tokens[index] == '-') {
        index++;
        return -parseNumber();
      }
      if (tokens[index] == '+') {
        index++;
        return parseNumber();
      }
      final token = tokens[index++];
      return double.parse(token);
    }

    final answer = parseExpression();
    if (index != tokens.length) throw const FormatException();
    return answer;
  }

  Color _buttonColor(String value) {
    if (value == '=') return const Color(0xFF00A6A6);
    if (['÷', '×', '−', '+'].contains(value)) return const Color(0xFF174B59);
    if (['AC', '⌫', '%', '±'].contains(value)) return const Color(0xFF34434D);
    return const Color(0xFF1D2A33);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الآلة الحاسبة', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            expression,
                            style: const TextStyle(fontSize: 30, color: Color(0xFFB7C5CC)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            result,
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: buttons.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.18,
                    ),
                    itemBuilder: (context, index) {
                      final value = buttons[index];
                      return Material(
                        color: _buttonColor(value),
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => press(value),
                          child: Center(
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: value.length > 1 ? 21 : 27,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
