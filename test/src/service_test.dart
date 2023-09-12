import 'package:ros_dart/ros_dart.dart';
import 'package:test/test.dart';

void main() {
  const serviceName = '/clear';
  const serviceType = 'std_srvs/Empty';
  group(
    'ROS Service',
    () {
      group(
        '`call`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request = RosService.call(service: serviceName, args: []);

              /// 다음 [링크](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#346-call-service)
              /// 에서 전달 형태가 맞는지 확인
              final comparison = <String, dynamic>{
                'op': 'call_service',
                'service': serviceName,
                'args': [],
                'compression': 'none'
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
              const request = RosService.call(service: serviceName);

              // 2. act
              // 3. assert
              expect(request.hasResponse, true);
            },
          );
        },
      );

      group(
        '`advertise`',
        () {
          test(
            '유효한 프로토콜 형태 이어야 합니다',
            () async {
              // 1. arrange
              const request =
                  RosService.advertise(service: serviceName, type: serviceType);

              /// 다음 [링크](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#347-advertise-service)
              /// 에서 전달 형태가 맞는지 확인
              final comparison = <String, dynamic>{
                'op': 'advertise_service',
                'type': serviceType,
                'service': serviceName,
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
              const request =
                  RosService.advertise(service: serviceName, type: serviceType);

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
              const request = RosService.unadvertise(service: serviceName);

              /// 다음 [링크](https://github.com/biobotus/rosbridge_suite/blob/master/ROSBRIDGE_PROTOCOL.md#348-unadvertise-service)
              /// 에서 전달 형태가 맞는지 확인
              final comparison = <String, dynamic>{
                'op': 'unadvertise_service',
                'service': serviceName,
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
              const request = RosService.unadvertise(service: serviceName);

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
