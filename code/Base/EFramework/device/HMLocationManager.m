//
//  HMLocationManager.m
//  CarAssistant
//
//  Created by Eric on 14-3-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMLocationManager.h"
#import "HMUIApplication.h"

@interface HMLocationManagerDelegate : NSObject<CLLocationManagerDelegate>

AS_SIGNAL(didAuthorizationStatus)
AS_SIGNAL(didNoAuthorizationStatus)

AS_SIGNAL(didUpdateLocations)

AS_SIGNAL(didStartMonitoringForRegion)
AS_SIGNAL(didEnterRegion)
AS_SIGNAL(didExitRegion)

AS_SIGNAL(didUpdateHeading)
AS_SIGNAL(didFailWithError)
@end

@implementation HMLocationManagerDelegate

DEF_SIGNAL(didAuthorizationStatus)
DEF_SIGNAL(didNoAuthorizationStatus)

DEF_SIGNAL(didUpdateLocations)

DEF_SIGNAL(didStartMonitoringForRegion)
DEF_SIGNAL(didEnterRegion)
DEF_SIGNAL(didExitRegion)

DEF_SIGNAL(didUpdateHeading)
DEF_SIGNAL(didFailWithError)

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorized) {
        [self sendSignal:[HMLocationManagerDelegate didAuthorizationStatus]];
    }else{
        if (status == kCLAuthorizationStatusNotDetermined) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
#else
            if(IOS8_OR_LATER)
            {
                if ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedWhenInUse) {
                    [manager requestWhenInUseAuthorization];
                }
            }
#endif
        }
        [self sendSignal:[HMLocationManagerDelegate didNoAuthorizationStatus]];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self sendSignal:[HMLocationManagerDelegate didFailWithError] withObject:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    [self sendSignal:[HMLocationManagerDelegate didUpdateHeading] withObject:newHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations lastObject];
    
    [self sendSignal:[HMLocationManagerDelegate didUpdateLocations] withObject:location];
}

#pragma mark for monitor Region
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [self sendSignal:[HMLocationManagerDelegate didEnterRegion] withObject:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    [self sendSignal:[HMLocationManagerDelegate didExitRegion] withObject:region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    [self sendSignal:[HMLocationManagerDelegate didFailWithError] withObject:error];
}

//7.0
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    [self sendSignal:[HMLocationManagerDelegate didStartMonitoringForRegion] withObject:region];
}

//7.0
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    
}

//7.0
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    
}

// 6.0
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
    
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{
    
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{
    
}

//- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
//    return YES;
//}


@end


@interface HMLocationManager (){
    CLLocationManager *             _locationManager;
    HMLocationManagerDelegate *     _managerDelegate;
    LocationRequestType                     _started;
    LocationRequestType                     _requested;
    BOOL                            _obsered;
}
@property (nonatomic, HM_STRONG,readwrite) CLLocation *preLocation;
@property (nonatomic, HM_STRONG,readwrite) CLHeading *currentHeading;
@property (nonatomic, HM_STRONG,readwrite) CLLocation *currentLocation;
@property (nonatomic,HM_STRONG) NSArray *locs;
@end

@implementation HMLocationManager{
    BOOL simulating;
    NSUInteger simulerFloor;

    NSTimeInterval simulerTick;

}

DEF_SINGLETON(HMLocationManager)
DEF_NOTIFICATION(DID_LOCATED)
DEF_NOTIFICATION(DID_HEADED)
DEF_NOTIFICATION(DENIED)
DEF_NOTIFICATION(AUTHORIZA)
DEF_NOTIFICATION(AUTHORIZA_FAILED)

@synthesize currentHeading;
@synthesize headAngle;
@synthesize currentLocation;
@synthesize preLocation;
@synthesize currentCoor;
@synthesize requested=_requested;

- (id)init
{
    self = [super init];
    if (self) {
        
        _enableLog = YES;
        _managerDelegate = [[HMLocationManagerDelegate alloc]init];
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = _managerDelegate;
        self.distanceSpace = CLLocationDistanceMax;
        self.timerSpace = CLTimeIntervalMax;
        self.minSpeed = 3;
        self.minFilter = 50;
        self.minInteval = 10;
        
        [self resetLocationMangaerBest];
        _managerDelegate.eventReceiver = self;
        
        [self observeNotification:UIApplicationDidEnterBackgroundNotification];
        [self observeNotification:UIApplicationDidBecomeActiveNotification];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        if ([infoDictionary valueForKey:@"NSLocationAlwaysUsageDescription"]==nil&&[infoDictionary valueForKey:@"NSLocationWhenInUseUsageDescription"]==nil) {
            [NSException raise:@"Location error" format:@"main plist has no NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription"];
        }
        
        
    }
    return self;
}

- (BOOL)checkAuthorizationStatusShowTips:(BOOL)show{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status==kCLAuthorizationStatusRestricted||status==kCLAuthorizationStatusDenied){
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
#else
        if(IOS8_OR_LATER&&show){
            HMUIAlertView *alert  = [HMUIAlertView alertViewWithTitle:@"温馨提示" message:@"您没有开启定位服务\n请到设置>隐私>位置服务中打开"];
            [alert addButtonWithTitle:@"确定"];
            [alert addCancelTitle:@"取消"];
            [alert setClicked:^(HMUIAlertView *a, NSInteger b) {
                
                if (b==0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"app-settings:"]];
                }
                
            }];
            [alert show];
            
        }
