import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// this is called in `socket.dart`
WebSocketChannel initializeWebSocketChannel(String url) {
  return IOWebSocketChannel.connect(url);
}
