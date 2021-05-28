package com.cindyu.all_sensors2;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.PowerManager;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.content.Context.POWER_SERVICE;

/** AllSensorsPlugin */
public class AllSensorsPlugin implements FlutterPlugin {

  /** Plugin registration. */
  private static final String ACCELEROMETER_CHANNEL_NAME = "cindyu.com/all_sensors2/accelerometer";
  private static final String GYROSCOPE_CHANNEL_NAME = "cindyu.com/all_sensors2/gyroscope";
  private static final String USER_ACCELEROMETER_CHANNEL_NAME = "cindyu.com/all_sensors2/user_accel";
  private static final String PROXIMITY_CHANNELNAME = "cindyu.com/all_sensors2/proximity";


  private EventChannel accelerometerChannel;
  private EventChannel userAccelChannel;
  private EventChannel gyroscopeChannel;
  private EventChannel proximityChannel;


  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {

    AllSensorsPlugin plugin = new AllSensorsPlugin();
    plugin.setupEventChannels(registrar.context(), registrar.messenger());

  }

  private void setupEventChannels(Context context, BinaryMessenger messenger) {

    accelerometerChannel = new EventChannel(messenger, ACCELEROMETER_CHANNEL_NAME);
    accelerometerChannel.setStreamHandler(
            new StreamHandlerImpl((SensorManager)context.getSystemService(context.SENSOR_SERVICE), Sensor.TYPE_ACCELEROMETER));

    userAccelChannel = new EventChannel(messenger, USER_ACCELEROMETER_CHANNEL_NAME);
    userAccelChannel.setStreamHandler(
            new StreamHandlerImpl((SensorManager)context.getSystemService(context.SENSOR_SERVICE), Sensor.TYPE_LINEAR_ACCELERATION));

    gyroscopeChannel = new EventChannel(messenger, GYROSCOPE_CHANNEL_NAME);
    gyroscopeChannel.setStreamHandler(
            new StreamHandlerImpl((SensorManager)context.getSystemService(context.SENSOR_SERVICE), Sensor.TYPE_GYROSCOPE));

    proximityChannel = new EventChannel(messenger, PROXIMITY_CHANNELNAME);
    proximityChannel.setStreamHandler(
            new StreamHandlerImpl((SensorManager)context.getSystemService(context.SENSOR_SERVICE), Sensor.TYPE_PROXIMITY,
                    (PowerManager) context.getSystemService(POWER_SERVICE)));
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    final Context context = binding.getApplicationContext();
    setupEventChannels(context, binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    accelerometerChannel.setStreamHandler(null);
    userAccelChannel.setStreamHandler(null);
    gyroscopeChannel.setStreamHandler(null);
    proximityChannel.setStreamHandler(null);
  }
}
