import 'package:ros_dart/ros_dart.dart';
import 'package:test/test.dart';

void main() {
  const paramNodeName = '/background_g';

  group(
    'ROS Param',
    () {
      group(
        '`get`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosParam.get(name: paramNodeName);

              /// ROS Param 은 Parameter Server의 데이터를 조종하는 Service call 형태.
              final comparison = <String, dynamic>{
                'op': 'call_service',
                'service': '/rosapi/get_param',
                'args': {'name': paramNodeName},
              };

              // 2. act
              final result = request.toMap();

              // 3. assert
              expect(result, comparison);
            },
          );

          test(
            '요청에 대한 응답이 존재해야 합니다',
            () async {
              // 1. arrange
              const request = RosParam.get(name: paramNodeName);

              // 2. act
              // 3. assert
              expect(request.hasResponse, true);
            },
          );
        },
      );

      group(
        '`set`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosParam.set(name: paramNodeName, value: '25');

              /// ROS Param 은 Parameter Server의 데이터를 조종하는 Service call 형태.
              final comparison = <String, dynamic>{
                'op': 'call_service',
                'service': '/rosapi/set_param',
                'args': {'name': paramNodeName, 'value': '25'},
              };

              // 2. act
              final result = request.toMap();

              // 3. assert
              expect(result, comparison);
            },
          );

          test(
            '요청에 대한 응답이 존재해야 합니다',
            () async {
              // 1. arrange
              const request = RosParam.set(name: paramNodeName, value: '25');

              // 2. act
              // 3. assert
              expect(request.hasResponse, true);
            },
          );
        },
      );

      group(
        '`delete`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosParam.delete(name: paramNodeName);

              /// ROS Param 은 Parameter Server의 데이터를 조종하는 Service call 형태.
              final comparison = <String, dynamic>{
                'op': 'call_service',
                'service': '/rosapi/delete_param',
                'args': {'name': paramNodeName},
              };

              // 2. act
              final result = request.toMap();

              // 3. assert
              expect(result, comparison);
            },
          );

          test(
            '요청에 대한 응답이 존재해야 합니다',
            () async {
              // 1. arrange
              const request = RosParam.delete(name: paramNodeName);

              // 2. act
              // 3. assert
              expect(request.hasResponse, true);
            },
          );
        },
      );
    },
  );
}
