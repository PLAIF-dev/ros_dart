part of '../ros_dart.dart';

/// Exception when websocket tries to send message without connection

class RosWebsocketException implements Exception {
  /// Message would be empty string
  const RosWebsocketException([this.message = '']);

  /// Message would be empty string
  final String message;

  @override
  String toString() => 'RosWebsocketException: $message';
}
