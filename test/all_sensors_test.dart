import 'package:all_sensors2/all_sensors2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('all_sensors2');

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
