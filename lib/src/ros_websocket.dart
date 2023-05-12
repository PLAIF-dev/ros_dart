part of '../ros_dart.dart';

/// interface for websocket for `ROS`
/// it is just wrapper for Websocket and it is introduced to solve
/// problems from external websocket library that devs cannot catch
/// SocketException when client cannot find websocket server
abstract class RosWebsocket {
  /// ROSBridge server URI
  /// Use [Uri.parse] to create URI object
  /// ```dart
  /// Uri.parse('ws://172.0.0.1:9090')
  /// ```
  ///
  /// It can be changed in [connect]
  Uri get uri;

  ///
  Stream<dynamic> get stream;

  ///
  Future<void> connect([Duration? timeout]);

  ///
  Future<void> close([int? code, String? reason]);

  ///
  void send(dynamic message);
}

/// Implementation of [RosWebsocket]
class RosWebsocketImpl implements RosWebsocket {
  /// [uri] is needed to connect to websocket server
  RosWebsocketImpl(this._uri);

  final Uri _uri;
  WebSocket? _socket;

  @override
  Uri get uri => _uri;

  @override
  Stream<dynamic> get stream => _socket ?? const Stream.empty();

  @override
  Future<void> connect([Duration? timeout]) async {
    try {
      _socket = await WebSocket.connect(uri.toString());
    } on SocketException {
      rethrow;
    }
  }

  @override
  Future<void> close([int? code, String? reason]) async {
    return _socket?.close(code, reason);
  }

  @override
  void send(dynamic message) {
    if (_socket == null) {
      throw const RosWebsocketException();
    }
    _socket!.add(message);
  }
}
