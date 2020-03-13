import 'package:test/test.dart';
import 'package:unsure/src/parser.dart';

void main() {
  test('no range', () {
    var formula = parseString('1 + 2');

    expect(formula(), 3);
    // Once again, to see that this is consistent.
    expect(formula(), 3);
  });

  test('correct operator precedence', () {
    var formula = parseString('1 + 2 * 5');

    expect(formula(), 11);
  });

  test('range produces different numbers', () {
    var formula = parseString('1~2');

    var a = formula();
    var b = formula();
    expect(a, isNot(b));
  });

  test('range has precedence over multiplication', () {
    var formula = parseString('1000*1~2');

    var a = formula();
    expect(a, greaterThan(500));
  });
}
