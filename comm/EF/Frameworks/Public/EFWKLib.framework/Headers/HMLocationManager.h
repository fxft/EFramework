//
//  HMLocationManager.h
//  CarAssistant
//
//  Created by Eric on 14-3-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//


#import "HMMacros.h"
#import "HMFoundation.h"


#define ON_NOTIFI_Location(__filter,__notification) ON_NOTIFICATION3(HMLocationManager, __filter, __notification)

@protocol ON_Location_handle <NSObject>

ON_NOTIFI_Location(__filter,__notification);

@end

typedef NS_ENUM(NSInteger, LocationRequestType){
    LocationRequestType_none = 0x00,
    LocationRequestType_loc = 0x01,/*默认以最小进度、无过滤定位*/
    LocationRequestType_head = 0x01<<1, /*陀螺仪*/
    LocationRequestType_monitor = 0x01<<2,/*请在plist中设置，location background；该定位方式采用基站定位，精度比较差*/
    LocationRequestType_interval = 0x01<<3|LocationRequestType_monitor,
};

@interface HMLocationManager : NSObject

AS_SINGLETON(HMLocationManager)
AS_NOTIFICATION(DID_LOCATED)//位置发生变化满足变更条件时触发
AS_NOTIFICATION(DID_HEADED)//罗盘发生变化满足变更条件时触发
AS_NOTIFICATION(DENIED)//用户拒绝该服务
AS_NOTIFICATION(AUTHORIZA)//授权成功
AS_NOTIFICATION(AUTHORIZA_FAILED)//授权失败

@property(assign, nonatomic) CLLocationDistance distanceFilter;//CLLocationDistanceMax default
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;//CLTimeIntervalMax default

@property (nonatomic, assign) CGFloat minSpeed;     //最小速度 3 default
@property (nonatomic, assign) CGFloat minFilter;    //最小范围 50 default
@property (nonatomic, assign) CGFloat minInteval;   //更新间隔 10 default

- (void)resetLocationMangaerBest;//设置desiredAccuracy为kCLLocationAccuracyBest

@property (nonatomic, readonly) CGFloat            headAngle;

@property (nonatomic, readonly) CLLocationCoordinate2D  currentCoor;

@property (nonatomic, HM_STRONG,readonly) CLHeading *currentHeading;

@property (nonatomic, HM_STRONG,readonly) CLLocation *currentLocation;

@property (nonatomic, HM_STRONG,readonly) CLLocation *preLocation;

@property(readonly, nonatomic) NSDate *timestamp;

/*
 for LocationRequestType_interval
 */
@property (nonatomic) NSTimeInterval timerSpace;
@property (nonatomic) NSTimeInterval distanceSpace;

@property (nonatomic) BOOL enableLog;

/**
 *  设置requsted即可启动监听位置、陀螺仪信息
 */
@property (nonatomic)  LocationRequestType                requested;
- (BOOL)checkAuthorizationStatusShowTips:(BOOL)show;//启动前可以检测一下是否有效

/// 模拟轨迹，CLLocation array
- (void)simulationLocations:(NSArray*)locations;
- (void)dissimulationLocations;

/// 百度坐标转谷歌坐标
+ (void)transformatBDLat:(CGFloat)fBDLat BDLng:(CGFloat)fBDLng toGoogleLat:(CGFloat *)pfGoogleLat googleLng:(CGFloat *)pfGoogleLng;
/// 百度坐标转谷歌坐标
+ (CLLocationCoordinate2D)getGoogleLocFromBaiduLocLat:(CGFloat)fBaiduLat lng:(CGFloat)fBaiduLng;

/// 谷歌坐标转百度坐标
+ (CLLocationCoordinate2D)getBaiduLocFromGoogleLocLat:(CGFloat)fGoogleLat lng:(CGFloat)fGoogleLng;

/// GPS坐标转谷歌坐标
+ (CLLocationCoordinate2D)GPSLocToGoogleLoc:(CLLocationCoordinate2D)objGPSLoc;

/// 计算两点直线距离
+ (CLLocationDegrees)LantitudeLongitudeDist:(CLLocationCoordinate2D)dist prov:(CLLocationCoordinate2D)prov;

@end

HM_EXTERN BOOL CLLocationCoordinateEqualTo(CLLocationCoordinate2D coordinate1, CLLocationCoordinate2D coordinate2);
HM_EXTERN BOOL CLLocationCoordinateIsValid(CLLocationCoordinate2D coordinate);

