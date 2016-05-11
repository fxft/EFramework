//
//  HMDeviceCapacity.m
//  CarAssistant
//
//  Created by Eric on 14-3-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMDeviceCapacity.h"
#import <CoreMotion/CoreMotion.h>

@interface HMDeviceCapacity ()<UIAccelerometerDelegate>

@end

@implementation HMDeviceCapacity
DEF_SINGLETON(HMDeviceCapacity)

DEF_NOTIFICATION(ORIENTATIONCHANGED)
@synthesize catched;
@synthesize orientaionDeviceNext;
@synthesize orientaionDevicePre;

- (id)init
{
    self = [super init];
    if (self) {
        [MotionOrientation sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:MotionOrientationInterfaceOrientationChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)orientationChanged:(NSNotification *)note{
    
    self.orientaionDevicePre = self.orientaionDeviceNext;
    
    self.orientaionDeviceNext = [MotionOrientation sharedInstance].interfaceOrientation;
#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"DeviceCapacity",@"next:%@  pre:%@",[self stringDescriptionForInterfaceOrientation:self.orientaionDeviceNext],[self stringDescriptionForInterfaceOrientation:self.orientaionDevicePre]);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    if (self.orientaionDevicePre!=self.orientaionDeviceNext) {
        [self postNotification:self.ORIENTATIONCHANGED];
    }
    
}
- (NSString *)stringDescriptionForDeviceOrientation:(UIDeviceOrientation)orientation
{
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
            return @"Portrait";
        case UIDeviceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIDeviceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIDeviceOrientationLandscapeRight:
            return @"LandscapeRight";
        case UIDeviceOrientationFaceUp:
            return @"FaceUp";
        case UIDeviceOrientationFaceDown:
            return @"FaceDown";
        case UIDeviceOrientationUnknown:
        default:
            return @"Unknown";
    }
}

- (NSString *)stringDescriptionForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            return @"Portrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"LandscapeRight";
        default:
            return @"Unknown";
    }
}

- (void)dealloc
{
    HM_SUPER_DEALLOC();
}

HM_EXTERN_C_BEGIN
void MAKECALL(NSString *phone){
    if (![phone isTelephone]) {
        phone = [phone.trim stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSRange range = [phone rangeOfString:@"电话"];
        if (range.location != NSNotFound) {
            range.location = range.length;
            range.length = phone.length - range.location;
            phone = [phone substringWithRange:range];
        }
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",[phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]]];
}
HM_EXTERN_C_END
@end

@implementation NSObject (DeviceCapacity)


- (void)enableCatchAccelerometer{
    
    if (![HMDeviceCapacity sharedInstance].catched) {
        
        [HMDeviceCapacity sharedInstance].catched = YES;
        [[MotionOrientation sharedInstance] start];
    }
}

- (void)disableCatchAccelerometer{
    
    if ([HMDeviceCapacity sharedInstance].catched) {
        
        [HMDeviceCapacity sharedInstance].catched = NO;
        [[MotionOrientation sharedInstance] stop];
    }
}

- (CGAffineTransform)orientationAffine{
    return [MotionOrientation sharedInstance].affineTransform;
}

- (CGAffineTransform)orientationAffineFor:(UIInterfaceOrientation)interfaceOr{
    return [MotionOrientation affineTransformFor:interfaceOr];
}

@end
