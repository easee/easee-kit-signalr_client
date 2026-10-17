import 'dart:async';

import 'package:logging/logging.dart';
import 'package:signalr_netcore/itransport.dart';
import 'package:signalr_netcore/web_socket_transport.dart';
import 'package:test/test.dart';

void main() {
  group("WebSocketTransport", () {
    test("logs warning when connection fails", () async {
      // Set up logging to capture warning
      hierarchicalLoggingEnabled = true;
      final logger = Logger("TestLogger");
      logger.level = Level.ALL;
      final warningCompleter = Completer<LogRecord>();
      logger.onRecord.listen((record) {
        if (record.level == Level.WARNING &&
            record.message.contains("WebSocket failed to connect") &&
            !warningCompleter.isCompleted) {
          warningCompleter.complete(record);
        }
      });

      // Create transport and try to connect to invalid host
      final transport = WebSocketTransport(null, logger, false);
      transport.onClose = ({Exception? error}) {};

      // Attempt connection to invalid host
      try {
        await transport
            .connect("http://nonexistent.invalid", TransferFormat.Text)
            .timeout(Duration(seconds: 5));
      } catch (e) {
        // Connection should fail, which is expected
      }

      // Wait for the warning log record
      final warningRecord =
          await warningCompleter.future.timeout(const Duration(seconds: 10));

      // Verify the warning message
      expect(warningRecord.message, contains("WebSocket failed to connect"));
    });
  });
}
