import 'package:web_socket_channel/io.dart' show IOWebSocketChannel;
import 'package:web_socket_channel/web_socket_channel.dart'
    show WebSocketChannel;

/// this is called in `socket.dart`
WebSocketChannel initializeWebSocketChannel(Uri uri, [Duration? timeout]) {
  return IOWebSocketChannel.connect(uri);
}
