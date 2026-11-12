import 'calculation_runner_interface.dart';

CalculationRunner createRunner() => _VmCalculationRunner();

class _VmCalculationRunner implements CalculationRunner {
  @override
  void Function(String message)? onMessage;

  @override
  void compute(String formula) {}

  @override
  String? getInitialHash() => null;
}
