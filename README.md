# ros_dart

[![License: MIT][license_badge]][license_link]

Dart 에서 사용할 수 있는 ROS Client

## 설치 방법 💻

**❗ `ros_dart` 패키지를 사용하기 위해서는 [Dart SDK][dart_install_link] 혹은 [Flutter SDK][flutter_install_link] 가 필요합니다.**

`ros_dart`를 `pubspec.yaml`에 추가:

```yaml
dependencies:
  ros_dart:
    git:
      url: https://github.com/plaif-dev/ros_dart.git
      ref: main
```

## 기본 사용법 ⌨️

### 1. Service

```dart
import 'package:ros_dart/ros_dart.dart';

void main() async {
  final ros = Ros.implement();

  await ros.connect(Uri.parse('ws://127.0.0.1:9090'));
  
  final request = RosService.call(service: '/clear', args: []);

  final response = ros.send(request);
}
```

### 2. Topic

```dart
import 'package:ros_dart/ros_dart.dart';

void main() async {
  final ros = Ros.implement();

  await ros.connect(Uri.parse('ws://127.0.0.1:9090'));

  final request = RosTopic.advertise(
                topic: '/turtle1/cmd_vel',
                type: 'geometry_msgs/Twist',
  );

  final Stream<Map<String,dynamic>> response = ros.send(request);
}
```

### 3. Param

```dart
import 'package:ros_dart/ros_dart.dart';

void main() async {
  final ros = Ros.implement();

  await ros.connect(Uri.parse('ws://127.0.0.1:9090'));

  final request = RosTopic.advertise(name: '/background_g');

  final Stream<Map<String,dynamic>> response = ros.send(request);
}
```

---

[dart_install_link]: https://dart.dev/get-dart
[flutter_install_link]: https://docs.flutter.dev/get-started/install
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
