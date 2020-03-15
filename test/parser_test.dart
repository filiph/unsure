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
}
