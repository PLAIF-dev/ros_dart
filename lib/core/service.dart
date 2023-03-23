// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:async';
import 'dart:convert';

import 'package:ros_dart/core/request.dart';
import 'package:ros_dart/core/ros.dart';

/// 메시지 전달을 시작한다는 것을 알릴 때 RosRequest를 처리하는 함수
typedef ServiceHandler = Future<Map<String, dynamic>>? Function(
  Map<String, dynamic> args,
);

/// ROS 서비스와 상호작용하기 위한 wrapper
class RosService {
  /// default constructor
  RosService({
    required this.ros,
    required this.name,
    required this.type,
  });

  /// ROS 연결 객체
  final Ros ros;

  /// Service 이름
  final String name;

  /// 서비스 타입
  final String type;

  /// Advertising 할 때 Service 요청을 위해 구독하는 Advertiser
  Stream<Map<String, dynamic>>? _advertiser;

  /// 서비스가 현재 advertising 하고 있는지 여부
  bool get isAdvertised => _advertiser != null;

  StreamSubscription<dynamic>? listener;

  /// Request [args]를 이용하여 서비스 호출
  Future<dynamic> call(Map<String, dynamic> args) async {
    // TODO(youngmin-gwon): change to custom exception
    // if (isAdvertised) throw UnimplementedError();

    final callId = ros.requestServiceCaller(name);
    final receiver = ros.stream
        .where(
      (message) => message['id'] == callId,
    )
        .map(
      (message) {
        if (message['result'] == null) {
          // TODO(youngmin-gwon): consider whether it throws exception or empty
          throw UnimplementedError();
        }
        return json.decode(message['result'].toString());
      },
    );

    final completer = Completer<dynamic>();
    listener = receiver.listen((d) {
      completer.complete(d);
      listener!.cancel();
    });

    ros.send(
      RosRequest(
        op: 'call_service',
        id: callId,
        service: name,
        type: type,
        args: args,
      ).encode(),
    );

    return completer.future;
  }

  /// service advertise 시작
  /// [handler] callback을 이용하여 request 처리
  Future<void> advertise(ServiceHandler handler) async {
    if (isAdvertised) return;

    // advertise 한다는 request를 가장 먼저 보내야함
    final request = RosRequest(
      op: 'advertise_service',
      type: type,
      service: name,
    );
    ros.send(request.encode());

    // request 를 받아 처리하기 위해 stream, hanlder를 정의하였고
    // response를 다시 ROS Node로 전송
    _advertiser = ros.stream;
    _advertiser!.listen((message) async {
      if (message['service'] != name) return;

      final resp =
          await handler(message['args'] as Map<String, dynamic>? ?? {});
      final request = RosRequest(
        op: 'service_response',
        id: message['id'] as String? ?? '',
        service: name,
        values: resp ?? {},
        result: resp != null,
      );
      ros.send(request.encode());
    });
  }

  /// advertising 멈추기
  void unadvertise() {
    if (!isAdvertised) return;
    final request = RosRequest(
      op: 'unadvertise_service',
      service: name,
    );
    ros.send(request.encode());
    _advertiser = null;
  }
}