#endif
        return NO;
    }
    return YES;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy{
    _locationManager.desiredAccuracy = desiredAccuracy;
}

- (CLLocationAccuracy)desiredAccuracy{
    return _locationManager.desiredAccuracy;
}

- (void)setDistanceFilter:(CLLocationDistance)distanceFilter{
    _locationManager.distanceFilter = distanceFilter;
}

- (CLLocationDistance)distanceFilter{
    return _locationManager.distanceFilter;
}

- (void)resetLocationMangaerBest{
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = self.minFilter;//kCLLocationAccuracyHundredMeters;
}

- (void)dealloc
{
    [self unobserveAllNotifications];
    self.preLocation = nil;
    self.currentLocation = nil;
    self.currentHeading = nil;
    
    [_managerDelegate release];
    _locationManager.delegate = nil;
    [_locationManager release];
    HM_SUPER_DEALLOC();
}

/**
 *  规则: 如果速度小于minSpeed m/s 则把触发范围设定为50m
 *  否则将触发范围设定为minSpeed*minInteval
 *  此时若速度变化超过10% 则更新当前的触发范围(这里限制是因为不能不停的设置distanceFilter,
 *  否则uploadLocation会不停被触发)
 */
- (void)adjustDistanceFilter:(CLLocation*)location
{
    //    NSLog(@"adjust:%f",location.speed);
    if (self.minFilter==self.distanceFilter&&self.minFilter<=kCLLocationAccuracyBest) {
        
        return;
    }
    if ( location.speed < self.minSpeed )
    {
        if ( fabs(self.distanceFilter-self.minFilter) > 0.1f )
        {
            self.distanceFilter = self.minFilter;
        }
    }
    else
    {
        CGFloat lastSpeed = self.distanceFilter/self.minInteval;
        
        if ( (fabs(lastSpeed-location.speed)/lastSpeed > 0.1f) || (lastSpeed < 0) )
        {
            CGFloat newSpeed  = (int)(location.speed+0.5f);
            CGFloat newFilter = newSpeed*self.minInteval;
            
            self.distanceFilter = newFilter;
        }
    }
}

- (void)setRequested:(LocationRequestType)requested{
    
    _requested  = requested;
    
    NSString *title=nil;
    
#if IPHONE_OS_VERSION_MAX8_OR_LATER
    
    if(IOS8_OR_LATER)
    {
        if (requested&LocationRequestType_monitor){
            if ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways) {
                [_locationManager requestAlwaysAuthorization];
            }
        }else{
            if ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedWhenInUse) {
                [_locationManager requestWhenInUseAuthorization];
            }
        }
        
    }
    
