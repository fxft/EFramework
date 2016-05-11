//
//  HMMapSearchAPI.h
//  WestLuckyStar
//
//  Created by Eric on 14-6-3.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@protocol HMAMapSearchRequestProtocol <NSObject>
@property (nonatomic, assign)   NSInteger tag;
@property (nonatomic, copy)   NSString * tagString;
@end

@interface HMAMapPlaceSearchRequest : AMapPlaceSearchRequest<HMAMapSearchRequestProtocol>
//区域查询循环添加范围边界点
- (void)addPolygonPoint:(CLLocationCoordinate2D)coor;
@end

@interface HMAMapInputTipsSearchRequest : AMapInputTipsSearchRequest<HMAMapSearchRequestProtocol>
@end

@interface HMAMapReGeocodeSearchRequest : AMapReGeocodeSearchRequest<HMAMapSearchRequestProtocol>
@end

@interface HMAMapGeocodeSearchRequest : AMapGeocodeSearchRequest<HMAMapSearchRequestProtocol>
@end

@interface HMAMapNavigationSearchRequest : AMapNavigationSearchRequest<HMAMapSearchRequestProtocol>
@end

@interface HMAMapBusStopSearchRequest : AMapBusStopSearchRequest<HMAMapSearchRequestProtocol>
@end

@interface HMAMapBusLineSearchRequest : AMapBusLineSearchRequest<HMAMapSearchRequestProtocol>
@end

#undef MAPSEARCHKEY_TagString
#define MAPSEARCHKEY_TagString @"SearchTagStringKey"

#undef MAPSEARCHKEY_REQUEST
#define MAPSEARCHKEY_REQUEST @"SearchRequestKey"

#undef MAPSEARCHKEY_Error
#define MAPSEARCHKEY_Error @"SearchErrorKey"

#undef MAPSEARCHKEY_RESPONSE
#define MAPSEARCHKEY_RESPONSE @"SearchResponseKey"

#define ON_NOTIFI_MapSearchAPI(noti) ON_NOTIFICATION3(HMMapSearchAPI, MapSearchReturn, noti)


@interface HMMapSearchAPI : NSObject

@property (nonatomic,HM_STRONG) id lastSearchResult;


AS_SINGLETON(HMMapSearchAPI)
//noti object contains MAPSEARCHKEY_TagString;MAPSEARCHKEY_REQUEST;MAPSEARCHKEY_RESPONSE
// 不同业务要用 MAPSEARCHKEY_TagString 或 MAPSEARCHKEY_REQUEST 区别
AS_NOTIFICATION(MapSearchReturn)

+ (void)resetWithKey:(NSString*)key;


//tagString is: @"SearchLocation"
- (void)doSearchLocationReloadIfTimeAgo:(NSTimeInterval)interval;

#pragma mark 逆地理编码 coor 》》 address
- (HMAMapReGeocodeSearchRequest*)searchReGeocode:(CLLocationCoordinate2D)coor radius:(NSInteger)radius;
#pragma mark 地理编码 address》》coor
- (HMAMapGeocodeSearchRequest*)searchGeocodeAddress:(NSString *)address inCities:(NSArray*)cities;

#pragma mark 输入提示
- (HMAMapInputTipsSearchRequest*)searchInputTips:(NSString*)keys inCities:(NSArray*)cities;

#pragma mark 路径规划
//type 0:walk  1:bus 2:drive
//查公交路径 需要添加 naviRequest.city = @"beijing";
- (AMapNavigationSearchRequest*)searchNavi:(NSInteger)type origin:(CLLocationCoordinate2D)origin destination:(CLLocationCoordinate2D)dest;

#pragma mark poi搜索

- (HMAMapPlaceSearchRequest*)searchPOIUid:(NSString*)uid;
//关键字
- (HMAMapPlaceSearchRequest*)searchPOIKeywords:(NSString*)keys inCities:(NSArray*)cities;
//周边
- (HMAMapPlaceSearchRequest*)searchPOIArround:(CLLocationCoordinate2D)coor keywords:(NSString*)keys radius:(NSInteger)radius;
//区域查询 可调用 - (void)addPolygonPoint:(CLLocationCoordinate2D)coor;
- (HMAMapPlaceSearchRequest*)searchPOIKeywords:(NSString*)keys byPolygon:(NSArray *)valueOfCoors;

#pragma mark 公交线路

- (HMAMapBusLineSearchRequest*)searchLineByID:(NSString *)uid keyworks:(NSString*)keys;

#pragma mark 公交站点

- (HMAMapBusStopSearchRequest*)searchBusstop:(NSString*)keys inCities:(NSArray*)cities;
@end
