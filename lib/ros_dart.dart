/// ROS implementation directly porting rosbridge_client_dot_net package to dart
library ros_dart;

import 'dart:async'
    show Completer, Stream, StreamController, StreamSubscription;
import 'dart:convert' show json;

import 'package:ros_dart/src/socket/socket.dart'
    if (dart.library.html) 'package:ros_dart/src/socket/socket_html.dart'
    if (dart.library.io) 'package:ros_dart/src/socket/socket_io.dart';

import 'package:web_socket_channel/web_socket_channel.dart'
    show WebSocketChannel;

part 'src/param.dart';
part 'src/request.dart';
part 'src/ros.dart';
part 'src/ros_websocket.dart';
part 'src/ros_websocket_exception.dart';
part 'src/service.dart';
part 'src/topic.dart';
