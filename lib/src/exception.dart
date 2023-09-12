part of '../ros_dart.dart';

/// ROS 연결을 먼저 하지 않고 데이터를 보내려고 했을 때, 발생하는 Exception
class NoRosConnectionException implements Exception {
  const NoRosConnectionException();

  /// Exception 떨어트렸을 때, 보여줄 메시지
  static const String message =
      'ROS Client is not initialized. Please connect first';
}
