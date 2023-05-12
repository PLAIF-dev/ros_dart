import 'package:ros_dart/ros_dart.dart';

Future<void> main() async {
  print('example start');
  final ros = Ros(uri: Uri.parse('ws://192.168.1.6:60000'));
  try {
    print('connection logic done');
    await ros.connect();
    print('closed');
  } on RosWebsocketException {
    print('error occured');
  } finally {
    ros.close();
  }
}
