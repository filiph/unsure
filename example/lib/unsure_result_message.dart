import 'dart:convert';

abstract class BaseResultMessage {
  String get simpleResult;

  String toData();

  static BaseResultMessage fromData(String message) {
    var object = Map<String, String>.from(json.decode(message));
    switch (object['type']) {
      case NonStochasticResultMessage.typeName:
        return NonStochasticResultMessage.fromData(object);
      case StochasticResultMessage.typeName:
        return StochasticResultMessage.fromData(object);
      case FailureResultMessage.typeName:
        return FailureResultMessage.fromData(object);
      default:
        throw ArgumentError('$object');
    }
  }
}

class FailureResultMessage extends BaseResultMessage {
  static const typeName = 'error';

  final String message;

  FailureResultMessage(this.message);

  FailureResultMessage.fromData(Map<String, String> object)
      : message = object['message'];

  @override
  String get simpleResult => 'ERROR';

  @override
  String toData() {
    var object = {
      'type': typeName,
      'simpleResult': simpleResult,
      'message': message,
    };
    return json.encode(object);
  }
}

class NonStochasticResultMessage extends BaseResultMessage {
  static const typeName = 'non-stochastic';

  @override
  final String simpleResult;

  NonStochasticResultMessage(this.simpleResult);

  NonStochasticResultMessage.fromData(Map<String, String> object)
      : simpleResult = object['simpleResult'];

  @override
  String toData() {
    var object = {
      'type': typeName,
      'simpleResult': simpleResult,
    };
    return json.encode(object);
  }
}

class StochasticResultMessage extends BaseResultMessage {
  static const typeName = 'stochastic';

  @override
  final String simpleResult;

  final String histogram;

  final String percentiles;

  StochasticResultMessage(this.simpleResult, this.histogram, this.percentiles);

  StochasticResultMessage.fromData(Map<String, String> object)
      : simpleResult = object['simpleResult'],
        histogram = object['histogram'],
        percentiles = object['percentiles'];

  @override
  String toData() {
    var object = {
      'type': typeName,
      'simpleResult': simpleResult,
      'histogram': histogram,
      'percentiles': percentiles,
    };
    return json.encode(object);
  }
}
