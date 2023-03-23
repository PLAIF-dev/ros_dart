// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ros_dart/core/socket.dart'
    if (dart.library.html) 'socket_html.dart'
    if (dart.library.io) 'socket_io.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

/// 연결 상태
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

/// 토픽 전달 상태
enum TopicStatus {
  ///
  subscribed,

  ///
  unsubscribed,

  ///
  published,

  ///
  advertised,

  ///
  unadvertised,
}

/// Status Level을 ROS에 알리기 위한 상태
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

/// 연결되지 않았을 때 message 보내거나 하는 상황에 발생하는 예외
class RosNotConnectedException implements Exception {}

/// ROS Node로부터 나오고 들어가는 모든 데이터를 관리하는 클래스
/// ROS 상태와 Node와 연결에 대한 핵심 정보를 관리함
class Ros {
  /// [_statusController]를 초기화
  /// ROS Node의 [uri]는 이 시점에 추가될 수 있음
  Ros({required this.uri}) {
    _statusController = StreamController<RosStatus>.broadcast();
  }

  /// rosbridge server를 구동하는 ROS Node의 uri
  Uri uri;

  /// 연결된 subscriber의 수
  int subscribers = 0;

  /// 연결된 advertiser의 수
  int advertisers = 0;

  /// 연결된 publisher의 수
  int publishers = 0;

  /// service를 호출한 caller의 수
  int serviceCallers = 0;

  /// !생성된 값이 trick 이기 때문에 주의
  int get ids => subscribers + advertisers + publishers + serviceCallers;

  /// ROS Node와 통신하기 위한 websocket connection
  late WebSocketChannel _channel;

  /// websocket stream 구독
  late StreamSubscription<Map<String, dynamic>> _channelListener;

  /// JSON broadcast websocket stream
  late Stream<Map<String, dynamic>> stream;

  /// 연결 상태에 따라 구독자들을 업데이트하기 위한 컨트롤러
  late StreamController<RosStatus> _statusController;

  /// 연결 상태 변경에 대한 stream
  Stream<RosStatus> get statusStream => _statusController.stream;

  /// live update 가 필요하지 않을 때 사용할 수 있음
  RosStatus status = RosStatus.none;

  /// [uri] 업데이트 될 수 있음
  void connect({Uri? newUri}) {
    uri = newUri ?? uri;
    try {
      _channel = initializeWebSocketChannel(uri);
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

  /// exit [code] 와 [reason]은 상황에 따라 제공될 수 있음
  Future<void> dispose([int? code, String? reason]) async {
    await _channelListener.cancel();
    await _channel.sink.close(code, reason);

    _statusController.add(RosStatus.closed);
    status = RosStatus.closed;
  }

  /// websocket endpoint에 연결 검증 request(JSON String)
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

  /// websocket endpoint에 상태 업데이트 request(JSON String)
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

    send(value.toString());
  }

  /// ROS Node로 [message] 전달
  void send(String message) {
    if (status != RosStatus.connected) throw RosNotConnectedException();
    _channel.sink.add(message);
  }

  /// Request a subscription ID.
  String requestSubscriber(String name) {
    subscribers++;
    return 'subscribe:$name:$ids';
  }

  /// Request an advertiser ID.
  String requestAdvertiser(String name) {
    advertisers++;
    return 'advertise:$name:$ids';
  }

  /// Request a publisher ID.
  String requestPublisher(String name) {
    publishers++;
    return 'publish:$name:$ids';
  }

  /// Request a service caller ID.
  String requestServiceCaller(String name) {
    serviceCallers++;
    return 'call_service:$name:$ids';
  }

  @override
  bool operator ==(Object other) {
    return other is Ros &&
        other.uri == uri &&
        other.subscribers == subscribers &&
        other.advertisers == advertisers &&
        other.publishers == publishers &&
        other._channel == _channel &&
        other._channelListener == _channelListener &&
        other.stream == stream &&
        other._statusController == _statusController &&
        other.status == status;
  }

  @override
  int get hashCode =>
      uri.hashCode +
      subscribers.hashCode +
      advertisers.hashCode +
      publishers.hashCode +
      _channel.hashCode +
      _channelListener.hashCode +
      stream.hashCode +
      _statusController.hashCode +
      status.hashCode;
}
