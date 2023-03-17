// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:convert';

/// Container for all possible ROS request parameters
class RosRequest {
  /// !주의!: 모든 RosRequest는 생성이후 수정이 불가능하다라고 정의하였으나,
  /// 추후 protocol 확인 후 변경될 수 있음
  const RosRequest({
    required this.op,
    this.id,
    this.type,
    this.topic,
    this.msg = const {},
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

  /// String으로 들어온 경우는 변경로직 만들지말고 이것 사용
  factory RosRequest.decode(String raw) {
    return RosRequest.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  /// JSON 기본 변환 생성자
  factory RosRequest.fromJson(Map<String, dynamic> jsonData) {
    return RosRequest(
      op: jsonData['op'] as String,
      id: jsonData['id'] as String?,
      type: jsonData['type'] as String?,
      topic: jsonData['topic'] as String?,
      msg: jsonData['msg'] as Map<String, dynamic>,
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

  /// 요청보낸 작업.
  final String op;

  /// 작업중인 요청이나 객체를 구분하기 위한 ID
  final String? id;

  /// 메시지 혹은 서비스 타입.
  final String? type;

  /// 작업중인 Topic 이름.
  final String? topic;

  /// 메시지 객체.
  final Map<String, dynamic> msg;

  /// 배포(publishing)할 때 topic을 latch 하였는지 아닌지 여부.
  final bool? latch;

  /// 사용하기 위한 압축타입. `png`, `cbor`.
  final String? compression;

  /// 메시지 사이 Topic 진입을 막기 위한 throttle 비율.
  final int? throttleRate;

  /// 구독할 때 사용하는 bridge 측의 queue 길이.
  final int? queueLength;

  /// topic 제발행을 위해 bridge 측에서 생성되는 queue 크기.
  final int? queueSize;

  /// 작동하는 서비스 이름.
  final String? service;

  /// 요청 인자 (JSON).
  final Map<String, dynamic>? args;

  /// 요청으로부터의 응답값.
  final dynamic values;

  /// true when indicating the success of the operation.
  final bool? result;

  /// Language Server가 String typo는 잡아주지 않기 때문에 변환에 반드시 이것 사용
  Map<String, dynamic> toJson() {
    return {
      'op': op,
      'id': id ?? '',
      'topic': topic ?? '',
      'msg': msg,
      'latch': latch ?? false,
      'compression': compression ?? '',
      'throttle_rate': throttleRate ?? -1,
      'queue_length': queueLength ?? 0,
      'queue_size': queueSize ?? 0,
      'service': service ?? '',
      'args': args ?? '',
      'values': values,
      'result': result ?? false,
    };
  }

  /// String 변환을 위해 통일해서 사용하라
  String encode() {
    return json.encode(toJson());
  }
}
