import 'package:mocktail/mocktail.dart';
import 'package:ros_dart/ros_dart.dart';
import 'package:test/fake.dart' as fake;
import 'package:test/test.dart';

class MockRosWebsocket extends Mock implements RosWebsocket {}

class FakeRosWebsocket extends fake.Fake implements RosWebsocket {}

void main() {
  late Ros ros;
  late MockRosWebsocket socket;

  setUpAll(
    () {
      socket = MockRosWebsocket();
      ros = Ros(
        uri: Uri.parse('ws://192.168.0.1'),
        socket: socket,
      );
    },
  );

  group(
    'Ros.connect',
    () {
      test(
        'should pass when connection succeeds',
        () async {
          // arrange
          when(socket.connect).thenAnswer((_) async {});
          when(() => socket.stream).thenAnswer((_) => const Stream.empty());
          // act
          await ros.connect();
          // assert
          verify(() => socket.connect());
          verify(() => socket.stream);
          verifyNoMoreInteractions(socket);
        },
      );

      test(
        'should throw RosWebsocketException when connection fails',
        () async {
          // arrange
          const exception = RosWebsocketException();
          when(() => socket.connect()).thenThrow(exception);
          // assert
          expect(() => ros.connect(), throwsA(same(exception)));
        },
      );
    },
  );
}
