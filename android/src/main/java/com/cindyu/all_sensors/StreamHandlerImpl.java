package com.cindyu.all_sensors;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.PowerManager;
import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.EventChannel;

public class StreamHandlerImpl implements EventChannel.StreamHandler{

    private SensorEventListener sensorEventListener;
    private SensorManager sensorManager;
    private final Sensor sensor;
    private PowerManager powerManager;
    private PowerManager.WakeLock wakeLock;
    private static int field = 0x00000020;
    private boolean onCancelCalled = false;
    private boolean far = true;
    private boolean proximityListenerEnabled = true;
    private boolean toggleScreenOnProximityChanged = true;

    public StreamHandlerImpl(SensorManager sensorManager, int sensorType) {
        this.sensorManager = sensorManager;
        sensor = sensorManager.getDefaultSensor(sensorType);
    }

    public StreamHandlerImpl(SensorManager sensorManager, int sensorType, PowerManager powerManager) {
        this(sensorManager, sensorType);
        this.powerManager = powerManager;
        try {
            field = PowerManager.class.getField("PROXIMITY_SCREEN_OFF_WAKE_LOCK").getInt(null);
        } catch (Throwable ignored) {}
        this.wakeLock = powerManager.newWakeLock(field, "AllSensors::Wakelock");
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        onCancelCalled = false;
        sensorEventListener = createSensorEventListener(events, sensorManager);
        sensorManager.registerListener(sensorEventListener, sensor, sensorManager.SENSOR_DELAY_NORMAL);
    }

    @Override
    public void onCancel(Object arguments) {
        onCancelCalled = true;
        if(far) sensorManager.unregisterListener(sensorEventListener);
    }

    SensorEventListener createSensorEventListener(final EventChannel.EventSink events, final SensorManager sensorManager) {
        return new SensorEventListener() {
            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {}

            @Override
            public void onSensorChanged(SensorEvent event) {

                double[] sensorValues = new double[event.values.length];
                for (int i = 0; i < event.values.length; i++) {
                    sensorValues[i] = event.values[i];
                }
                if (event.sensor.getType() == Sensor.TYPE_PROXIMITY) {
                    // Don't send event when proximityListenerEnabled is false.
                    if(!proximityListenerEnabled){
                        return;
                    }

                    if (onCancelCalled && far){
                      sensorManager.unregisterListener(this);
                    } else {
                      setWakeLock(sensorValues[0]);
                    }
                }
                events.success(sensorValues);

            }
        };
    }

    private void setWakeLock (double value) {
        try {
            if (value == 0) {
                far = false;
                if (this.toggleScreenOnProximityChanged) {
                    wakeLock.acquire();
                }
            } else {
                far = true;
                if (this.toggleScreenOnProximityChanged && wakeLock.isHeld()) {
                    wakeLock.release();
                }
            }
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void setToggleScreenOnProximityChanged(boolean enabled) {
        this.toggleScreenOnProximityChanged = enabled;
    }

}
