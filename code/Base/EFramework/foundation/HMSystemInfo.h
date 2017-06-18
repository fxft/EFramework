//
//  HMSystemInfo.h
//  CarAssistant
//
//  Created by Eric on 14-3-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#define IPHONE_OS_VERSION_MAX11_OR_LATER (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000)
#define IPHONE_OS_VERSION_MAX10_OR_LATER (__IPHONE_OS_VERSION_MAX_ALLOWED >= 100000)
#define IPHONE_OS_VERSION_MAX9_OR_LATER (__IPHONE_OS_VERSION_MAX_ALLOWED >= 90000)
#define IPHONE_OS_VERSION_MAX8_OR_LATER (__IPHONE_OS_VERSION_MAX_ALLOWED >= 80000)
#define IPHONE_OS_VERSION_MAX7_OR_LATER (__IPHONE_OS_VERSION_MAX_ALLOWED >= 70000)
#define IPHONE_OS_VERSION_MAX6_OR_LATER (__IPHONE_OS_VERSION_MAX_ALLOWED >= 60000)
#define IPHONE_OS_VERSION_MAX5_OR_LATER (__IPHONE_OS_VERSION_MAX_ALLOWED >= 50000)
#define IPHONE_OS_VERSION_MAX4_OR_LATER (__IPHONE_OS_VERSION_MAX_ALLOWED >= 40000)

#define IPHONE_OS_VERSION_MAX10_OR_EARLIER ( !IPHONE_OS_VERSION_MAX11_OR_LATER )
#define IPHONE_OS_VERSION_MAX9_OR_EARLIER ( !IPHONE_OS_VERSION_MAX10_OR_LATER )
#define IPHONE_OS_VERSION_MAX8_OR_EARLIER ( !IPHONE_OS_VERSION_MAX9_OR_LATER )
#define IPHONE_OS_VERSION_MAX7_OR_EARLIER ( !IPHONE_OS_VERSION_MAX8_OR_LATER )
#define IPHONE_OS_VERSION_MAX6_OR_EARLIER ( !IPHONE_OS_VERSION_MAX7_OR_LATER )
#define IPHONE_OS_VERSION_MAX5_OR_EARLIER ( !IPHONE_OS_VERSION_MAX6_OR_LATER )
#define IPHONE_OS_VERSION_MAX4_OR_EARLIER ( !IPHONE_OS_VERSION_MAX5_OR_LATER )

#define IOS11_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=11  )
#define IOS10_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=10  )
#define IOS9_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=9  )
#define IOS8_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=8  )
#define IOS7_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=7  )
#define IOS6_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=6  )
#define IOS5_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=5 )
#define IOS4_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=4  )
#define IOS3_OR_LATER		( [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."].firstObject integerValue]>=3  )

#define IOS10_OR_EARLIER	( !IOS11_OR_LATER )
#define IOS9_OR_EARLIER		( !IOS10_OR_LATER )
#define IOS8_OR_EARLIER		( !IOS9_OR_LATER )
#define IOS7_OR_EARLIER		( !IOS8_OR_LATER )
#define IOS6_OR_EARLIER		( !IOS7_OR_LATER )
#define IOS5_OR_EARLIER		( !IOS6_OR_LATER )
#define IOS4_OR_EARLIER		( !IOS5_OR_LATER )
#define IOS3_OR_EARLIER		( !IOS4_OR_LATER )

#define IS_SCREEN_5_5_INCH	([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1080, 1920), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_4_7_INCH	([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_4_INCH	([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_35_INCH	([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define DEV_SIMULATER ([[UIDevice currentDevice].model isEqualToString:@"iPhone Simulator"])

#else	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#define IOS11_OR_LATER		(NO)
#define IOS10_OR_LATER		(NO)
#define IOS9_OR_LATER		(NO)
#define IOS8_OR_LATER		(NO)
#define IOS7_OR_LATER		(NO)
#define IOS6_OR_LATER		(NO)
#define IOS5_OR_LATER		(NO)
#define IOS4_OR_LATER		(NO)
#define IOS3_OR_LATER		(NO)

