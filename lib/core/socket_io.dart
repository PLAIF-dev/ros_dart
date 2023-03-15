// Copyright (c) 2019 Conrad Heidebrecht.

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// this is called in `socket.dart`
WebSocketChannel initializeWebSocketChannel(Uri uri) {
  return IOWebSocketChannel.connect(uri);
}
