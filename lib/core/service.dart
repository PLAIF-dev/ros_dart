// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:async';
import 'dart:convert';

import 'package:ros_dart/core/request.dart';
import 'package:ros_dart/core/ros.dart';

/// A callback from advertisement succeeds
typedef ServiceHandler = Future<Map<String, dynamic>>? Function(
  Map<String, dynamic> args,
);

/// ROS service wrapper
class RosService {
  /// default constructor
  RosService({
    required this.ros,
    required this.name,
    required this.type,
  });

  /// ROS object
  final Ros ros;

  /// service name
  final String name;

  /// service type
  final String type;

  // this watches advertising
  Stream<Map<String, dynamic>>? _advertiser;

  /// true if advertising now
  bool get isAdvertised => _advertiser != null;

  /// This object catches ROS Service callback and returns value as [Future]
  late StreamSubscription<dynamic> _listener;

  /// service call with [RosRequest.args]
  Future<dynamic> call(Map<String, dynamic> args) async {
    // TODO(youngmin-gwon): change to custom exception
    // if (isAdvertised) throw UnimplementedError();

    final callId = ros.requestServiceCaller(name);
    final receiver = ros.stream
        .where(
      (message) => message['id'] == callId,
    )
        .map(
      (message) {
        if (message['result'] == null) {
          // TODO(youngmin-gwon): consider whether it throws exception or empty
          throw UnimplementedError();
        }
        return json.decode(message['result'].toString());
      },
    );

    final completer = Completer<dynamic>();
    _listener = receiver.listen((d) {
      completer.complete(d);
      _listener.cancel();
    });

    ros.send(
      RosRequest(
        op: 'call_service',
        id: callId,
        service: name,
        type: type,
        args: args,
      ).encode(),
    );

    return completer.future;
  }

  /// it starts advertising
  Future<void> advertise(ServiceHandler handler) async {
    if (isAdvertised) return;

    final request = RosRequest(
      op: 'advertise_service',
      type: type,
      service: name,
    );
    ros.send(request.encode());

    _advertiser = ros.stream;
    _advertiser!.listen((message) async {
      if (message['service'] != name) return;

      final resp =
          await handler(message['args'] as Map<String, dynamic>? ?? {});
      final request = RosRequest(
        op: 'service_response',
        id: message['id'] as String? ?? '',
        service: name,
        values: resp ?? {},
        result: resp != null,
      );
      ros.send(request.encode());
    });
  }

  /// it stops advertising
  void unadvertise() {
    if (!isAdvertised) return;
    final request = RosRequest(
      op: 'unadvertise_service',
      service: name,
    );
    ros.send(request.encode());
    _advertiser = null;
  }
}
