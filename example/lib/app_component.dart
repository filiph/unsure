import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:dorker/dorker.dart';
import 'package:unsure_angular_dart/unsure_result_message.dart';

@Component(
  selector: 'unsure-calc',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    NgIf,
    NgClass,
    formDirectives,
  ],
)
class AppComponent implements OnInit {
  String formula = '100 / 4~6';

  DorkerWorker _worker;

  String simpleResult = '';

  String histogram = '';

  bool showHistogram = true;

  bool showPercentiles = false;

  bool isComputing = false;

  String note = 'Write a formula and hit Enter, or press =.';

  String percentiles = '';

  void add(String s) => formula = '$formula$s';

  void delete() {
    if (formula.isEmpty) return;
    formula = formula.substring(0, formula.length - 1);
    while (formula.endsWith(' ')) {
      formula = formula.substring(0, formula.length - 1);
    }
  }

  @override
  void ngOnInit() {
    _worker = DorkerWorker(Worker('worker.dart.js'));
    _worker.onMessage.listen(_receiveResult);
  }

  void startComputation() {
    _worker.postMessage.add(formula);
    isComputing = true;
    note = 'Please wait...';
    histogram = '';
    percentiles = '';
  }

  void _receiveResult(Object data) {
    var result = BaseResultMessage.fromData(data);
    simpleResult = result.simpleResult;
    isComputing = false;
    if (result is FailureResultMessage) {
      note = 'There was a problem with your formula ${result.message}.';
      histogram = '';
      percentiles = '';
    } else if (result is StochasticResultMessage) {
      histogram = result.histogram;
      percentiles = result.percentiles;
      note = '';
    } else if (result is NonStochasticResultMessage) {
      note = 'Try to make some inputs a bit more unsure, '
          'such as writing 4~6 instead of 4.';
      histogram = '';
      percentiles = '';
    } else {
      throw ArgumentError('$result is not one of the messages we expect');
    }
  }
}
