part of '../ros_dart.dart';

/// callback when advertising service
typedef SubscribeHandler = Future<void> Function(Map<String, dynamic> args);

/// Compression extension
enum RosCompression {
  ///
  none,

  ///
  png,

  ///
  cbor,
}

/// ROS Topic wrapper
class RosTopic {
  /// ROS Topic wrapper
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

  /// [Ros] object
  final Ros ros;

  /// Topic name
  ///
  /// ex) /turtle1/cmd_vel
  final String name;

  /// Topic type
  ///
  /// ex) /geometry_msgs/Twist
  final String type;

  ///
  Stream<Map<String, dynamic>>? subscription;

  /// id of subscriber
  String? subscribeId;

  /// id of advertiser
  String? advertiseId;

  /// id of publisher
  late String publishId;

  /// compression type such as 'png' or 'cbor'. default is [RosCompression.none]
  final RosCompression compression;

  ///
  final bool reconnectOnClose;

  /// true when topic latches in publishing
  final bool latch;

  /// rate to pass between message by message
  final int throttleRate;

  /// queue length from ROSBridge to subscribe
  final int queueLength;

  /// queue size from ROSBridge to republish topic
  final int queueSize;

  /// true when advertised
  bool get isAdvertised => advertiseId != null;

  ///
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
          compression: compression,
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

  /// it starts advertising
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

  /// it stops advertising
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

  /// Wait for the connection to close and then reset advertising variables.
  Future<void> watchForClose() async {
    if (!reconnectOnClose) {
      await ros.statusStream.firstWhere((s) => s == RosStatus.closed);
      advertiseId = null;
    }
  }

  /// This function has more conditional logic than [Ros.send]
  Future<void> safeSend(RosRequest request) async {
    ros.send(request.encode());
    if (reconnectOnClose && ros.status != RosStatus.connected) {
      await ros.statusStream.firstWhere((s) => s == RosStatus.connected);
      ros.send(request.encode());
    }
  }
}
