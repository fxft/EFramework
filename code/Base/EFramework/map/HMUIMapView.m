//
//  HMUIMapView.m
//  CarAssistant
//
//  Created by Eric on 14-4-1.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIMapView.h"

@implementation HMUIMapView

@end

HM_EXTERN_C_BEGIN

void mapInitRange(CLLocationCoordinate2D* minCoor,CLLocationCoordinate2D*  maxCoor){
    *minCoor = CLLocationCoordinate2DMake(180.f, 180.f);
    *maxCoor = CLLocationCoordinate2DMake(-180.f, -180.f);
}

void mapRangeForCoordinate(CLLocationCoordinate2D coordinate ,CLLocationCoordinate2D minCoor ,CLLocationCoordinate2D maxCoor){
    maxCoor.latitude = MAX(coordinate.latitude,maxCoor.latitude);
    maxCoor.longitude = MAX(coordinate.longitude, maxCoor.longitude);
    minCoor.latitude = MIN(coordinate.latitude, minCoor.latitude);
    minCoor.longitude = MIN(coordinate.longitude, minCoor.longitude);
}

MSOMapRect mapRectForRange(CLLocationCoordinate2D minCoor ,CLLocationCoordinate2D maxCoor){
    MSOMapPoint point = MSOMapPointForCoordinate(minCoor);
    MSOMapPoint point2 = MSOMapPointForCoordinate(maxCoor);
    MSOMapRect reck = MSOMapRectMake(point.x, point2.y, point2.x-point.x, point.y-point2.y);
    return reck;
}

CLLocationCoordinate2D mapCenterForRange(CLLocationCoordinate2D minCoor ,CLLocationCoordinate2D maxCoor){
    return CLLocationCoordinate2DMake((minCoor.latitude+maxCoor.latitude)/2, (minCoor.longitude+maxCoor.longitude)/2);
}

HM_EXTERN_C_END