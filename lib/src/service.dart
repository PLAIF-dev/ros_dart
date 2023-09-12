part of '../ros_dart.dart';

/// [ROSBridge Protocol](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md)
/// 중 `Service` 에 관련된 요청 모음
///
/// 1. call
/// 2. advertise
/// 3. unadvertise
abstract class RosService with RosRequest {
  /// 하위 클래스를 const 로 사용하기 위해서 const constructor 정의함
  const RosService();

  /// API call 과 비슷함
  ///
  /// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#346-call-service)
  /// 참고
  const factory RosService.call({
    required String service,
    String id,
    List<Map<String, dynamic>> args,
    int fragmentSize,
    Compression compression,
  }) = RosCallService._;

  /// Service 호출전 `roscore` 에 보내 호출한다고 알려주는 요청
  ///
  /// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#347-advertise-service)
  /// 참고
  const factory RosService.advertise({
    required String type,
    required String service,
  }) = RosAdvertiseService._;

  /// Service 호출 후 호출 끝났다고 알려주는 요청
  ///
  /// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#348-unadvertise-service)
  /// 참고
  const factory RosService.unadvertise({
    required String service,
  }) = RosUnadvertiseService._;
}

/// API call 과 비슷함
///
/// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#346-call-service)
/// 참고
class RosCallService extends RosService {
  ///
  const RosCallService._({
    required this.service,
    this.id,
    this.args = const [],
    this.fragmentSize,
    this.compression = Compression.none,
  });

  ///
  final String? id;

  /// Service 이름
  final String service;

  /// 호출 위해 전달해야 할 arguments
  final List<Map<String, dynamic>> args;

  ///
  final int? fragmentSize;

  /// 이미지 압축 형태
  final Compression compression;

  @override
  String get op => 'call_service';

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      if (id != null) 'id': id,
      'service': service,
      'args': args,
      if (fragmentSize != null) 'fragmentSize': fragmentSize,
      'compression': compression.name,
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return response['service'] == service;
  }

  @override
  bool get hasResponse => true;
}

/// Service 호출전 `roscore` 에 보내 호출한다고 알려주는 요청
///
/// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#347-advertise-service)
/// 참고
class RosAdvertiseService extends RosService {
  ///
  const RosAdvertiseService._({
    required this.type,
    required this.service,
  });

  final String type;

  final String service;

  @override
  String get op => 'advertise_service';

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      'type': type,
      'service': service,
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return true;
  }

  @override
  bool get hasResponse => false;
}

/// Service 호출 후 호출 끝났다고 알려주는 요청
///
/// [공식 문서](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#348-unadvertise-service)
/// 참고
class RosUnadvertiseService extends RosService {
  const RosUnadvertiseService._({
    required this.service,
  });

  final String service;

  @override
  String get op => 'unadvertise_service';

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      'service': service,
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return true;
  }

  @override
  bool get hasResponse => false;
}
