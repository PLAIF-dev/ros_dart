// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:convert';

/// Container for all possible ROS request parameters
class RosRequest {
  factory RosRequest.decode(String raw) {
    return RosRequest.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  factory RosRequest.fromJson(Map<String, dynamic> jsonData) {
    return RosRequest(
      op: jsonData['op'] as String,
      id: jsonData['id'] as String?,
      type: jsonData['type'] as String?,
      topic: jsonData['topic'] as String?,
      msg: jsonData['msg'],
      latch: jsonData['latch'] as bool?,
      compression: jsonData['compression'] as String?,
      throttleRate: jsonData['throttle_rate'] as int?,
      queueLength: jsonData['queue_length'] as int?,
      queueSize: jsonData['queue_size'] as int?,
      service: jsonData['service'] as String?,
      args: jsonData['args'] as Map<String, dynamic>?,
      values: jsonData['values'],
      result: jsonData['result'] as bool?,
    );
  }
  RosRequest({
    required this.op,
    this.id,
    this.type,
    this.topic,
    this.msg,
    this.latch,
    this.compression,
    this.throttleRate,
    this.queueLength,
    this.queueSize,
    this.service,
    this.args,
    this.values,
    this.result,
  });

  /// 요청보낸 작업.
  String op;

  /// 작업중인 요청이나 객체를 구분하기 위한 ID
  String? id;

  /// 메시지 혹은 서비스 타입.
  String? type;

  /// 작업중인 Topic 이름.
  String? topic;

  /// 메시지 객체.
  dynamic msg;

  /// 배포(publishing)할 때 topic을 latch 하였는지 아닌지 여부.
  bool? latch;

  /// 사용하기 위한 압축타입. `png`, `cbor`.
  String? compression;

  /// 메시지 사이 Topic 진입을 막기 위한 throttle 비율.
  int? throttleRate;

  /// 구독할 때 사용하는 bridge 측의 queue 길이.
  int? queueLength;

  /// topic 제발행을 위해 bridge 측에서 생성되는 queue 크기.
  int? queueSize;

  /// 작동하는 서비스 이름.
  String? service;

  /// 요청 인자 (JSON).
  Map<String, dynamic>? args;

  /// 요청으로부터의 응답값.
  dynamic values;

  /// true when indicating the success of the operation.
  bool? result;

  Map<String, dynamic> toJson() {
    return {
      'op': op,
      'id': id ?? '',
      'topic': topic ?? '',
      'msg': msg ?? '',
      'latch': latch ?? false,
      'compression': compression ?? '',
      'throttle_rate': throttleRate ?? -1,
      'queue_length': queueLength ?? 0,
      'queue_size': queueSize ?? 0,
      'service': service ?? '',
      'args': args ?? '',
      'values': values ?? '',
      'result': false,
    };
  }

  String encode() {
    return json.encode(toJson());
  }
}
