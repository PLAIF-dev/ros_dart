// Copyright (c) 2019 Conrad Heidebrecht.

// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ros_dart/core/socket.dart'
    if (dart.library.html) 'socket_html.dart'
    if (dart.library.io) 'socket_io.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection status. It is used before sending request to `ROS`.
enum RosStatus {
  /// default
  none,

  ///
  connecting,

  ///
  connected,

  ///
  closed,

  ///
  errored,
}

/// It is used to let `ROS` know status.
enum RosStatusLevel {
  ///
  none,

  ///
  error,

  ///
  warning,

  ///
  info,
}

/// This custom exception is only used when checking connection in [Ros.send()]
class RosNotConnectedException implements Exception {}

/// This holds status and info of connection between `Client` and `ROS`
class Ros {
  /// common URI example
  /// ```dart
  /// Uri.parse()
  /// ```
  Ros({required Uri uri})
      : _uri = uri,
        _statusController = StreamController<RosStatus>.broadcast();

  /// Other objects or view can utilize this object to act depending on status
  final StreamController<RosStatus> _statusController;

  /// ROSBridge server URI
  /// Use [Uri.parse] to create URI object
  /// ```dart
  /// Uri.parse('ws://172.0.0.1:9090')
  /// ```
  ///
  /// It can be changed in [connect]
  Uri _uri;

  /// ROSBridge server URI
  /// ```dart
  /// Uri.parse('ws://172.0.0.1:9090')
  /// ```
  Uri get uri => _uri;

  /// the number of subscribers
  int _subscribers = 0;

  /// the number of advertisers
  int _advertisers = 0;

  /// the number of publishers
  int _publishers = 0;

  /// the number of callers
  int _serviceCallers = 0;

  /// same as how many connections have been made
  int get ids => _subscribers + _advertisers + _publishers + _serviceCallers;

  /// ROSBridge use `WebSocket` to make bridge between `Client` and `ROS`
  late final WebSocketChannel _channel;

  /// Subscription to verify connection was successful or not
  late final StreamSubscription<Map<String, dynamic>> _channelListener;

  /// JSON broadcast websocket stream
  late final Stream<Map<String, dynamic>> stream;

  /// declarative name for current status
  Stream<RosStatus> get statusStream => _statusController.stream;

  /// it can be used when live-updating is not necessary
  RosStatus status = RosStatus.none;

  /// This method must be used before starting communication with `ROS`
  /// [_uri] can be updated in this method
  void connect({Uri? newUri}) {
    _uri = newUri ?? _uri;
    try {
      _channel = initializeWebSocketChannel(_uri);
      stream = _channel.stream.asBroadcastStream().map(
            (raw) => json.decode(raw.toString()) as Map<String, dynamic>,
          );
      status = RosStatus.connected;
      _statusController.add(status);
      _channelListener = stream.listen(
        (data) {
          if (status != RosStatus.connected) {
            status = RosStatus.connected;
            _statusController.add(status);
          }
        },
        onDone: () {
          status = RosStatus.closed;
          _statusController.add(status);
        },
        onError: (_) {
          status = RosStatus.errored;
          _statusController.add(status);
        },
      );
    } on WebSocketException {
      status = RosStatus.errored;
      _statusController.add(status);
    }
  }

  /// Close channel from ROS
  Future<void> close([int? code, String? reason]) async {
    await _channelListener.cancel();
    await _channel.sink.close(code, reason);

    _statusController.add(RosStatus.closed);
    status = RosStatus.closed;
  }

  /// Authentication request(JSON String) to websocket endpoint
  void authenticate({
    required String mac,
    required String client,
    required String dest,
    required String rand,
    required DateTime t,
    required String level,
    required DateTime end,
  }) {
    final value = {
      'mac': mac,
      'client': client,
      'dest': dest,
      'rand': rand,
      't': t.millisecondsSinceEpoch,
      'level': level,
      'end': end.millisecondsSinceEpoch,
    };

    send(json.encode(value));
  }

  /// Status update request(JSON String) to websocket endpoint
  /// [id] is the optional operation ID to change status level on
  void setStatusLevel({
    required RosStatusLevel level,
    int? id,
  }) {
    final value = {
      'op': 'set_level',
      'level': level.name,
      'id': id,
    };

    send(json.encode(value));
  }

  /// Actual websocket communication
  void send(String message) {
    if (status != RosStatus.connected) throw RosNotConnectedException();
    _channel.sink.add(message);
  }

  /// Generate subscriber name
  String requestSubscriber(String name) {
    _subscribers++;
    return 'subscribe:$name:$ids';
  }

  /// Generate advertiser name
  String requestAdvertiser(String name) {
    _advertisers++;
    return 'advertise:$name:$ids';
  }

  /// Generate publisher name
  String requestPublisher(String name) {
    _publishers++;
    return 'publish:$name:$ids';
  }

  /// Generate service caller name
  String requestServiceCaller(String name) {
    _serviceCallers++;
    return 'call_service:$name:$ids';
  }

  @override
  bool operator ==(Object other) {
    return other is Ros &&
        other._uri == _uri &&
        other._subscribers == _subscribers &&
        other._advertisers == _advertisers &&
        other._publishers == _publishers &&
        other._channel == _channel &&
        other._channelListener == _channelListener &&
        other.stream == stream &&
        other._statusController == _statusController &&
        other.status == status;
  }

  @override
  int get hashCode =>
      _uri.hashCode +
      _subscribers.hashCode +
      _advertisers.hashCode +
      _publishers.hashCode +
      _channel.hashCode +
      _channelListener.hashCode +
      stream.hashCode +
      _statusController.hashCode +
      status.hashCode;
}
