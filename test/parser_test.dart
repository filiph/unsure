import 'package:test/test.dart';
import 'package:unsure/src/ast.dart';
import 'package:unsure/src/parser.dart';

void main() {
  group('parser with no variables', () {
    late FormulaParser parser;

    setUp(() {
      parser = FormulaParser();
    });

    test('no range', () {
      var formula = parser.parseString('1 + 2');

      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 3);
      // Once again, to see that this is consistent.
      expect(formula.emit(), 3);
    });

    test('correct operator precedence', () {
      var formula = parser.parseString('1 + 2 * 5');

      expect(formula.emit(), 11);
    });

    test('parses first - (minus) correctly', () {
      var formula = parser.parseString('-100~-10');

      expect(formula.isStochastic, isTrue);
      expect(formula.emit(), isNegative);
    });

    test('range produces different numbers', () {
      var formula = parser.parseString('1~2');

      expect(formula.isStochastic, isTrue);

      var a = formula.emit();
      var b = formula.emit();
      expect(a, isNot(b));
    });

    test('range has precedence over multiplication', () {
      var formula = parser.parseString('1000*1~2');

      var a = formula.emit();
      expect(a, greaterThan(500));
    });

    test('parses Python-style exponentiation', () {
      var formula = parser.parseString('3**2');

      expect(formula.emit(), 9);
    });

    test('parses sine function of constant', () {
      var formula = parser.parseString('sin(0)');

      var a = formula.emit();
      expect(a, equals(0));
      expect(formula.isStochastic, isFalse);
    });

    test('parses sine function of a more complicated expression', () {
      var formula = parser.parseString('sin(1~2 + 4 ^ 1)');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isTrue);
    });

    test('parses sine function followed by something else', () {
      var formula = parser.parseString('sin(0) * 100');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 0);
    });

    test('parses sine function prepended by something else', () {
      var formula = parser.parseString('100 * sin(0)');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 0);
    });

    test('parses sqrt', () {
      var formula = parser.parseString('sqrt(4)');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 2);
    });

    test('parses %', () {
      var formula = parser.parseString('10%');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 0.1);
    });

    test('parses K', () {
      var formula = parser.parseString('42K');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 42000);
    });

    test('parses M', () {
      var formula = parser.parseString('42M');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 42000000);
    });

    test('postfixes have meaningful precedence', () {
      var formula = parser.parseString('42K * -10%');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 42000 * (-0.1));
    });

    test('K postfix plays well with ranges', () {
      // This means "10,000 to 20,000", not "10 to 20,000".
      var formula = parser.parseString('10~20K');

      expect(formula.emit, returnsNormally);
      expect(formula.isStochastic, isTrue);
      expect(formula.rootNode, isA<ConstantMultipleNode>());
      expect(formula.emit(), greaterThan(1000));
    });

    test('K postfix cannot be in front of the range operator', () {
      // This means "10,000 to 2,000,000". But it doesn't work.
      var formula = parser.parseString('10K~2M');

      expect(formula.wasFailure, isTrue);
    });
  });
}
