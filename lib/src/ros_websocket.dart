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
  late final WebSocketChannel _channel;

  @override
  Uri get uri => _uri;

  @override
  Stream<dynamic> get stream => _channel.stream;

  @override
  Future<void> connect([Duration? timeout]) async {
    final completer = Completer<void>();
    final localTimeout = timeout ?? const Duration(milliseconds: 2000);
    try {
      _channel = initializeWebSocketChannel(uri, localTimeout);

      await Future.delayed(localTimeout, completer.complete);

      return completer.future;
    } catch (e) {
      throw const RosWebsocketException();
    }
  }

  @override
  Future<void> close([int? code, String? reason]) {
    return _channel.sink.close(code, reason);
  }

  @override
  void send(dynamic message) {
    _channel.sink.add(message);
  }
}
