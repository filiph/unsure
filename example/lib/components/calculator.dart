import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

import '../models/result_message.dart';
import 'calculation_runner.dart';

class Calculator extends StatefulComponent {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  static final _logger = Logger('Calculator');
  late final CalculationRunner _runner;

  String simpleResult = '';
  String histogram = '';
  bool showHistogram = true;
  bool showPercentiles = false;
  bool isComputing = false;
  String note = 'Write a formula and hit Enter, or press =.';
  String percentiles = '';
  String formulaString = '100 / 4~6';

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing Calculator component');
    _runner = createRunner();
    _runner.onMessage = _receiveResult;
    final hash = _runner.getInitialHash();
    if (hash != null) {
      _extractHashIntoFormula(hash);
    }
  }

  void _extractHashIntoFormula(String urlHash) {
    _logger.fine('Checking URL hash: "$urlHash"');
    final fIndex = urlHash.indexOf('f=');
    if (fIndex == -1) return;

    final startIndex = fIndex + 'f='.length;
    if (startIndex >= urlHash.length) return;

    var endIndex = urlHash.length;
    final andIndex = urlHash.indexOf('&', startIndex);
    if (andIndex != -1) {
      endIndex = andIndex;
    }

    final urlEncodedFormula = urlHash.substring(startIndex, endIndex);
    if (urlEncodedFormula.isEmpty) return;

    final formula = Uri.decodeComponent(urlEncodedFormula);
    _logger.info('Extracted formula from URL hash: "$formula"');
    formulaString = formula;
    startComputation(formula);
  }

  void add(String s) {
    _logger.fine('Keypad append: "$s"');
    setState(() {
      formulaString = '$formulaString$s';
    });
  }

  void delete() {
    _logger.fine('Keypad delete');
    setState(() {
      if (formulaString.isEmpty) return;
      formulaString = formulaString.substring(0, formulaString.length - 1);
      while (formulaString.endsWith(' ')) {
        formulaString = formulaString.substring(0, formulaString.length - 1);
      }
    });
  }

  void startComputation(String formula) {
    _logger.info('Starting computation for formula: "$formula"');
    setState(() {
      isComputing = true;
      note = 'Please wait...';
      histogram = '';
      percentiles = '';
    });
    _runner.compute(formula);
  }

  void _receiveResult(String data) {
    _logger.info('Received result data from runner');
    try {
      final result = BaseResultMessage.fromData(data);
      setState(() {
        simpleResult = result.simpleResult;
        isComputing = false;
        switch (result) {
          case FailureResultMessage(:final message):
            _logger.warning('Formula computation failed: $message');
            note = 'There was a problem with your formula $message.';
            histogram = '';
            percentiles = '';
          case InvalidResultMessage():
            _logger.warning('Computation produced invalid result');
            note =
                "Most or all of the results of this computation were invalid values. "
                "It doesn't make sense to run statistics on this formula.";
            histogram = '';
            percentiles = '';
          case StochasticResultMessage(:final histogram, :final percentiles):
            _logger.info(
                'Stochastic computation succeeded: ${result.simpleResult}');
            this.histogram = histogram;
            this.percentiles = percentiles;
            note = '';
          case NonStochasticResultMessage():
            _logger.info(
                'Non-stochastic computation succeeded: ${result.simpleResult}');
            note =
                'Try to make some inputs a bit more unsure, such as writing 4~6 instead of 4.';
            histogram = '';
            percentiles = '';
        }
      });
    } catch (e, stack) {
      _logger.severe('Failed to parse result message: $e', e, stack);
      setState(() {
        isComputing = false;
        note = 'Error processing computation response.';
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'unsure-calc', [
      form(
        events: {
          'submit': (dynamic event) {
            startComputation(formulaString);
          },
        },
        [
          input(
            id: 'formula-input',
            type: InputType.text,
            value: formulaString,
            disabled: isComputing,
            attributes: {
              'aria-label': 'Formula to compute',
              'size': '16',
            },
            onInput: (dynamic val) {
              formulaString = '$val';
            },
            events: {
              'keydown': (dynamic event) {
                try {
                  if (event.key == 'Enter' || event.keyCode == 13) {
                    startComputation(formulaString);
                  }
                } catch (_) {}
              },
            },
          ),
        ],
      ),
      div(classes: 'keypad-and-results', [
        div(classes: 'keypad', [
          table([
            tr([
              td([
                button(
                  onClick: isComputing ? null : () => add('7'),
                  disabled: isComputing,
                  [Component.text('7')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('8'),
                  disabled: isComputing,
                  [Component.text('8')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('9'),
                  disabled: isComputing,
                  [Component.text('9')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('/'),
                  disabled: isComputing,
                  attributes: {'aria-label': 'Divide (/)'},
                  [Component.text('/')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => delete(),
                  disabled: isComputing,
                  attributes: {'aria-label': 'Delete'},
                  [Component.text('⌫')],
                ),
              ]),
            ]),
            tr([
              td([
                button(
                  onClick: isComputing ? null : () => add('4'),
                  disabled: isComputing,
                  [Component.text('4')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('5'),
                  disabled: isComputing,
                  [Component.text('5')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('6'),
                  disabled: isComputing,
                  [Component.text('6')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('x'),
                  disabled: isComputing,
                  attributes: {'aria-label': 'Multiply (x)'},
                  [Component.text('x')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('~'),
                  disabled: isComputing,
                  attributes: {'aria-label': 'Range operator (~)'},
                  [Component.text('~')],
                ),
              ]),
            ]),
            tr([
              td([
                button(
                  onClick: isComputing ? null : () => add('1'),
                  disabled: isComputing,
                  [Component.text('1')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('2'),
                  disabled: isComputing,
                  [Component.text('2')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('3'),
                  disabled: isComputing,
                  [Component.text('3')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('-'),
                  disabled: isComputing,
                  attributes: {'aria-label': 'Subtract (-)'},
                  [Component.text('-')],
                ),
              ]),
              td([]),
            ]),
            tr([
              td([
                button(
                  onClick: isComputing ? null : () => add('0'),
                  disabled: isComputing,
                  [Component.text('0')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing ? null : () => add('.'),
                  disabled: isComputing,
                  [Component.text('.')],
                ),
              ]),
              td([]),
              td([
                button(
                  onClick: isComputing ? null : () => add('+'),
                  disabled: isComputing,
                  attributes: {'aria-label': 'Add (+)'},
                  [Component.text('+')],
                ),
              ]),
              td([
                button(
                  onClick: isComputing
                      ? null
                      : () => startComputation(formulaString),
                  disabled: isComputing,
                  [Component.text('=')],
                ),
              ]),
            ]),
          ]),
        ]),
        div(
          classes: 'calculator-output${isComputing ? ' grayout' : ''}',
          [
            if (isComputing)
              img(
                classes: 'loader',
                src: 'images/three-dots.svg',
                alt: 'Loading...',
              ),
            if (simpleResult.isNotEmpty && !isComputing)
              p(classes: 'result', [Component.text(simpleResult)]),
            if (note.isNotEmpty) p(classes: 'note', [Component.text(note)]),
            if (histogram.isNotEmpty)
              div([
                p([
                  a(
                    href: 'javascript:void(0)',
                    onClick: () =>
                        setState(() => showHistogram = !showHistogram),
                    [
                      Component.text('Histogram ('),
                      span([Component.text(showHistogram ? 'hide' : 'show')]),
                      Component.text(')'),
                    ],
                  ),
                ]),
                if (showHistogram)
                  pre(classes: 'histogram', [Component.text(histogram)]),
              ]),
            if (percentiles.isNotEmpty)
              div([
                p([
                  a(
                    href: 'javascript:void(0)',
                    onClick: () =>
                        setState(() => showPercentiles = !showPercentiles),
                    [
                      Component.text('Percentiles ('),
                      span([Component.text(showPercentiles ? 'hide' : 'show')]),
                      Component.text(')'),
                    ],
                  ),
                ]),
                if (showPercentiles)
                  pre(classes: 'percentiles', [Component.text(percentiles)]),
              ]),
          ],
        ),
      ]),
    ]);
  }
}
