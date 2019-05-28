
#ifndef AllSensorsPlugin_h
#define AllSensorsPlugin_h
#import <Flutter/Flutter.h>

@interface AllSensorsPlugin : NSObject<FlutterPlugin>
@end

@interface CDYUserAccelStreamHandler : NSObject<FlutterStreamHandler>
@end

@interface CDYAccelerometerStreamHandler : NSObject<FlutterStreamHandler>
@end

@interface CDYGyroscopeStreamHandler : NSObject<FlutterStreamHandler>
@end

@interface CDYProximityStreamHandler : NSObject<FlutterStreamHandler>
@end

#endif /* AllSensorsPlugin_h */
