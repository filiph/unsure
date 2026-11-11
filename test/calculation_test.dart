import 'package:test/test.dart';
import 'package:unsure/unsure.dart';

void main() {
  test('works for simple input', () {
    var parser = FormulaParser();
    var formula = parser.parseString('1000 + 2~4');
    var calculation = Calculation(formula.emit);

    expect(() => calculation.run(), returnsNormally);
  });

  test('doesn\'t break when all output is not a number', () {
    var parser = FormulaParser();
    var formula = parser.parseString('100~101 / 0');
    var calculation = Calculation(formula.emit);

    late Result result;
    expect(() => result = calculation.run(), returnsNormally);
    expect(result.isInvalid, isTrue);
  });

  group('degenerate distribution', () {
    test('handles zero-variance simulation results gracefully', () {
      // Simulate an unprovable stochastic function that always produces 0.
      var calculation = Calculation(() => 0.0, iterations: 1000);
      var result = calculation.run();

      expect(result.isDegenerate, isTrue);
      expect(result.simple, '0');
      expect(result.histogram, isNull);
      expect(result.percentilesString, contains('All percentiles are 0.'));
    });

    test('handles zero-variance non-zero simulation results', () {
      var calculation = Calculation(() => 42.0, iterations: 1000);
      var result = calculation.run();

      expect(result.isDegenerate, isTrue);
      expect(result.simple, '42');
      expect(result.histogram, isNull);
      expect(result.percentilesString, contains('All percentiles are 42.'));
    });
  });
}
