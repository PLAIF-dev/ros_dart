// Copyright (c) 2019 Conrad Heidebrecht.

import 'package:ros_dart/core/ros.dart';
import 'package:ros_dart/core/service.dart';

/// ROS 매개변수wrapper
class RosParam {
  /// ROS 매개변수wrapper
  const RosParam({
    required this.ros,
    required this.name,
  });

  /// ROS 연결 객체
  final Ros ros;

  /// 파라미터 이름
  final String name;

  /// ROS Node로 부터 parameter 받아오기(/rosapi/get_param service 사용)
  Future<dynamic> get() {
    final client = RosService(
      ros: ros,
      name: '/rosapi/get_param',
      type: 'rosapi/GetParam',
    );
    return client({'name': name});
  }

  /// [value] 지정
  Future<List<Map<String, dynamic>>> set(dynamic value) {
    final client = RosService(
      ros: ros,
      name: '/rosapi/set_param',
      type: 'rosapi/SetParam',
    );
    return client({
      'name': name,
      'value': value,
    });
  }

  /// parameter 삭제
  Future<List<Map<String, dynamic>>> delete() {
    final client = RosService(
      ros: ros,
      name: '/rosapi/delete_param',
      type: 'rosapi/DeleteParam',
    );
    return client({'name': name});
  }
}
