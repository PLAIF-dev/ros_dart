// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:convert';

import 'package:ros_dart/core/request.dart';
import 'package:ros_dart/core/ros.dart';

/// service가 advertising을 할 때 request를 처리하는 함수
typedef SubscribeHandler = Future<void> Function(Map<String, dynamic> args);

/// 압축 확장자 범위를 좁히는 역할로 사용함
enum RosCompression {
  ///
  none,

  ///
  png,

  ///
  cbor,
}

/// ROS topic을 단지 wrapping한 것 뿐임
class RosTopic {
  ///
  RosTopic({
    required this.ros,
    required this.name,
    required this.type,
    this.compression = RosCompression.none,
    this.throttleRate = 0,
    this.latch = false,
    this.queueSize = 100,
    this.queueLength = 0,
    this.reconnectOnClose = true,
  }) : assert(throttleRate >= 0, 'throttleRate must be positive');

  final Ros ros;

  final String name;

  final String type;

  Stream<Map<String, dynamic>>? subscription;

  /// [ros] 가 제공하는 subscription ID
  String? subscribeId;

  /// [ros] 가 제공하는 advertiser ID
  String? advertiseId;

  /// [ros] 가 제공하는 publisher ID
  late String publishId;

  /// 'png'나 'cbor' 등의 압축타입. 기본은 [RosCompression.none]
  final RosCompression compression;

  final int throttleRate;

  final bool latch;

  final int queueSize;

  final int queueLength;

  final bool reconnectOnClose;

  /// topic이 현재 advertising 하고 있는지 확인
  bool get isAdvertised => advertiseId != null;

  Future<void> subscribe(SubscribeHandler handler) async {
    if (subscribeId == null) {
      subscription = ros.stream;
      subscribeId = ros.requestSubscriber(name);
      await safeSend(
        RosRequest(
          op: 'subscribe',
          id: subscribeId,
          type: type,
          topic: name,
          compression: compression.name,
          throttleRate: throttleRate,
          queueLength: queueLength,
        ),
      );
      subscription!.listen(
        (message) async {
          if (message['topic'] != name) {
            return;
          }
          await handler(message['msg'] as Map<String, dynamic>);
        },
      );
    }
  }

  /// 구독 취소 request 보낸 후 value 값 초기화
  Future<void> unsubscribe() async {
    if (subscribeId != null) {
      await safeSend(
        RosRequest(
          op: 'unsubscribe',
          id: subscribeId,
          topic: name,
        ),
      );
      subscription = null;
      subscribeId = null;
    }
  }

  /// [message] 를 topic에 전달
  Future<void> publish(Map<String, dynamic> message) async {
    await advertise();
    publishId = ros.requestPublisher(name);
    await safeSend(
      RosRequest(
        op: 'publish',
        topic: name,
        id: publishId,
        msg: message,
        latch: latch,
      ),
    );
  }

  /// advertising 시작
  Future<void> advertise() async {
    if (!isAdvertised) {
      advertiseId = ros.requestAdvertiser(name);
      await safeSend(
        RosRequest(
          op: 'advertise',
          id: advertiseId,
          type: type,
          topic: name,
          latch: latch,
          queueSize: queueSize,
        ),
      );

      await watchForClose();
    }
  }

  /// advertising 종료
  Future<void> unadvertise() async {
    if (isAdvertised) {
      await safeSend(
        RosRequest(
          op: 'unadvertise',
          id: advertiseId,
          topic: name,
        ),
      );
      advertiseId = null;
    }
  }

  Future<void> watchForClose() async {
    if (!reconnectOnClose) {
      await ros.statusStream.firstWhere((s) => s == RosStatus.closed);
      advertiseId = null;
    }
  }

  /// 안전한 연결을 위해 만약 연결되지 않았거나,
  /// [reconnectOnClose]이 true라면, ROS 재연결 까지 기다리고, 다시 메시지 보냄
  Future<void> safeSend(RosRequest request) async {
    ros.send(request.encode());
    if (reconnectOnClose && ros.status != RosStatus.connected) {
      await ros.statusStream.firstWhere((s) => s == RosStatus.connected);
      ros.send(request.encode());
    }
  }
}