#endif
    
    if (![CLLocationManager locationServicesEnabled]) {
        title = !!(requested&LocationRequestType_loc)?@"请到设置中开启定位服务！":nil;
    }else{
        if (_started&LocationRequestType_loc) {//has start
            if (!(requested&LocationRequestType_loc)) {//forward to stop
                [_locationManager stopUpdatingLocation];
                _started &= ~LocationRequestType_loc;
            }
        }else{
            if (requested&LocationRequestType_loc) {//forward to start
                
                [_locationManager startUpdatingLocation];
                _started |= LocationRequestType_loc;
            }
        }
    }
    
    if (![CLLocationManager significantLocationChangeMonitoringAvailable]) {
        title = !!(requested&LocationRequestType_monitor)?@"请到设置开启后台定位服务！":nil;
    }else{
        if (_started&LocationRequestType_monitor) {//has start
            if (!(requested&LocationRequestType_monitor)) {//forward to stop
                
                if (_obsered) {
                    [_locationManager stopMonitoringSignificantLocationChanges];
                }
                
                if (!(_started&LocationRequestType_loc)) {//forward to stop
                    [_locationManager stopUpdatingLocation];
                }
                
                if ([CLLocationManager deferredLocationUpdatesAvailable]&&((_started&LocationRequestType_interval)==LocationRequestType_interval||(_started&LocationRequestType_interval)<LocationRequestType_interval)) {
                    _started &= ~LocationRequestType_interval;
//                    [_locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:CLTimeIntervalMax];
                }
                
                _started &= ~LocationRequestType_monitor;
            }else{//forward to change the state
                if (!_obsered&&[UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                    if (((_requested&LocationRequestType_interval)==LocationRequestType_interval)&&[CLLocationManager deferredLocationUpdatesAvailable]) {
//                        [_locationManager allowDeferredLocationUpdatesUntilTraveled:self.distanceSpace timeout:self.timerSpace];
                        _started |= LocationRequestType_interval;
                    }
                    if (!(_started&LocationRequestType_loc)) {//forward to stop
                        [_locationManager stopUpdatingLocation];
                    }
                    _obsered = YES;
                    [_locationManager startMonitoringSignificantLocationChanges];
                }else if (_obsered&&[UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
                    
                    [_locationManager startUpdatingLocation];
                    [_locationManager stopMonitoringSignificantLocationChanges];
                    _obsered = NO;
                }
                
            }
        }else{
            if (requested&LocationRequestType_monitor) {//forward to start
                // 5.iOS9新特性：将允许出现这种场景：同一app中多个location manager：一些只能在前台定位，另一些可在后台定位（并可随时禁止其后台定位）。
                BOOL backgroundmodes = NO;
#if IPHONE_OS_VERSION_MAX9_OR_LATER
                if (IOS9_OR_LATER) {
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    
                    if ([infoDictionary valueForKey:@"UIBackgroundModes"]!=nil&&[[infoDictionary valueForKey:@"UIBackgroundModes"] indexOfObject:@"location"]!=NSNotFound) {
                        backgroundmodes = YES;
                        _locationManager.allowsBackgroundLocationUpdates = YES;
                    }
                }
#endif
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                    if (!_obsered){
                        _obsered = YES;
                        if (!(_started&LocationRequestType_loc)) {//forward to stop
                            [_locationManager stopUpdatingLocation];
                        }
                        [_locationManager startMonitoringSignificantLocationChanges];
                    }
                }else{
                    [_locationManager startUpdatingLocation];
                }
                
                _started |= LocationRequestType_monitor;
            }
        }
    }
    
    
    if (![CLLocationManager headingAvailable]) {
        title = !!(requested&LocationRequestType_head)?@"不支持罗盘服务！":nil;
    }else{
        if (_started&LocationRequestType_head) {//has start
            if (!(requested&LocationRequestType_head)) {//forward to stop
                [_locationManager stopUpdatingHeading];
                _started &= ~LocationRequestType_head;
            }
        }else{
            if (requested&LocationRequestType_head) {//forward to start
                
                [_locationManager startUpdatingHeading];
                _started |= LocationRequestType_head;
            }
        }
    }
    
    if (title!=nil){
        HMUIAlertView *alert = [HMUIAlertView alertViewWithTitle:@"温馨提示" message:title];
        [alert addButtonWithTitle:@"确定"];
        [alert show];
    }
}

- (CGFloat)headAngle{
    if (self.currentHeading) {
        return self.currentHeading.trueHeading;
    }
    return 0.f;
}

- (NSDate *)timestamp{
    return self.currentLocation.timestamp;
}

-  (CLLocationCoordinate2D)currentCoor{
    if (self.currentLocation) {
        return self.currentLocation.coordinate;
    }else if (self.preLocation) {
        return self.preLocation.coordinate;
    }
    return kCLLocationCoordinate2DInvalid;
}

ON_NOTIFICATION(__notification){
    if ([__notification is:UIApplicationDidBecomeActiveNotification]) {
        self.requested = _requested;
    }else if ([__notification is:UIApplicationDidEnterBackgroundNotification]) {
        self.requested = _requested;
    }
}

