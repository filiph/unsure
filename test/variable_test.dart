import 'package:test/test.dart';
import 'package:unsure/unsure.dart';

void main() {
  group('using a constant (non-stochastic) formula', () {
    late FormulaAst constantFormula;

    setUp(() {
      constantFormula = FormulaParser().parseString('42', name: 'answer');
    });

    test('from another constant one', () {
      var nextParser = FormulaParser(variables: [constantFormula]);
      var formula = nextParser.parseString('answer + answer');

      expect(formula.wasFailure, isFalse);
      expect(formula.isStochastic, isFalse);
      expect(formula.emit(), 42 + 42);
    });

    test('from a stochastic one', () {
      var nextParser = FormulaParser(variables: [constantFormula]);
      var formula = nextParser.parseString('answer * 100~101');

      expect(formula.wasFailure, isFalse);
      expect(formula.isStochastic, isTrue);
      expect(() => formula.emit(), returnsNormally);
    });
  });

  test('weird variable names works', () {
    var a = FormulaParser().parseString('42', name: '😀');
    var b = FormulaParser().parseString('5', name: 'not-a-good-idea');
    var c = FormulaParser().parseString('100', name: '/terrible-idea!');

    var nextParser = FormulaParser(variables: [a, b, c]);
    var formula =
        nextParser.parseString('😀 - not-a-good-idea + /terrible-idea!');

    expect(formula.emit(), 42 - 5 + 100);
  });

  test('variable overrides its previous definition', () {
    var a = FormulaParser().parseString('42', name: 'blah');
    var b = FormulaParser().parseString('100', name: 'blah');

    var nextParser = FormulaParser(variables: [a, b]);
    var formula = nextParser.parseString('2 * blah');

    expect(formula.emit(), 200);
  });

  test('variables are case sensitive' ,  () {
    var a = FormulaParser().parseString('42', name: 'a');
    var capitalA = FormulaParser().parseString('-1', name: 'A');

    var nextParser = FormulaParser(variables: [a, capitalA]);
    var formula = nextParser.parseString('2 * a');

    expect(formula.emit(), 2 * 42);
  });

  group('invalid variable name', () {
    test('empty string', () {
      expect(() => FormulaParser().parseString('42', name: ''),
          throwsArgumentError);
    });

    test('string with whitespace', () {
      expect(() => FormulaParser().parseString('42', name: 'my foo'),
          throwsArgumentError);
    });

    test('null and then used as variable', () {
      var a = FormulaParser().parseString('42');
      expect(() => FormulaParser(variables: [a]), throwsArgumentError);
    });
  });
}
