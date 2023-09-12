part of '../ros_dart.dart';

/// [ROSBridge Protocol](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md)
/// 중 `Topic` 에 관련된 요청 모음
///
/// 1. advertise
/// 2. unadvertise
/// 3. publish
/// 4. subscribe
/// 5. unsubscribe
abstract class RosTopic with RosRequest {
  /// 하위 클래스를 const 로 사용하기 위해서 const constructor 정의함
  const RosTopic();

  /// [RosTopic] 을 publish 하기 전에 ROS 에 알리는 요청
  ///
  /// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#341-advertise--advertise-)
  /// 참고
  const factory RosTopic.advertise({
    required String topic,
    required String type,
    String id,
  }) = RosAdvertiseTopic._;

  /// [RosTopic] 을 publish 한 이후 ROS 에게 알리는 요청
  ///
  /// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#342-unadvertise--unadvertise-)
  /// 참고
  const factory RosTopic.unadvertise({
    required String topic,
    String id,
  }) = RosUnadvertiseTopic._;

  /// ROS 에 데이터를 보내 이를 구독하는 각 Node에 알리는 요청
  ///
  /// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#343-publish--publish-)
  /// 참고
  const factory RosTopic.publish({
    required String topic,
    required Map<String, dynamic> msg,
    String id,
  }) = RosPublishTopic._;

  /// [RosTopic] 으로 새로운 데이터가 들어오면 알려주도록 하는 요청
  ///
  /// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#344-subscribe)
  /// 참고
  const factory RosTopic.subscribe({
    required String topic,
    String id,
    String type,
    int throttleRate,
    int queueLength,
    int fragmentSize,
    Compression compression,
  }) = RosSubscribeTopic._;

  /// [RosTopic.subscribe]가 끝났음을 알리는 요청
  ///
  /// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#345-unsubscribe)
  /// 참고
  const factory RosTopic.unsubscribe({
    required String topic,
    String id,
  }) = RosUnsubscribeTopic._;
}

class RosAdvertiseTopic extends RosTopic {
  const RosAdvertiseTopic._({
    required this.topic,
    required this.type,
    this.id,
  });

  final String? id;

  final String topic;

  final String type;

  @override
  String get op => 'advertise';

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      if (id != null) 'id': id,
      'topic': topic,
      'type': type,
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return true;
  }

  @override
  bool get hasResponse => false;
}

class RosUnadvertiseTopic extends RosTopic {
  const RosUnadvertiseTopic._({required this.topic, this.id});

  final String? id;

  final String topic;

  @override
  String get op => 'unadvertise';

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      if (id != null) 'id': id,
      'topic': topic,
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return true;
  }

  @override
  bool get hasResponse => false;
}

class RosPublishTopic extends RosTopic {
  const RosPublishTopic._({required this.topic, required this.msg, this.id});

  final String? id;

  final String topic;

  final Map<String, dynamic> msg;

  @override
  String get op => 'publish';

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      if (id != null) 'id': id,
      'topic': topic,
      'msg': msg,
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return true;
  }

  @override
  bool get hasResponse => false;
}

class RosSubscribeTopic extends RosTopic {
  const RosSubscribeTopic._({
    required this.topic,
    this.id,
    this.type,
    this.throttleRate = 0,
    this.queueLength = 1,
    this.fragmentSize,
    this.compression = Compression.none,
  });

  final String? id;

  final String topic;

  final String? type;

  final int throttleRate;

  final int queueLength;

  final int? fragmentSize;

  final Compression compression;

  @override
  String get op => 'subscribe';

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      if (id != null) 'id': id,
      'topic': topic,
      if (type != null) 'type': type,
      'throttleRate': throttleRate,
      'queueLength': queueLength,
      if (fragmentSize != null) 'fragmentSize': fragmentSize,
      'compression': compression.name,
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return response['topic'] == topic;
  }

  @override
  bool get hasResponse => true;
}

class RosUnsubscribeTopic extends RosTopic {
  const RosUnsubscribeTopic._({
    required this.topic,
    this.id,
  });

  final String? id;

  final String topic;

  @override
  String get op => 'unsubscribe';

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      if (id != null) 'id': id,
      'topic': topic,
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return true;
  }

  @override
  bool get hasResponse => false;
}
