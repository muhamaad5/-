
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

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

  static const List<String> buttons = [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  bool isOperator(String value) {
    return ['+', '−', '×', '÷'].contains(value);
  }

  void press(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '0';
        result = '0';
        justCalculated = false;
        return;
      }

      if (value == '⌫') {
        if (justCalculated || expression.length <= 1) {
          expression = '0';
          result = '0';
          justCalculated = false;
        } else {
          expression = expression.substring(0, expression.length - 1);
          preview();
        }
        return;
      }

      if (value == '=') {
        calculate();
        return;
      }

      if (value == '±') {
        if (expression == '0') return;

        expression = expression.startsWith('-')
            ? expression.substring(1)
            : '-$expression';

        preview();
        justCalculated = false;
        return;
      }

      if (value == '%') {
        try {
          expression = format(evaluate(expression) / 100);
          result = expression;
        } catch (_) {
          result = 'خطأ';
        }
        justCalculated = false;
        return;
      }

      final isDigit = RegExp(r'^[0-9]$').hasMatch(value);

      if (justCalculated && (isDigit || value == '.')) {
        expression = '0';
        result = '0';
      }

      justCalculated = false;

      if (isOperator(value)) {
        if (isOperator(expression[expression.length - 1])) {
          expression =
              expression.substring(0, expression.length - 1) + value;
        } else {
          expression += value;
        }
      } else if (value == '.') {
        final current = expression.split(RegExp(r'[+−×÷]')).last;
        if (!current.contains('.')) {
          expression += current.isEmpty ? '0.' : '.';
        }
      } else if (isDigit) {
        expression = expression == '0' ? value : expression + value;
      }

      preview();
    });
  }

  void preview() {
    try {
      result = format(evaluate(expression));
    } catch (_) {
      result = '';
    }
  }

  void calculate() {
    try {
      final answer = evaluate(expression);
      result = format(answer);
      expression = result;
      justCalculated = true;
    } catch (_) {
      result = 'خطأ';
      justCalculated = false;
    }
  }

  String format(double value) {
    if (!value.isFinite) return 'خطأ';

    if (value.abs() < 0.0000000001) {
      value = 0;
    }

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsPrecision(10)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double evaluate(String input) {
    final text = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(' ', '');

    if (text.isEmpty) throw const FormatException();

    final numbers = <double>[];
    final operators = <String>[];

    int precedence(String op) {
      return (op == '*' || op == '/') ? 2 : 1;
    }

    void applyOperation() {
      if (numbers.length < 2 || operators.isEmpty) {
        throw const FormatException();
      }

      final b = numbers.removeLast();
      final a = numbers.removeLast();
      final op = operators.removeLast();

      switch (op) {
        case '+':
          numbers.add(a + b);
          break;
        case '-':
          numbers.add(a - b);
          break;
        case '*':
          numbers.add(a * b);
          break;
        case '/':
          if (b == 0) throw const FormatException();
          numbers.add(a / b);
          break;
        default:
          throw const FormatException();
      }
    }

    int index = 0;
    bool needNumber = true;

    while (index < text.length) {
      if (needNumber) {
        int sign = 1;

        if (text[index] == '-') {
          sign = -1;
          index++;
        } else if (text[index] == '+') {
          index++;
        }

        if (index >= text.length) {
          throw const FormatException();
        }

        final start = index;
        bool hasDigit = false;
        bool hasDot = false;

        while (index < text.length) {
          final char = text[index];

          if (RegExp(r'[0-9]').hasMatch(char)) {
            hasDigit = true;
            index++;
          } else if (char == '.' && !hasDot) {
            hasDot = true;
            index++;
          } else {
            break;
          }
        }

        if (!hasDigit) throw const FormatException();

        final number = double.parse(text.substring(start, index));
        numbers.add(number * sign);
        needNumber = false;
      } else {
        final op = text[index];

        if (!['+', '-', '*', '/'].contains(op)) {
          throw const FormatException();
        }

        while (operators.isNotEmpty &&
            precedence(operators.last) >= precedence(op)) {
          applyOperation();
        }

        operators.add(op);
        index++;
        needNumber = true;
      }
    }

    if (needNumber) throw const FormatException();

    while (operators.isNotEmpty) {
      applyOperation();
    }

    if (numbers.length != 1) throw const FormatException();

    return numbers.single;
  }

  Color buttonColor(String value) {
    if (value == '=') {
      return const Color(0xFF00A6A6);
    }

    if (isOperator(value)) {
      return const Color(0xFF174B59);
    }

    if (['AC', '⌫', '%', '±'].contains(value)) {
      return const Color(0xFF34434D);
    }

    return const Color(0xFF1D2A33);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الآلة الحاسبة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
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
                              style: const TextStyle(
                                fontSize: 30,
                                color: Color(0xFFB7C5CC),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Text(
                              result,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
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
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: buttons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.18,
                    ),
                    itemBuilder: (context, index) {
                      final value = buttons[index];

                      return Material(
                        color: buttonColor(value),
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
