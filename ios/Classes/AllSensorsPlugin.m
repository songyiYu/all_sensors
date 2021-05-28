
#import <Foundation/Foundation.h>
#import "AllSensorsPlugin.h"
#import <CoreMotion/CoreMotion.h>

NSNotificationCenter *proximityObserver;

@implementation AllSensorsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    CDYAccelerometerStreamHandler* accelerometerStreamHandler =
    [[CDYAccelerometerStreamHandler alloc] init];
    FlutterEventChannel* accelerometerChannel =
    [FlutterEventChannel eventChannelWithName:@"cindyu.com/all_sensors2/accelerometer"
                              binaryMessenger:[registrar messenger]];
    [accelerometerChannel setStreamHandler:accelerometerStreamHandler];
    
    CDYUserAccelStreamHandler* userAccelerometerStreamHandler =
    [[CDYUserAccelStreamHandler alloc] init];
    FlutterEventChannel* userAccelerometerChannel =
    [FlutterEventChannel eventChannelWithName:@"cindyu.com/all_sensors2/user_accel"
                              binaryMessenger:[registrar messenger]];
    [userAccelerometerChannel setStreamHandler:userAccelerometerStreamHandler];
    
    CDYGyroscopeStreamHandler* gyroscopeStreamHandler = [[CDYGyroscopeStreamHandler alloc] init];
    FlutterEventChannel* gyroscopeChannel =
    [FlutterEventChannel eventChannelWithName:@"cindyu.com/all_sensors2/gyroscope"
                              binaryMessenger:[registrar messenger]];
    [gyroscopeChannel setStreamHandler:gyroscopeStreamHandler];
    
    CDYProximityStreamHandler* proximityStreamHandler = [[CDYProximityStreamHandler alloc] init];
    FlutterEventChannel* proximityChannel =
    [FlutterEventChannel eventChannelWithName:@"cindyu.com/all_sensors2/proximity"
                              binaryMessenger:[registrar messenger]];
    [proximityChannel setStreamHandler:proximityStreamHandler];
}

@end

const double GRAVITY = 9.8;
CMMotionManager* _motionManager;

void _initMotionManager() {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
}

static void sendTriplet(Float64 x, Float64 y, Float64 z, FlutterEventSink sink) {
    NSMutableData* event = [NSMutableData dataWithCapacity:3 * sizeof(Float64)];
    [event appendBytes:&x length:sizeof(Float64)];
    [event appendBytes:&y length:sizeof(Float64)];
    [event appendBytes:&z length:sizeof(Float64)];
    sink([FlutterStandardTypedData typedDataWithFloat64:event]);
}

@implementation CDYAccelerometerStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _initMotionManager();
    [_motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData* accelerometerData, NSError* error) {
         CMAcceleration acceleration = accelerometerData.acceleration;
         // Multiply by gravity, and adjust sign values to
         // align with Android.
         sendTriplet(-acceleration.x * GRAVITY, -acceleration.y * GRAVITY,
                     -acceleration.z * GRAVITY, eventSink);
     }];
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [_motionManager stopAccelerometerUpdates];
    return nil;
}

@end

@implementation CDYUserAccelStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _initMotionManager();
    [_motionManager
     startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMDeviceMotion* data, NSError* error) {
         CMAcceleration acceleration = data.userAcceleration;
         // Multiply by gravity, and adjust sign values to align with Android.
         sendTriplet(-acceleration.x * GRAVITY, -acceleration.y * GRAVITY,
                     -acceleration.z * GRAVITY, eventSink);
     }];
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [_motionManager stopDeviceMotionUpdates];
    return nil;
}

@end

@implementation CDYGyroscopeStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _initMotionManager();
    [_motionManager
     startGyroUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMGyroData* gyroData, NSError* error) {
         CMRotationRate rotationRate = gyroData.rotationRate;
         sendTriplet(rotationRate.x, rotationRate.y, rotationRate.z, eventSink);
     }];
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [_motionManager stopGyroUpdates];
    return nil;
}

@end

@implementation CDYProximityStreamHandler

- (FlutterError*) onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = YES;
    double proximityValue= device.proximityState ? 0 : 1;
    sendTriplet(proximityValue, proximityValue, proximityValue, eventSink);
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    proximityObserver = [[NSNotificationCenter defaultCenter]
     addObserverForName:UIDeviceProximityStateDidChangeNotification
     object:nil
     queue:mainQueue
     usingBlock:^(NSNotification *note){
         UIDevice *device = [UIDevice currentDevice];
         double proximityValue= device.proximityState ? 0 : 1;
         sendTriplet(proximityValue, proximityValue, proximityValue, eventSink);
     }
     ];
    return nil;
    
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:proximityObserver name:UIDeviceProximityStateDidChangeNotification object:nil];
    return nil;
}

@end
