// Copyright (c) 2019 Conrad Heidebrecht.

part of '../ros_dart.dart';

/// ROS Parameter wrapper
class RosParam {
  /// ROS Parameter wrapper
  const RosParam({
    required this.ros,
    required this.name,
  });

  /// [Ros] object which handles connection with `ROS`.
  final Ros ros;

  /// [RosParam] name. Check this with the command below.
  /// ```shell
  /// rosparam list
  /// ```
  ///
  final String name;

  /// this method mostly returns [bool] value for call success
  Future<dynamic> get() async {
    final client = RosService(
      ros: ros,
      name: '/rosapi/get_param',
      type: 'rosapi/GetParam',
    );
    return client.call({'name': name});
  }

  /// this method mostly returns [bool] value for call success
  Future<dynamic> set(dynamic value) async {
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

  /// this method mostly returns [bool] value for call success
  Future<dynamic> delete() async {
    final client = RosService(
      ros: ros,
      name: '/rosapi/delete_param',
      type: 'rosapi/DeleteParam',
    );
    return client.call({'name': name});
  }
}
