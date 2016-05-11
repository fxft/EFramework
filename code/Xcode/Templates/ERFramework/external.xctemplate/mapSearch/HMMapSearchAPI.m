//
//  HMMapSearchAPI.m
//  WestLuckyStar
//
//  Created by Eric on 14-6-3.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMMapSearchAPI.h"

@implementation HMAMapPlaceSearchRequest
@synthesize tag;
@synthesize tagString;
- (void)dealloc
{
    self.tagString = nil;
    HM_SUPER_DEALLOC();
}
- (void)addPolygonPoint:(CLLocationCoordinate2D)coor{
    NSMutableArray *arry = [NSMutableArray arrayWithArray:self.polygon.points];
    [arry addObject:[AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude]];
    self.polygon = [AMapGeoPolygon polygonWithPoints:arry];
}
@end

@implementation HMAMapInputTipsSearchRequest
@synthesize tag;
@synthesize tagString;
- (void)dealloc
{
    self.tagString = nil;
    HM_SUPER_DEALLOC();
}
@end


@implementation HMAMapReGeocodeSearchRequest
@synthesize tag;
@synthesize tagString;
- (void)dealloc
{
    self.tagString = nil;
    HM_SUPER_DEALLOC();
}
@end

@implementation HMAMapGeocodeSearchRequest
@synthesize tag;
@synthesize tagString;
- (void)dealloc
{
    self.tagString = nil;
    HM_SUPER_DEALLOC();
}
@end

@implementation HMAMapNavigationSearchRequest
@synthesize tag;
@synthesize tagString;
- (void)dealloc
{
    self.tagString = nil;
    HM_SUPER_DEALLOC();
}
@end


@implementation HMAMapBusStopSearchRequest
@synthesize tag;
@synthesize tagString;
- (void)dealloc
{
    self.tagString = nil;
    HM_SUPER_DEALLOC();
}
@end

@implementation HMAMapBusLineSearchRequest
@synthesize tag;
@synthesize tagString;
- (void)dealloc
{
    self.tagString = nil;
    HM_SUPER_DEALLOC();
}
@end

@interface HMMapSearchAPI ()<AMapSearchDelegate>
@property (nonatomic, HM_STRONG) AMapSearchAPI *search;
@end

@implementation HMMapSearchAPI
{
    BOOL hadLocation;
    BOOL locating;

}
@synthesize lastSearchResult;

DEF_SINGLETON(HMMapSearchAPI)
DEF_NOTIFICATION(MapSearchReturn)

+ (void)resetWithKey:(NSString*)key{
    [HMMapSearchAPI sharedInstance].search = [[[AMapSearchAPI alloc]initWithSearchKey:key Delegate:[HMMapSearchAPI sharedInstance]]autoreleaseARC];
}

- (void)dealloc
{
    self.lastSearchResult = nil;
    self.search = nil;
    HM_SUPER_DEALLOC();
}

#pragma mark - 

- (void)doSearchLocationReloadIfTimeAgo:(NSTimeInterval)interval{
    if (locating) {
        return;
    }
    locating =  YES;
    if (interval>0.f&&[HMLocationManager sharedInstance].timestamp&&self.lastSearchResult) {
        NSTimeInterval time = [[HMLocationManager sharedInstance].timestamp timeIntervalSinceNow];
        if (time+interval>0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:self.lastSearchResult forKey:MAPSEARCHKEY_RESPONSE];
            HMAMapReGeocodeSearchRequest*request=  [[[HMAMapReGeocodeSearchRequest alloc] init]autoreleaseARC];
            request.tagString = @"SearchLocation";
            [dic setObject:request forKey:MAPSEARCHKEY_REQUEST];
            [dic setObject:request.tagString forKey:MAPSEARCHKEY_TagString];
            [self postNotification:self.MapSearchReturn withObject:dic];
            locating = NO;
            return;
        }
    }
    
    [self observeNotification:[HMLocationManager DID_LOCATED]];
    
    hadLocation = !!([HMLocationManager sharedInstance].requested & LocationRequestType_loc);

    [HMLocationManager sharedInstance].requested = LocationRequestType_loc;
}

