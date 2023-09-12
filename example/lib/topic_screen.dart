import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ros_dart/ros_dart.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  late Ros _ros;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _ros = Ros.implement();

    _ros.connect(Uri.parse('ws://127.0.0.1:9090'));
  }

  @override
  void dispose() {
    _ros.disconnect();
    super.dispose();
  }

  void _sendTopic() {
    final request = RosTopic.publish(
      topic: '/turtle1/cmd_vel',
      msg: {
        'linear': {
          'x': _random.nextDouble() * 2 * (_random.nextBool() ? 1 : -1),
          'y': _random.nextDouble() * 2 * (_random.nextBool() ? 1 : -1),
          'z': 0,
        },
        'angular': {
          'x': 0,
          'y': 0,
          'z': 0,
        },
      },
    );

    _ros.send(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic'),
      ),
      body: const Center(
        child: Text('Look at your turtlesim after pushing the button'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendTopic,
        child: const Icon(Icons.add),
      ),
    );
  }
}
