import 'package:web_socket_channel/web_socket_channel.dart';

/// Implemented in `socket_html.dart` and `socket_io.dart`
WebSocketChannel initializeWebSocketChannel(Uri uri, [Duration? timeout]) {
  throw UnsupportedError(
    'Cannot create a web socket channel without dart:html or dart:io',
  );
}
