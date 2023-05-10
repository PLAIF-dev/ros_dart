import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// this is called in `socket.dart`
WebSocketChannel initializeWebSocketChannel(Uri uri, [Duration? timeout]) {
  return HtmlWebSocketChannel.connect(uri);
}
