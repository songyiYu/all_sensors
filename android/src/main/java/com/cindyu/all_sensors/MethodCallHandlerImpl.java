package com.cindyu.all_sensors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.cindyu.all_sensors.StreamHandlerImpl;

public class MethodCallHandlerImpl implements MethodCallHandler {
  private final StreamHandlerImpl proximityStreamHandler;

  public MethodCallHandlerImpl(StreamHandlerImpl proximityStreamHandler) {
    this.proximityStreamHandler = proximityStreamHandler;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("toggleScreenOnProximityChanged")) {
      Boolean enabled = (Boolean) call.argument("enabled");
      this.proximityStreamHandler.setToggleScreenOnProximityChanged(enabled);
    } else {
      result.notImplemented();
    }
  }
}
