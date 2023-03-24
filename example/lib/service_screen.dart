import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ros_dart/ros_dart.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  late Ros _ros;
  late RosService _service;
  late RosParam _paramBgR;
  late RosParam _paramBgG;
  late RosParam _paramBgB;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _ros = Ros(uri: Uri.parse('ws://127.0.0.1:9090'));
    _service = RosService(
      ros: _ros,
      name: '/clear',
      type: 'std_srvs/Empty',
    );
    _paramBgR = RosParam(ros: _ros, name: '/turtlesim/background_r');
    _paramBgG = RosParam(ros: _ros, name: '/turtlesim/background_g');
    _paramBgB = RosParam(ros: _ros, name: '/turtlesim/background_b');
    _ros.connect();
  }

  @override
  void dispose() {
    _ros.close();
    super.dispose();
  }

  void _sendServiceCall() {
    // _param.get().then((value) => print(value));
    _paramBgR.set(_random.nextInt(255).toString());
    _paramBgG.set(_random.nextInt(255).toString());
    _paramBgB.set(_random.nextInt(255).toString());
    _service.call({});
  }

  Future<Map<String, dynamic>>? serviceHandler(
      Map<String, dynamic> args) async {
    final response = <String, dynamic>{};
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child:
            Text('Notice changes in your turtlesim after clicking the button'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendServiceCall,
        child: const Icon(Icons.tv),
      ),
    );
  }
}
