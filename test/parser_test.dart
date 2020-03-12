import 'package:uncertainty/src/parser.dart';
import 'package:test/test.dart';

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
}
