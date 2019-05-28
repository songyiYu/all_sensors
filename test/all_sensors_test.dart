import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_sensors/all_sensors.dart';

void main() {
  const MethodChannel channel = MethodChannel('all_sensors');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

//  test('getPlatformVersion', () async {
//    expect(await AllSensors.platformVersion, '42');
//  });
}
