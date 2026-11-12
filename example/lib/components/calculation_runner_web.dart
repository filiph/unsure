import 'dart:js_interop';
import 'package:logging/logging.dart';
import 'package:unsure_example/models/result_message.dart';
import 'package:web/web.dart' as web;
import 'calculation_runner_interface.dart';

CalculationRunner createRunner() => _WebCalculationRunner();

class _WebCalculationRunner implements CalculationRunner {
  static final _logger = Logger('CalculationRunnerWeb');
  late final web.Worker _worker;
  bool _isWorkerReady = false;
  String? _pendingFormula;

  @override
  void Function(String message)? onMessage;

  _WebCalculationRunner() {
    _logger.info('Initializing WebCalculationRunner with worker.dart.js');
    try {
      _worker = web.Worker('worker.dart.js'.toJS);

      _worker.onmessage = (web.MessageEvent event) {
        final rawData = event.data;
        final data =
            (rawData as JSString?)?.toDart ?? (rawData?.toString() ?? '');
        _logger.fine('Received message from worker: $data');

        if (data == '{"type":"ready"}' || data == 'ready') {
          _logger.info('Worker reported READY');
          _isWorkerReady = true;
          if (_pendingFormula != null) {
            final formula = _pendingFormula!;
            _pendingFormula = null;
            _logger.info('Sending pending formula to ready worker: $formula');
            _worker.postMessage(formula.toJS);
          }
          return;
        }

        onMessage?.call(data);
      }.toJS;

      _worker.onerror = (web.Event event) {
        String errorDetails;
        try {
          final errorEvent = event as web.ErrorEvent;
          errorDetails =
              '${errorEvent.message} (${errorEvent.filename}:${errorEvent.lineno}:${errorEvent.colno})';
        } catch (_) {
          errorDetails = event.type;
        }
        final errorMsg = 'Worker error: $errorDetails';
        _logger.severe(errorMsg);
        onMessage?.call(FailureResultMessage(errorMsg).toData());
      }.toJS;

      _worker.onmessageerror = (web.MessageEvent event) {
        final errorMsg = 'Worker message error: ${event.data}';
        _logger.severe(errorMsg);
        onMessage?.call(FailureResultMessage(errorMsg).toData());
      }.toJS;
    } catch (e, stack) {
      _logger.severe('Failed to create web Worker: $e', e, stack);
    }
  }

  @override
  void compute(String formula) {
    _logger.info(
        'compute() requested for "$formula" (isWorkerReady=$_isWorkerReady)');
    if (!_isWorkerReady) {
      _pendingFormula = formula;
      try {
        _worker.postMessage(formula.toJS);
      } catch (e) {
        _logger.warning('Could not immediately post message to worker: $e');
      }
      return;
    }
    _worker.postMessage(formula.toJS);
  }

  @override
  String? getInitialHash() {
    return web.window.location.hash;
  }
}
