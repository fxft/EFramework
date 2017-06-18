//
//  HMUIMapView.h
//  CarAssistant
//
//  Created by Eric on 14-4-1.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GGMapView.h"
#import "HMMapCalloutView.h"

@interface HMUIMapView : NSObject



@end
/*用于计算经纬度集合的边界与中点
 mapInitRange 初始化
 mapRangeForCoordinate 循环计算
 mapRectForRange 转换成可视区域
 mapCenterForRange 计算中点
 eg.
 
 CLLocationCoordinate2D minCoor;
 CLLocationCoordinate2D maxCoor;
 mapInitRange(&minCoor,&maxCoor);
 for(CLLocationCoordinate2D coor in [??]){
    mapRangeForCoordinate(coor,minCoor,maxCoor);
 }
 MSOMapRect rect = mapRectForRange(minCoor,maxCoor);
 CLLocationCoordinate2D centerCoor = mapCenterForRange(minCoor,maxCoor);
 
 */
HM_EXTERN void mapInitRange(CLLocationCoordinate2D* minCoor,CLLocationCoordinate2D*  maxCoor);
HM_EXTERN void mapRangeForCoordinate(CLLocationCoordinate2D coordinate ,CLLocationCoordinate2D* minCoor ,CLLocationCoordinate2D* maxCoor);
HM_EXTERN MSOMapRect mapRectForRange(CLLocationCoordinate2D minCoor ,CLLocationCoordinate2D maxCoor);
HM_EXTERN CLLocationCoordinate2D mapCenterForRange(CLLocationCoordinate2D minCoor ,CLLocationCoordinate2D maxCoor);