ON_NOTIFI_Location(DID_LOCATED, noti){
    if (!hadLocation) {
        [HMLocationManager sharedInstance].requested &= ~LocationRequestType_loc;
    }
    locating = NO;
    [self unobserveNotification:[HMLocationManager DID_LOCATED]];
    
    [self searchReGeocode:[HMLocationManager sharedInstance].currentCoor radius:500].tagString = @"SearchLocation";
}


#pragma mark 关键字查询
- (HMAMapPlaceSearchRequest*)searchPOIUid:(NSString*)uid{
    HMAMapPlaceSearchRequest *poiRequest = [[[HMAMapPlaceSearchRequest alloc] init]autoreleaseARC];
    poiRequest.uid = uid;//oiRequest.uid = @"B000A7ZQYC"; 返回的是poi的信息详情
    poiRequest.searchType = AMapSearchType_PlaceID;
    [self.search performSelector:@selector(AMapPlaceSearch:) withObject:poiRequest afterDelay:.1f];
    return poiRequest;
}

- (HMAMapPlaceSearchRequest*)searchPOIKeywords:(NSString*)keys inCities:(NSArray*)cities{
    HMAMapPlaceSearchRequest *poiRequest = [[[HMAMapPlaceSearchRequest alloc] init]autoreleaseARC];
    poiRequest.keywords = keys;
    poiRequest.searchType = AMapSearchType_PlaceKeyword;
    poiRequest.city = cities;
    [self.search performSelector:@selector(AMapPlaceSearch:) withObject:poiRequest afterDelay:.1f];
    return poiRequest;
}

- (HMAMapPlaceSearchRequest*)searchPOIArround:(CLLocationCoordinate2D)coor keywords:(NSString*)keys radius:(NSInteger)radius{
    HMAMapPlaceSearchRequest *poiRequest = [[[HMAMapPlaceSearchRequest alloc] init]autoreleaseARC];
    poiRequest.searchType = AMapSearchType_PlaceAround;
    poiRequest.radius = radius;
    poiRequest.keywords = keys;
    poiRequest.location = [AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude];
    [self.search performSelector:@selector(AMapPlaceSearch:) withObject:poiRequest afterDelay:.1f];
    return poiRequest;
}

- (HMAMapPlaceSearchRequest*)searchPOIKeywords:(NSString*)keys byPolygon:(NSArray *)valueOfCoors{
    HMAMapPlaceSearchRequest *poiRequest = [[[HMAMapPlaceSearchRequest alloc] init]autoreleaseARC];
    poiRequest.searchType = AMapSearchType_PlacePolygon;
    poiRequest.keywords = keys;
    NSMutableArray *arry = [NSMutableArray array];
    for (NSValue *value in valueOfCoors) {
        CLLocationCoordinate2D coor;
        [value getValue:&coor];
        [arry addObject:[AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude]];
    }
    if (arry.count>2) {
        poiRequest.polygon = [AMapGeoPolygon polygonWithPoints:arry];
    }
     [self.search performSelector:@selector(AMapPlaceSearch:) withObject:poiRequest afterDelay:.1f];
    return poiRequest;
}

/*!
 @brief 通知查询成功或失败的回调函数
 @param searchRequest 发起的查询
 @param errInfo 错误信息
 */

- (void)search:(id)searchRequest error:(NSString*)errInfo{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],errInfo);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:searchRequest forKey:MAPSEARCHKEY_REQUEST];
    
    if ([errInfo notEmpty]) {
        [dic setObject:errInfo forKey:MAPSEARCHKEY_Error];
    }
    if ([searchRequest respondsToSelector:@selector(tagString)]) {
        NSString *tags = [searchRequest valueForKey:@"tagString"];
        if ([tags notEmpty]) {
            [dic setObject:tags forKey:MAPSEARCHKEY_TagString];
        }
    }
    
    [self postNotification:self.MapSearchReturn withObject:dic];
}

/*!
 @brief POI 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapPlaceSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapPlaceSearchResponse类中的定义)
 */
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],response);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:request forKey:MAPSEARCHKEY_REQUEST];
    
    if (response) {
        [dic setObject:response forKey:MAPSEARCHKEY_RESPONSE];
    }
    if ([request respondsToSelector:@selector(tagString)]) {
        NSString *tags = [request valueForKey:@"tagString"];
        if ([tags notEmpty]) {
             [dic setObject:tags forKey:MAPSEARCHKEY_TagString];
        }
    }
    
    [self postNotification:self.MapSearchReturn withObject:dic];
}