ON_SIGNAL2(HMLocationManagerDelegate, signal){
    if ([signal is:[HMLocationManagerDelegate didFailWithError]]) {
        NSError *error = (NSError *)[signal inputValue];
        switch (error.code) {
            case kCLErrorDenied://系统拒绝该服务
                [self postNotification:[HMLocationManager DENIED]];
                break;
            case kCLErrorHeadingFailure://罗盘服务失败,设备不支持
                
                break;
            default:
                break;
        }
#if (__ON__ == __HM_DEVELOPMENT__)
        if (_enableLog)
            CC( @"Location",error);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }else if ([signal is:[HMLocationManagerDelegate didNoAuthorizationStatus]]) {
        self.currentLocation = nil;
    }else if ([signal is:[HMLocationManagerDelegate didAuthorizationStatus]]) {
        [self postNotification:[HMLocationManager AUTHORIZA]];
    }else if ([signal is:[HMLocationManagerDelegate didUpdateLocations]]) {
        
        CLLocation *newLocation = (CLLocation *)[signal inputValue];
        [self handleUpdateLocaionts:newLocation];
        
    }else if ([signal is:[HMLocationManagerDelegate didUpdateHeading]]) {
        CLHeading *newHeading = (CLHeading *)[signal inputValue];
        [self handleUpdateHeading:newHeading];
    }
    
}

- (void)handleUpdateHeading:(CLHeading*)newHeading{
    CGFloat heading = -1.0f * M_PI * newHeading.magneticHeading / 180.0f;
    self.currentHeading = newHeading;
    
#if (__ON__ == __HM_DEVELOPMENT__)
    if (_enableLog)
        CC( @"Location",@"magnetic:%.1f true:%.1f acc:%.2f x:%.3f y:%.3f z:%.3f  view can rota:%.1f(-1.0f * M_PI * newHeading.magneticHeading / 180.0f) ",newHeading.magneticHeading,newHeading.trueHeading,newHeading.headingAccuracy,newHeading.x,newHeading.y,newHeading.z,heading);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    [self postNotification:[HMLocationManager DID_HEADED]];
    
}

- (void)handleUpdateLocaionts:(CLLocation *)newLocation{
    
    if (self.preLocation==nil) {
        self.preLocation = self.currentLocation;
    }
    
    CLLocationDistance distance = [self.preLocation distanceFromLocation:newLocation];
    NSTimeInterval interval = fabs([self.preLocation.timestamp timeIntervalSinceDate:newLocation.timestamp]);
    //第一次启动定位，或定位被重置过，或者位置变化存在误差
    
#if (__ON__ == __HM_DEVELOPMENT__)
    if (_enableLog)
        CC( @"Location",@"lat:%.4f lng:%.4f speed:%.2f  distance:%.2f interval:%.3f",newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.speed,distance,interval);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    
//    [self adjustDistanceFilter:newLocation];
    
    if (self.preLocation==nil
        || (distance>0.f||interval>self.minInteval)) {
        self.preLocation = self.currentLocation;
        [self postNotification:[HMLocationManager DID_LOCATED]];
    }
    
    self.currentLocation = newLocation;

}

#pragma mark -

- (void)simulationLocations:(NSArray *)locations{
    
    simulating = YES;
    
    @synchronized(self.locs) {
        simulerTick = self.minInteval-2;
        simulerFloor = 0;
        self.locs = locations;
    }
    [self observeTick];
    
}

- (void)dissimulationLocations{
    simulating = NO;
    [self unobserveTick];
}


- (void)handleTick:(NSTimeInterval)elapsed
{
    simulerTick += elapsed;
    if (simulerTick>=self.minInteval&&simulating) {
        simulerTick = 0;
        @synchronized(self.locs) {
            if (self.locs.count) {
                if (self.locs.count<=simulerFloor) {
                    simulerFloor=0;
                }
                
                CLLocation *newLocation = (CLLocation *)[self.locs objectAtIndex:simulerFloor];
                [self handleUpdateLocaionts:newLocation];
                simulerFloor++;
            }
           
        }
    }
}

#pragma mark -

