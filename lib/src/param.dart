part of '../ros_dart.dart';

/// ROS Parameter Server 에 등록된 parameter를
///
/// 1. 가져오기(Read)
/// 2. 수정하기(Update)
/// 3. 삭제하기(Delete)
///
/// 하는 요청
abstract class RosParam with RosRequest {
  /// 하위 클래스를 const 로 사용하기 위해서 const constructor 정의함
  const RosParam();

  /// parameter 를 가져오는 요청
  ///
  /// 따로 프로토콜이 정리되어 있는 것은 없음
  /// 내부적으로는 [RosService.call] protocol 형태의 데이터를 보냄
  const factory RosParam.get({
    required String name,
  }) = RosGetParam._;

  /// parameter 를 변경하는 요청
  ///
  /// 따로 프로토콜이 정리되어 있는 것은 없음
  /// 내부적으로는 [RosService.call] protocol 형태의 데이터를 보냄
  const factory RosParam.set({
    required String name,
    required String value,
  }) = RosSetParam._;

  /// parameter 를 삭제 요청
  ///
  /// 따로 프로토콜이 정리되어 있는 것은 없음
  /// 내부적으로는 [RosService.call] protocol 형태의 데이터를 보냄
  const factory RosParam.delete({
    required String name,
  }) = RosDeleteParam._;

  @override
  String get op => 'call_service';
}

class RosGetParam extends RosParam {
  const RosGetParam._({
    required this.name,
  });

  final String name;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      'service': _service,
      'args': {'name': name},
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return response['service'] == _service;
  }

  @override
  bool get hasResponse => true;

  String get _service => '/rosapi/get_param';
}

///
class RosSetParam extends RosParam {
  ///
  const RosSetParam._({
    required this.name,
    required this.value,
  });

  final String name;
  final String value;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      'service': _service,
      'args': {
        'name': name,
        'value': value,
      },
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return response['service'] == _service;
  }

  @override
  bool get hasResponse => true;

  String get _service => '/rosapi/set_param';
}

class RosDeleteParam extends RosParam {
  const RosDeleteParam._({
    required this.name,
  });

  final String name;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'op': op,
      'service': _service,
      'args': {'name': name},
    };
  }

  @override
  bool didGetValidResponse(Map<String, dynamic> response) {
    return response['service'] == _service;
  }

  @override
  bool get hasResponse => true;

  String get _service => '/rosapi/delete_param';
}
