//
//  MotionOrientation.h
//
//  Created by Sangwon Park on 5/3/12.
//  Copyright (c) 2012 tastyone@gmail.com. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <CoreGraphics/CoreGraphics.h>

extern NSString* const MotionOrientationChangedNotification;//加速计发生变化发出通知
extern NSString* const MotionOrientationInterfaceOrientationChangedNotification;//iphone方向变化发出通知

extern NSString* const kMotionOrientationKey;//取值的key，返回MotionOrientation对象

typedef void (^MotionAccelerometerHandler)(CMAccelerometerData * accelerometerData,float angle,float absoluteZ, NSError * error);

/**
 *  加速计 使用
 */
@interface MotionOrientation : NSObject

@property (readonly) UIInterfaceOrientation interfaceOrientation;
@property (readonly) UIDeviceOrientation deviceOrientation;
@property (readonly) CGAffineTransform affineTransform;

@property (nonatomic,copy) MotionAccelerometerHandler handler;//当加速计发生变化时触发

@property (assign) BOOL showDebugLog;

+ (void)initialize;
+ (MotionOrientation *)sharedInstance;

- (void)stop;
- (void)start;

/**
 *  获取视图方向上需要选择的角度
 *
 *   interfaceOr
 *
 *   return 
 */
+ (CGAffineTransform)affineTransformFor:(UIInterfaceOrientation)interfaceOr;

@end
