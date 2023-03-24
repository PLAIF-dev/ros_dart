// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:convert';

import 'package:ros_dart/core/core.dart';

/// Container for all possible ROS request parameters
class RosRequest {
  /// A proposal object to receive data from protocols
  /// such as topic, service in ROS
  /// !warning: This writer arbitrarily assume that the request is immutable
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

  /// Use this always to convert raw `String` data to `RosRequest`
  factory RosRequest.decode(String raw) {
    return RosRequest.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  /// `JSON` converter
  factory RosRequest.fromJson(Map<String, dynamic> jsonData) {
    return RosRequest(
      op: jsonData['op'] as String,
      id: jsonData['id'] as String?,
      type: jsonData['type'] as String?,
      topic: jsonData['topic'] as String?,
      msg: jsonData['msg'] as Map<String, dynamic>,
      latch: jsonData['latch'] as bool?,
      compression: RosCompression.values.firstWhere(
        (e) => e.toString() == jsonData['compression'] as String?,
      ),
      throttleRate: jsonData['throttle_rate'] as int?,
      queueLength: jsonData['queue_length'] as int?,
      queueSize: jsonData['queue_size'] as int?,
      service: jsonData['service'] as String?,
      args: jsonData['args'] as Map<String, dynamic>?,
      values: jsonData['values'],
      result: jsonData['result'] as bool?,
    );
  }

  /// operation name such as `call_service`, `advertise_service`
  final String op;

  /// arbitrary id for uniqueness
  final String? id;

  /// type of service or message
  final String? type;

  /// [RosTopic.name]
  final String? topic;

  /// messages
  final Map<String, dynamic> msg;

  /// true when topic latches in publishing
  final bool? latch;

  /// compression type such as `png`, `cbor`.
  final RosCompression? compression;

  /// rate to pass between message by message
  final int? throttleRate;

  /// queue length from ROSBridge to subscribe
  final int? queueLength;

  /// queue size from ROSBridge to republish topic
  final int? queueSize;

  /// service name
  final String? service;

  /// JSON arguments
  final Map<String, dynamic>? args;

  /// the result can vary from `bool` to `JSON List`
  final dynamic values;

  /// true when indicating the success of the operation.
  final bool? result;

  /// Use this because Language Server cannot guarantee typo of [Map]
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

  /// Use this always to convert this object to `String`
  String encode() {
    return json.encode(toJson());
  }
}
