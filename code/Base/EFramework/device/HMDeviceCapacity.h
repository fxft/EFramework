//
//  HMDeviceCapacity.h
//  CarAssistant
//
//  Created by Eric on 14-3-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
/**
 *  设备能力
 *
 *  @param __notification
 *
 *  @return
 */

#import <Foundation/Foundation.h>
#import "HMLocationManager.h"
#import "MotionOrientation.h"

#define ON_NOTIFI_DeviceCapacity(__notification) ON_NOTIFICATION3(HMDeviceCapacity, ORIENTATIONCHANGED, __notification)
@protocol ON_Device_handle <NSObject>

ON_NOTIFI_DeviceCapacity(__notification);

@end


@interface HMDeviceCapacity : NSObject
AS_SINGLETON(HMDeviceCapacity)
AS_NOTIFICATION(ORIENTATIONCHANGED)

@property (nonatomic,assign) UIInterfaceOrientation orientaionDevicePre;
@property (nonatomic,assign) UIInterfaceOrientation orientaionDeviceNext;
@property (nonatomic,assign) BOOL                catched;
/**
 *  打电话,并可返回应用
 *
 *  @param phone 电话号码
 */
HM_EXTERN void MAKECALL(NSString *phone);

@end

@interface NSObject (DeviceCapacity)

- (void)enableCatchAccelerometer;
- (void)disableCatchAccelerometer;

- (CGAffineTransform)orientationAffine;
- (CGAffineTransform)orientationAffineFor:(UIInterfaceOrientation)interfaceOr;
@end
