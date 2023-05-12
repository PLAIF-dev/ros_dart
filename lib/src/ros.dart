// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

part of '../ros_dart.dart';

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

/// This custom exception is only used when checking connection in [Ros.send()]
class RosNotConnectedException implements Exception {}

/// This holds status and info of connection between `Client` and `ROS`
class Ros {
  /// common URI example
  /// ```dart
  /// Uri.parse()
  /// ```
  Ros({required Uri uri, RosWebsocket? socket})
      : _statusController = StreamController<RosStatus>.broadcast(),
        _socket = socket ?? RosWebsocketImpl(uri);

  /// Other objects or view can utilize this object to act depending on status
  final StreamController<RosStatus> _statusController;

  /// the number of subscribers
  int _subscribers = 0;

  /// the number of advertisers
  int _advertisers = 0;

  /// the number of publishers
  int _publishers = 0;

  /// the number of callers
  int _serviceCallers = 0;

  /// ROSBridge server URI
  Uri get uri => _socket.uri;

  /// same as how many connections have been made
  int get ids => _subscribers + _advertisers + _publishers + _serviceCallers;

  /// ROSBridge use `WebSocket` to make bridge between `Client` and `ROS`
  final RosWebsocket _socket;

  /// Subscription to verify connection was successful or not
  StreamSubscription<Map<String, dynamic>>? _channelListener;

  /// JSON broadcast websocket stream
  late final Stream<Map<String, dynamic>> stream;

  /// declarative name for current status
  Stream<RosStatus> get statusStream => _statusController.stream;

  /// it can be used when live-updating is not necessary
  RosStatus status = RosStatus.none;

  /// This method must be used before starting communication with `ROS`
  Future<void> connect([Duration? timeout]) async {
    try {
      await _socket.connect(timeout).catchError(_handleConnectError);

      stream = _socket.stream.asBroadcastStream().map(
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
    } on RosWebsocketException {
      rethrow;
    }
  }

  /// Close channel from ROS
  Future<void> close([int? code, String? reason]) async {
    await _channelListener?.cancel();
    await _socket.close(code, reason);

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

  /// Actual websocket communication
  void send(String message) {
    if (status != RosStatus.connected) throw RosNotConnectedException();
    _socket.send(message);
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

  Future<void> _handleConnectError(Object? _) {
    throw const RosWebsocketException();
  }

  @override
  bool operator ==(Object other) {
    return other is Ros &&
        other._subscribers == _subscribers &&
        other._advertisers == _advertisers &&
        other._publishers == _publishers &&
        other._socket == _socket &&
        other._channelListener == _channelListener &&
        other.stream == stream &&
        other._statusController == _statusController &&
        other.status == status;
  }

  @override
  int get hashCode =>
      _subscribers.hashCode +
      _advertisers.hashCode +
      _publishers.hashCode +
      _socket.hashCode +
      _channelListener.hashCode +
      stream.hashCode +
      _statusController.hashCode +
      status.hashCode;
}
