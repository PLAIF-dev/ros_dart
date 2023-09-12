part of '../ros_dart.dart';

/// [ROSBridge Protocol](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md)
/// 에 정의된 타입을 Composition으로 사용하기 위해 정의한 `mixin`
mixin RosRequest {
  /// "call_service", "advertise_service" 등과 같은 연산 이름
  /// subclass 에서 직접 이름 지정
  String get op;

  /// 각 [RosRequest] 프로토콜을 표현하기 위해 각 subclass 에서 구현함
  Map<String, dynamic> toMap();

  /// [Ros] (혹은 [WebSocket])을 통해 메시지를 보낼 때 모두 직렬화 한 이후에 보내야하기 때문에
  /// 사용하는 공통 로직
  String toJson() => json.encode(toMap());

  /// 각 [RosRequest]의 subclass 들은 응답 결과가 있을수도 있고 없을 수도 있음
  /// e.g. [RosService.call] 의 경우, 요청에 대해 응답이 있지만, [RosService.advertise],
  ///      [RosTopic.publish] 같은 요청은 응답이 없거나, 응답을 사용하지 않음
  bool get hasResponse;

  /// 제대로된 응답을 수신했는지 확인. [Ros] 에서 사용
  /// 하나의 socket 채널을 통해서 [Stream] 값이 무작위로 들어오기 때문에 제대로 된 값인지
  /// 판별하기 위해 사용
  bool didGetValidResponse(Map<String, dynamic> response);
}

/// [ROSBridge Protocol](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md)
/// 에 정의 되어 있는 Image compression type
enum Compression {
  none,
  png,
}
