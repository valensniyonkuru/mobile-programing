import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: Color(0xFF1E1E1E), // Dark background
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // Button background color
            foregroundColor: Colors.white, // Button text color
          ),
        ),
      ),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _expression = '';
        _result = '';
      } else if (buttonText == '=') {
        try {
          _result = _calculate(_expression);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        if (_result.isNotEmpty && !_isOperator(buttonText)) {
          _expression = '';
          _result = '';
        }
        _expression += buttonText;
      }
    });
  }

  bool _isOperator(String buttonText) {
    return buttonText == '+' ||
        buttonText == '-' ||
        buttonText == '×' ||
        buttonText == '÷' ||
        buttonText == '%' ||
        buttonText == '(' ||
        buttonText == ')';
  }

  String _calculate(String expression) {
    try {
      // Handle modulus manually
      String modifiedExpression = _handleModulus(expression);
      // Replace × and ÷ with * and / respectively
      modifiedExpression =
          modifiedExpression.replaceAll('×', '*').replaceAll('÷', '/');

      final parser = Parser();
      final expressionAst = parser.parse(modifiedExpression);
      final result =
          expressionAst.evaluate(EvaluationType.REAL, ContextModel());
      return result.toString();
    } catch (e) {
      return 'Error';
    }
  }

  String _handleModulus(String expression) {
    RegExp regex = RegExp(r'(\d+\.?\d*)\s*%\s*(\d+\.?\d*)');
    while (regex.hasMatch(expression)) {
      expression = expression.replaceFirstMapped(regex, (match) {
        double leftOperand = double.parse(match.group(1)!);
        double rightOperand = double.parse(match.group(2)!);
        double result = leftOperand % rightOperand;
        return result.toString();
      });
    }
    return expression;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calculator',
          style: TextStyle(color: Colors.white), // Title color changed to white
        ),
        backgroundColor: Color(0xFF00897B), // Teal color for AppBar
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Color(0xFF1E1E1E), // Dark background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.1), // Slightly transparent white
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _expression,
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.1), // Slightly transparent white
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _result,
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildButtonRow(['(', ')', 'C', '÷']),
                  buildButtonRow(['7', '8', '9', '×']),
                  buildButtonRow(['4', '5', '6', '-']),
                  buildButtonRow(['1', '2', '3', '+']),
                  buildButtonRow(['0', '.', '=', '%']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButtonRow(List<String> buttonTexts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: buttonTexts
          .map((text) => CalculatorButton(text, _onButtonPressed))
          .toList(),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String _text;
  final Function _onPressed;

  CalculatorButton(this._text, this._onPressed);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF64B5F6),
                Color(0xFF64FFDA)
              ], // Gradient from light blue to light green
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          child: ElevatedButton(
            child: Text(
              _text,
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            onPressed: () => _onPressed(_text),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(24),
              backgroundColor: Colors
                  .transparent, // Make button background transparent to show gradient
              shadowColor: Colors.transparent, // Remove button shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Match border radius of container
              ),
            ),
          ),
        ),
      ),
    );
  }
}