#define IS_SCREEN_5_5_INCH (NO)
#define IS_SCREEN_4_7_INCH (NO)
#define IS_SCREEN_4_INCH	(NO)
#define IS_SCREEN_35_INCH	(NO)
#define DEV_SIMULATER       (NO)

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
@class HMMemoryInfo;
@class HMNetworkInfo;
@class HMCPUMemoryInfo;

@interface HMSystemInfo : NSObject

+ (NSString *)OSVersion;
+ (NSString *)appVersion;
+ (NSString *)appIdentifier;
+ (NSString *)deviceModel;
+ (NSString *)deviceUUID;//open uuid

+ (NSString *)macaddress;//可以忽略
+ (NSString *)ipAddress;//will return error string when error;
+ (NSString *)appShortVersion NS_AVAILABLE_IOS(4_0);//build
+ (NSString *)appName;

//内存信息
+ (HMCPUMemoryInfo *)cpuMemoryInfo;
//存储信息
+ (HMMemoryInfo *)memoryInfo;
//网络状态信息
+ (HMNetworkInfo *)networkInfo;
+ (HMNetworkInfo *)diffNetworkInfo;//必须更新networkInfo
+ (HMNetworkInfo *)lastNetworkInfo;//必须更新networkInfo

/**
 *  返回App支持的路径方案
 *
 *   return
 */
+ (NSString *)anyScheme;
+ (NSString *)anySchemeForIdentifier:(NSString*)identifier;
+ (NSArray *)anySchemesForIdentifier:(NSString*)identifier;

+ (BOOL)isJailBroken		NS_AVAILABLE_IOS(4_0);
+ (NSString *)jailBreaker	NS_AVAILABLE_IOS(4_0);

+ (BOOL)isDevicePhone;
+ (BOOL)isDevicePad;

/**
 *  是否是iPhone3
 */
+ (BOOL)isPhone35;
/**
 *  是否是iPhone4
 */
+ (BOOL)isPhoneRetina35;
/**
 *  是否是iPhone5
 */
+ (BOOL)isPhoneRetina4;
/**
 *  是否是iPhone6
 */
+ (BOOL)isPhoneRetina47;
/**
 *  是否是iPhone6 plus
 */
+ (BOOL)isPhoneRetina55;

+ (BOOL)isPad;
+ (BOOL)isPadRetina;
+ (BOOL)isScreenSize:(CGSize)size;

+ (NSString*)currentLanguage;

@end

@interface HMMemoryInfo : NSObject

@property (nonatomic, assign) unsigned long long total;/**< B */
@property (nonatomic, assign) unsigned long long free;/**< B */
@property (nonatomic, assign) unsigned long long used;/**< B */
@property (nonatomic, assign) unsigned long long active;/**< B */
@property (nonatomic, assign) unsigned long long inactive;/**< B */
@property (nonatomic, assign) unsigned long long wired;/**< B */
@property (nonatomic, assign) unsigned long long purgable;/**< B */

@end

@interface HMCPUMemoryInfo : NSObject

@property (nonatomic, assign) unsigned long long total;/**< B */
@property (nonatomic, assign) unsigned long long virtuals;/**< B */
@property (nonatomic, assign) unsigned long long used;/**< B */
@property (nonatomic, assign) float usage;/**cpu使用率 */
@property (nonatomic, assign) NSTimeInterval userTime;/**< microseconds */
@property (nonatomic, assign) NSTimeInterval systemTime;/**< microseconds */

@end

@interface HMNetworkInfo : NSObject

@property (nonatomic, assign) unsigned long long wifiSent;/**< B */
@property (nonatomic, assign) unsigned long long wiFiReceived;/**< B */
@property (nonatomic, assign) unsigned long long wwanSent;/**< B */
@property (nonatomic, assign) unsigned long long wwanReceived;/**< B */

- (void)reset;
- (void)updateWithNetworkInfo:(HMNetworkInfo *)netInfo;

@end
