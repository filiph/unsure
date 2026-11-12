import 'package:jaspr/client.dart';
import 'package:logging/logging.dart';

import 'components/calculator.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}] ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('StackTrace: ${record.stackTrace}');
    }
  });

  final log = Logger('Main');
  log.info('Initializing Jaspr application...');

  runApp(
    const Calculator(),
    attachTo: '#calculator',
  );
}
