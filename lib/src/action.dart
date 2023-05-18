part of '../ros_dart.dart';

///
class RosAction {
  ///
  RosAction({
    required this.ros,
    required this.serverName,
    required this.actionName,
    required this.timeout,
    required this.omitFeedback,
    required this.omitStatus,
    required this.omitResult,
  }) {
    feedbacker = RosTopic(
      ros: ros,
      name: '$serverName/feedback',
      type: '${actionName}Feedback',
    );
    statuser = RosTopic(
      ros: ros,
      name: '$serverName/status',
      type: 'actionlib_msgs/GoalStatusArray',
    );
    resulter = RosTopic(
      ros: ros,
      name: '$serverName/result',
      type: '${actionName}Result',
    );
    goaler = RosTopic(
      ros: ros,
      name: '$serverName/goal',
      type: '${actionName}Goal',
    );
    canceler = RosTopic(
      ros: ros,
      name: '$serverName/cancel',
      type: 'actionlib_msgs/GoalID',
    );
  }

  final Ros ros;

  final String serverName;

  final String actionName;

  final int timeout;

  final bool omitFeedback;

  final bool omitStatus;

  final bool omitResult;

  final Map<String, StreamController<dynamic>> goals = {};

  late final RosTopic feedbacker;

  late final RosTopic statuser;

  late final RosTopic resulter;

  late final RosTopic goaler;

  late final RosTopic canceler;

  List<StreamSubscription<dynamic>> subs = [];

  Future<void> init() async {
    await goaler.advertise();
    await canceler.advertise();

    if (!omitStatus) {
      await statuser.subscribe((data) async {});
      subs.add(statuser.subscription!.listen((message) {
        for (final status
            in message['status_list'] as List<Map<String, dynamic>>) {
          final g = status['goal_id']['id'] as String;
          goals[g] ??= StreamController.broadcast();
          goals[g]?.add({'status': status});
        }
      }));
    }

    if (!omitFeedback) {
      await feedbacker.subscribe((data) async {});
      subs.add(feedbacker.subscription!.listen((message) {
        final g = message['status']['goal_id']['id'] as String;
        goals[g] ??= StreamController.broadcast();
        goals[g]?.add({'status': message['status']});
        goals[g]?.add({'feedback': message['feedback']});
      }));
    }

    if (!omitResult) {
      await resulter.subscribe((data) async {});
      subs.add(resulter.subscription!.listen((message) {
        final g = message['status']['goal_id']['id'] as String;
        goals[g] ??= StreamController.broadcast();
        goals[g]?.add({'status': message['status']});
        goals[g]?.add({'result': message['result']});
      }));
    }
  }

  void cancel() {}

  void dispose() {}
}