// 百度坐标转谷歌坐标
const CGFloat x_pi = 3.14159265358979324 * 3000.0 / 180.0;
+ (void)transformatBDLat:(CGFloat)fBDLat BDLng:(CGFloat)fBDLng toGoogleLat:(CGFloat *)pfGoogleLat googleLng:(CGFloat *)pfGoogleLng
{
    CGFloat x = fBDLng - 0.0065f, y = fBDLat - 0.006f;
    CGFloat z = sqrt(x * x + y * y) - 0.00002f * sin(y * x_pi);
    CGFloat theta = atan2(y, x) - 0.000003f * cos(x * x_pi);
    *pfGoogleLng = z * cos(theta);
    *pfGoogleLat = z * sin(theta);
}

+ (CLLocationCoordinate2D)getGoogleLocFromBaiduLocLat:(CGFloat)fBaiduLat lng:(CGFloat)fBaiduLng
{
    CGFloat fLat;
    CGFloat fLng;
    
    [[self class] transformatBDLat:fBaiduLat BDLng:fBaiduLng toGoogleLat:&fLat googleLng:&fLng];
    
    CLLocationCoordinate2D objLoc;
    objLoc.latitude = fLat;
    objLoc.longitude = fLng;
    return objLoc;
}

// 谷歌坐标转百度坐标
+ (CLLocationCoordinate2D)getBaiduLocFromGoogleLocLat:(CGFloat)fGoogleLat lng:(CGFloat)fGoogleLng
{
    CLLocationCoordinate2D objLoc;
    
    CGFloat x = fGoogleLng, y = fGoogleLat;
    CGFloat z = sqrt(x * x + y * y) + 0.00002f * sin(y * x_pi);
    CGFloat theta = atan2(y, x) + 0.000003f * cos(x * x_pi);
    objLoc.longitude = z * cos(theta) + 0.0065;
    objLoc.latitude = z * sin(theta) + 0.006;
    
    return objLoc;
}

/*******************       === GPS-Google  BEGIN  ===    *******************/
/*               在网上看到的根据这个 c# 代码改的 GPS坐标转火星坐标               */
/*  https://on4wp7.codeplex.com/SourceControl/changeset/view/21483#353936  */
/***************************************************************************/

const double pi = 3.14159265358979324;
//
// Krasovsky 1940
//
// a = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

bool outOfChina(double lat, double lon);
static double transformLat(double x, double y);
static double transformLon(double x, double y);

// World Geodetic System ==> Mars Geodetic System
CLLocationCoordinate2D transformFromWGSCoord2MarsCoord(CLLocationCoordinate2D wgsCoordinate)
{
    double wgLat = wgsCoordinate.latitude;
    double wgLon = wgsCoordinate.longitude;
    
    if (outOfChina(wgLat, wgLon))
    {
        return wgsCoordinate;
    }
    
    double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
    double radLat = wgLat / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    
    CLLocationCoordinate2D marsCoordinate = {wgLat + dLat, wgLon + dLon};
    return marsCoordinate;
}

bool outOfChina(double lat, double lon)
{
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}
/*******************       === GPS-Google  END  ===    *******************/

// GPS坐标转谷歌坐标
+ (CLLocationCoordinate2D)GPSLocToGoogleLoc:(CLLocationCoordinate2D)objGPSLoc
{
    return transformFromWGSCoord2MarsCoord(objGPSLoc);
}
#pragma mark - calculate distance  根据2个经纬度计算距离

+ (CLLocationDegrees) LantitudeLongitudeDist:(CLLocationCoordinate2D)dist prov:(CLLocationCoordinate2D)prov{
    
    CLLocationDegrees lat1 = dist.latitude;
    CLLocationDegrees lon1 = dist.longitude;
    CLLocationDegrees lat2 = prov.latitude;
    CLLocationDegrees lon2 = prov.longitude;
    
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = M_PI*lat1/180.0f;
    double radlat2 = M_PI*lat2/180.0f;
    //now long.
    double radlong1 = M_PI*lon1/180.0f;
    double radlong2 = M_PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = M_PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = M_PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = M_PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = M_PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = M_PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = M_PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double distance  = theta*er;
    return distance;
}

@end

HM_EXTERN_C_BEGIN

BOOL CLLocationCoordinateEqualTo(CLLocationCoordinate2D coordinate1, CLLocationCoordinate2D coordinate2){
    return (coordinate1.latitude==coordinate2.latitude)&&(coordinate1.longitude==coordinate2.longitude);
}

BOOL CLLocationCoordinateIsValid(CLLocationCoordinate2D coordinate){
    return (!((coordinate.latitude==0.f)&&(coordinate.longitude==0.f))&&CLLocationCoordinate2DIsValid(coordinate));
}
HM_EXTERN_C_END