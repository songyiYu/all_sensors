import 'dart:async';

import 'package:flutter/services.dart';

const EventChannel _accelerometerEventChannel =
    EventChannel('cindyu.com/all_sensors/accelerometer');

const EventChannel _userAccelerometerEventChannel =
    EventChannel('cindyu.com/all_sensors/user_accel');

const EventChannel _gyroscopeEventChannel = EventChannel('cindyu.com/all_sensors/gyroscope');

const EventChannel _proximityEventChannel = EventChannel('cindyu.com/all_sensors/proximity');

const MethodChannel _methodChannel = MethodChannel('cindyu.com/all_sensors');


class AccelerometerEvent {
  /// Acceleration force along the x axis (including gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (including gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (including gravity) measured in m/s^2.
  final double z;

  double getZ() => this.z;

  AccelerometerEvent(this.x, this.y, this.z);

  @override
  String toString() => '[AccelerometerEvent (x: $x, y: $y, z: $z)]';
}

class GyroscopeEvent {
  /// Rate of rotation around the x axis measured in rad/s.
  final double x;

  /// Rate of rotation around the y axis measured in rad/s.
  final double y;

  /// Rate of rotation around the z axis measured in rad/s.
  final double z;

  GyroscopeEvent(this.x, this.y, this.z);

  @override
  String toString() => '[GyroscopeEvent (x: $x, y: $y, z: $z)]';
}

class UserAccelerometerEvent {
  /// Acceleration force along the x axis (excluding gravity) measured in m/s^2.
  final double x;

  /// Acceleration force along the y axis (excluding gravity) measured in m/s^2.
  final double y;

  /// Acceleration force along the z axis (excluding gravity) measured in m/s^2.
  final double z;

  UserAccelerometerEvent(this.x, this.y, this.z);

  @override
  String toString() => '[UserAccelerometerEvent (x: $x, y: $y, z: $z)]';
}

class ProximityEvent {
  /// Proximity value Yes or No
  final double proximity;

  ProximityEvent(this.proximity);

//  double getValue() => proximity;

  bool getValue() => proximity == 0 ? true : false;

  @override
  String toString() => proximity == 0 ? 'true' : 'false';
}

AccelerometerEvent _listToAccelerometerEvent(List<double> list) {
  return new AccelerometerEvent(list[0], list[1], list[2]);
}

UserAccelerometerEvent _listToUserAccelerometerEvent(List<double> list) {
  return new UserAccelerometerEvent(list[0], list[1], list[2]);
}

GyroscopeEvent _listToGyroscopeEvent(List<double> list) {
  return new GyroscopeEvent(list[0], list[1], list[2]);
}

ProximityEvent _listToProximityEvent(List<double> list) {
  return new ProximityEvent(list[0]);
}

Stream<AccelerometerEvent>? _accelerometerEvents;
Stream<GyroscopeEvent>? _gyroscopeEvents;
Stream<UserAccelerometerEvent>? _userAccelerometerEvents;
Stream<ProximityEvent>? _proximityEvents;

/// A broadcast stream of events from the device accelerometer.
Stream<AccelerometerEvent>? get accelerometerEvents {
  if (_accelerometerEvents == null) {
    _accelerometerEvents = _accelerometerEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToAccelerometerEvent(event.cast<double>()));
  }
  return _accelerometerEvents;
}

/// A broadcast stream of events from the device gyroscope.
Stream<GyroscopeEvent>? get gyroscopeEvents {
  if (_gyroscopeEvents == null) {
    _gyroscopeEvents = _gyroscopeEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToGyroscopeEvent(event.cast<double>()));
  }
  return _gyroscopeEvents;
}

/// Events from the device accelerometer with gravity removed.
Stream<UserAccelerometerEvent>? get userAccelerometerEvents {
  if (_userAccelerometerEvents == null) {
    _userAccelerometerEvents = _userAccelerometerEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _listToUserAccelerometerEvent(event.cast<double>()));
  }
  return _userAccelerometerEvents;
}

/// A broadcast stream of events from the device proximity.
Stream<ProximityEvent>? get proximityEvents {
  _proximityEvents = _proximityEventChannel
      .receiveBroadcastStream()
      .map((dynamic event) => _listToProximityEvent(event.cast<double>()));

  return _proximityEvents;
}

/// Android only. Select if the screen is automatically turned on/off when the proximity changes.
Future<void> toggleScreenOnProximityChanged(bool enabled) {
  return _methodChannel.invokeMethod<void>(
    'toggleScreenOnProximityChanged',
    <String, dynamic>{'enabled': enabled},
  );
}