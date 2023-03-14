// Copyright (c) 2019 Conrad Heidebrecht.

import 'package:ros_dart/core/ros.dart';
import 'package:ros_dart/core/service.dart';

/// ROS 매개변수wrapper
class Param {
  Param({
    required this.ros,
    required this.name,
  });

  /// ROS 연결 객체
  Ros ros;

  /// 파라미터 이름
  String name;

  /// Get the parameter from the ROS node using the /rosapi/get_param service.
  Future get() {
    final client = RosService(
      ros: ros,
      name: '/rosapi/get_param',
      type: 'rosapi/GetParam',
    );
    return client.call({'name': name});
  }

  /// Set the [value] of the parameter.
  Future set(dynamic value) {
    final client = RosService(
      ros: ros,
      name: '/rosapi/set_param',
      type: 'rosapi/SetParam',
    );
    return client.call({
      'name': name,
      'value': value,
    });
  }

  /// Delete the parameter.
  Future delete() {
    final client = RosService(
      ros: ros,
      name: '/rosapi/delete_param',
      type: 'rosapi/DeleteParam',
    );
    return client.call({'name': name});
  }
}
