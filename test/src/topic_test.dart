import 'package:ros_dart/ros_dart.dart';
import 'package:test/test.dart';

void main() {
  group(
    'ROS Topic',
    () {
      const topicName = '/turtle1/cmd_vel';
      const topicType = 'geometry_msgs/Twist';

      group(
        '`advertise`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosTopic.advertise(
                topic: topicName,
                type: topicType,
              );

              /// 다음 [링크](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#341-advertise--advertise-)
              /// 에서 전달 형태가 맞는지 확인
              final comparison = <String, dynamic>{
                'op': 'advertise',
                'topic': topicName,
                'type': topicType,
              };

              // 2. act
              final result = request.toMap();

              // 3. assert
              expect(result, comparison);
            },
          );

          test(
            '요청에 대한 응답이 존재하지 않습니다',
            () async {
              // 1. arrange
              const request = RosTopic.advertise(
                topic: topicName,
                type: topicType,
              );

              // 2. act
              // 3. assert
              expect(request.hasResponse, false);
            },
          );
        },
      );

      group(
        '`unadvertise`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosTopic.unadvertise(
                topic: topicName,
              );

              /// 다음 [링크](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#342-unadvertise--unadvertise-)
              /// 에서 전달 형태가 맞는지 확인
              final comparison = <String, dynamic>{
                'op': 'unadvertise',
                'topic': topicName,
              };

              // 2. act
              final result = request.toMap();

              // 3. assert
              expect(result, comparison);
            },
          );

          test(
            '요청에 대한 응답이 존재하지 않습니다',
            () async {
              // 1. arrange
              const request = RosTopic.unadvertise(
                topic: topicName,
              );

              // 2. act
              // 3. assert
              expect(request.hasResponse, false);
            },
          );
        },
      );

      group(
        '`publish`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosTopic.publish(
                topic: topicName,
                msg: {
                  'linear': {
                    'x': 2,
                    'y': 1,
                    'z': 0,
                  },
                  'angular': {
                    'x': 0,
                    'y': 0,
                    'z': 0,
                  },
                },
              );

              /// 다음 [링크](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#343-publish--publish-)
              /// 에서 전달 형태가 맞는지 확인
              final comparison = <String, dynamic>{
                'op': 'publish',
                'topic': topicName,
                'msg': {
                  'linear': {
                    'x': 2,
                    'y': 1,
                    'z': 0,
                  },
                  'angular': {
                    'x': 0,
                    'y': 0,
                    'z': 0,
                  },
                },
              };

              // 2. act
              final result = request.toMap();

              // 3. assert
              expect(result, comparison);
            },
          );

          test(
            '요청에 대한 응답이 존재하지 않습니다',
            () async {
              // 1. arrange
              const request = RosTopic.publish(topic: topicName, msg: {});

              // 2. act
              // 3. assert
              expect(request.hasResponse, false);
            },
          );
        },
      );

      group(
        '`subscribe`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosTopic.subscribe(
                topic: topicName,
                type: topicType,
              );

              /// 다음 [링크](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#344-subscribe)
              /// 에서 전달 형태가 맞는지 확인
              final comparison = <String, dynamic>{
                'op': 'subscribe',
                'topic': topicName,
                'type': topicType,
                'throttleRate': 0,
                'queueLength': 1,
                'compression': 'none',
              };

              // 2. act
              final result = request.toMap();

              // 3. assert
              expect(result, comparison);
            },
          );

          test(
            '요청에 대한 응답이 존재해야합니다',
            () async {
              // 1. arrange
              const request = RosTopic.subscribe(
                topic: topicName,
                type: topicType,
              );

              // 2. act
              // 3. assert
              expect(request.hasResponse, true);
            },
          );
        },
      );

      group(
        '`unsubscribe`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosTopic.unsubscribe(
                topic: topicName,
              );

              /// 다음 [링크](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#345-unsubscribe)
              /// 에서 전달 형태가 맞는지 확인
              final comparison = <String, dynamic>{
                'op': 'unsubscribe',
                'topic': topicName,
              };

              // 2. act
              final result = request.toMap();

              // 3. assert
              expect(result, comparison);
            },
          );

          test(
            '요청에 대한 응답이 존재하지 않습니다',
            () async {
              // 1. arrange
              const request = RosTopic.unsubscribe(
                topic: topicName,
              );

              // 2. act
              // 3. assert
              expect(request.hasResponse, false);
            },
          );
        },
      );
    },
  );
}
