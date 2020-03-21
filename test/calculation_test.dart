import 'package:test/test.dart';
import 'package:unsure/unsure.dart';

void main() {
  test('works for simple input', () {
    var formula = parseString('1000 + 2~4');
    var calculation = Calculation(formula.emit);

    expect(() => calculation.run(), returnsNormally);
  });

  test('doesn\'t break when all output is not a number', () {
    var formula = parseString('100~101 / 0');
    var calculation = Calculation(formula.emit);

    Result result;
    expect(() => result= calculation.run(), returnsNormally);
    expect(result.isInvalid, isTrue);
  });
}
