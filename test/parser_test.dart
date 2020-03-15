import 'package:test/test.dart';
import 'package:unsure/src/parser.dart';

void main() {
  test('no range', () {
    var formula = parseString('1 + 2');

    expect(formula.isStochastic, isFalse);
    expect(formula.emit(), 3);
    // Once again, to see that this is consistent.
    expect(formula.emit(), 3);
  });

  test('correct operator precedence', () {
    var formula = parseString('1 + 2 * 5');

    expect(formula.emit(), 11);
  });

  test('range produces different numbers', () {
    var formula = parseString('1~2');

    expect(formula.isStochastic, isTrue);

    var a = formula.emit();
    var b = formula.emit();
    expect(a, isNot(b));
  });

  test('range has precedence over multiplication', () {
    var formula = parseString('1000*1~2');

    var a = formula.emit();
    expect(a, greaterThan(500));
  });

  test('parses Python-style exponentiation', () {
    var formula = parseString('3**2');

    expect(formula.emit(), 9);
  });

  test('parses sine function of constant', () {
    var formula = parseString('sin(0)');

    var a = formula.emit();
    expect(a, equals(0));
    expect(formula.isStochastic, isFalse);
  });

  test('parses sine function of a more complicated expression', () {
    var formula = parseString('sin(1~2 + 4 ^ 1)');

    expect(formula.emit, returnsNormally);
    expect(formula.isStochastic, isTrue);
  });

  test('parses sine function followed by something else', () {
    var formula = parseString('sin(0) * 100');

    expect(formula.emit, returnsNormally);
    expect(formula.isStochastic, isFalse);
    expect(formula.emit(), 0);
  });

  test('parses sine function prepended by something else', () {
    var formula = parseString('100 * sin(0)');

    expect(formula.emit, returnsNormally);
    expect(formula.isStochastic, isFalse);
    expect(formula.emit(), 0);
  });

  test('parses sqrt', () {
    var formula = parseString('sqrt(4)');

    expect(formula.emit, returnsNormally);
    expect(formula.isStochastic, isFalse);
    expect(formula.emit(), 2);
  });
}
