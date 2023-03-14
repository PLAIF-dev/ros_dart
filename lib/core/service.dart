// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:async';

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
  Ros ros;

  /// Service 이름
  String name;

  /// 서비스 타입
  String type;

  /// Advertising 할 때 Service 요청을 위해 구독하는 Advertiser
  Stream<Map<String, dynamic>>? _advertiser;

  /// 서비스가 현재 advertising 하고 있는지 여부
  bool get isAdvertised => _advertiser != null;

  StreamSubscription? listener;
}