#pragma mark -
#pragma mark 路径规划
//type 0:walk  1:bus 2:drive
//查公交路径 需要添加 naviRequest.city = @"beijing"; 
- (AMapNavigationSearchRequest*)searchNavi:(NSInteger)type origin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)dest
{
    AMapNavigationSearchRequest *naviRequest= [[AMapNavigationSearchRequest alloc] init];
    switch (type) {
        case 0:
            naviRequest.searchType = AMapSearchType_NaviWalking;
            break;
        case 1:
            naviRequest.searchType = AMapSearchType_NaviBus;
            break;
        default:
            naviRequest.searchType = AMapSearchType_NaviDrive;
            break;
    }
    
    naviRequest.requireExtension = YES;
    naviRequest.origin = [AMapGeoPoint locationWithLatitude:origin.latitude longitude:origin.longitude];
    naviRequest.destination = [AMapGeoPoint locationWithLatitude:dest.latitude longitude:dest.longitude];
    [self.search performSelector:@selector(AMapNavigationSearch:) withObject:naviRequest afterDelay:.1f];
    return naviRequest;
}
    
/*!
 @brief 导航 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapNavigationSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapNavigationSearchResponse类中的定义)
 */
- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],response);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:request forKey:MAPSEARCHKEY_REQUEST];
    
    if (response) {
        [dic setObject:response forKey:MAPSEARCHKEY_RESPONSE];
    }
    if ([request respondsToSelector:@selector(tagString)]) {
        NSString *tags = [request valueForKey:@"tagString"];
        if ([tags notEmpty]) {
             [dic setObject:tags forKey:MAPSEARCHKEY_TagString];
        }
    }
    
    [self postNotification:self.MapSearchReturn withObject:dic];
}

#pragma mark -
#pragma mark 输入提示
- (HMAMapInputTipsSearchRequest*)searchInputTips:(NSString*)keys inCities:(NSArray*)cities{
    HMAMapInputTipsSearchRequest *poiRequest = [[[HMAMapInputTipsSearchRequest alloc] init]autoreleaseARC];
    poiRequest.searchType = AMapSearchType_InputTips;
    poiRequest.keywords = keys;
    poiRequest.city = cities;
    [self.search performSelector:@selector(AMapInputTipsSearch:) withObject:poiRequest afterDelay:.1f];
    return poiRequest;
}

/*!
 @brief 输入提示 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapInputTipsSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapInputTipsSearchResponse类中的定义)
 */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],response);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:request forKey:MAPSEARCHKEY_REQUEST];
    
    if (response) {
        [dic setObject:response forKey:MAPSEARCHKEY_RESPONSE];
    }
    if ([request respondsToSelector:@selector(tagString)]) {
        NSString *tags = [request valueForKey:@"tagString"];
        if ([tags notEmpty]) {
             [dic setObject:tags forKey:MAPSEARCHKEY_TagString];
        }
    }
    
    [self postNotification:self.MapSearchReturn withObject:dic];
}

#pragma mark -
#pragma mark 地理编码 address》》coor

- (HMAMapGeocodeSearchRequest*)searchGeocodeAddress:(NSString *)address inCities:(NSArray*)cities
{
    HMAMapGeocodeSearchRequest *regeoRequest = [[[HMAMapGeocodeSearchRequest alloc] init]autoreleaseARC];
    regeoRequest.searchType = AMapSearchType_Geocode;
    regeoRequest.city = cities;
    regeoRequest.address = address;
    [self.search performSelector:@selector(AMapGeocodeSearch:) withObject:regeoRequest afterDelay:.1f];
    return regeoRequest;
}

/*!
 @brief 地理编码 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapGeocodeSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapGeocodeSearchResponse类中的定义)
 */
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],response);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:request forKey:MAPSEARCHKEY_REQUEST];
    
    if (response) {
        [dic setObject:response forKey:MAPSEARCHKEY_RESPONSE];
    }
    if ([request respondsToSelector:@selector(tagString)]) {
        NSString *tags = [request valueForKey:@"tagString"];
        if ([tags notEmpty]) {
             [dic setObject:tags forKey:MAPSEARCHKEY_TagString];
        }
    }
    
    [self postNotification:self.MapSearchReturn withObject:dic];
}

