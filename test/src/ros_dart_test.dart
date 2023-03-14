// ignore_for_file: prefer_const_constructors
import 'package:ros_dart/ros_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RosDart', () {
    test('can be instantiated', () {
      expect(RosDart(), isNotNull);
    });
  });
}