#pragma mark -
#pragma mark 逆地理编码 coor 》》 address
- (HMAMapReGeocodeSearchRequest*)searchReGeocode:(CLLocationCoordinate2D)coor radius:(NSInteger)radius
{
    if (!CLLocationCoordinate2DIsValid(coor)) {
        return nil;
    }
    HMAMapReGeocodeSearchRequest *regeoRequest = [[[HMAMapReGeocodeSearchRequest alloc] init]autoreleaseARC];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude];
    regeoRequest.radius = radius;
    regeoRequest.requireExtension = YES;
    [self.search performSelector:@selector(AMapReGoecodeSearch:) withObject:regeoRequest afterDelay:.1f];
    return regeoRequest;
}
/*!
 @brief 逆地理编码 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapReGeocodeSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapReGeocodeSearchResponse类中的定义)
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],response);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:request forKey:MAPSEARCHKEY_REQUEST];
    
    if (response) {
        [dic setObject:response forKey:MAPSEARCHKEY_RESPONSE];
    }
    if ([request respondsToSelector:@selector(tagString)]) {
        NSString *tags = [request valueForKey:@"tagString"];
        if ([tags notEmpty]) {
            if ([tags isEqualToString:@"SearchLocation"]) {
                self.lastSearchResult = response;
            }
             [dic setObject:tags forKey:MAPSEARCHKEY_TagString];
        }
    }
    
    [self postNotification:self.MapSearchReturn withObject:dic];
}

#pragma mark -
#pragma mark 公交线路

- (HMAMapBusLineSearchRequest*)searchLineByID:(NSString *)uid keyworks:(NSString*)keys
{
    HMAMapBusLineSearchRequest *lineRequest = [[[HMAMapBusLineSearchRequest alloc] init]autoreleaseARC];
    lineRequest.searchType = AMapSearchType_LineID;
    lineRequest.uid = uid;
    lineRequest.keywords = keys;
    [self.search performSelector:@selector(AMapBusLineSearch:) withObject:lineRequest afterDelay:.1f];
    return lineRequest;
}

/*!
 @brief 公交线路 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapBusLineSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapBusLineSearchResponse类中的定义)
 */
- (void)onBusLineSearchDone:(AMapBusLineSearchRequest *)request response:(AMapBusLineSearchResponse *)response{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],response);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:request forKey:MAPSEARCHKEY_REQUEST];
    
    if (response) {
        [dic setObject:response forKey:MAPSEARCHKEY_RESPONSE];
    }
    if ([request respondsToSelector:@selector(tagString)]) {
        NSString *tags = [request valueForKey:@"tagString"];
        if ([tags notEmpty]) {
             [dic setObject:tags forKey:MAPSEARCHKEY_TagString];
        }
    }
    
    [self postNotification:self.MapSearchReturn withObject:dic];
}

#pragma mark -
#pragma mark 公交站点

- (HMAMapBusStopSearchRequest*)searchBusstop:(NSString*)keys inCities:(NSArray*)cities
{
    HMAMapBusStopSearchRequest *stopRequest = [[[HMAMapBusStopSearchRequest alloc] init]autoreleaseARC];
    stopRequest.keywords = keys;
    stopRequest.city = cities;
    [self.search performSelector:@selector(AMapBusStopSearch:) withObject:stopRequest afterDelay:.1f];
    return stopRequest;
}

/*!
 @brief 公交站 查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapBusStopSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapBusStopSearchResponse类中的定义)
 */
- (void)onBusStopSearchDone:(AMapBusStopSearchRequest *)request response:(AMapBusStopSearchResponse *)response{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],response);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:request forKey:MAPSEARCHKEY_REQUEST];
    
    if (response) {
        [dic setObject:response forKey:MAPSEARCHKEY_RESPONSE];
    }
    if ([request respondsToSelector:@selector(tagString)]) {
        NSString *tags = [request valueForKey:@"tagString"];
        if ([tags notEmpty]) {
             [dic setObject:tags forKey:MAPSEARCHKEY_TagString];
        }
    }
    
    [self postNotification:self.MapSearchReturn withObject:dic];
}
@end
