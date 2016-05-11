//
//  HMUIStyleSheet.h
//  CarAssistant
//
//  Created by Eric on 14-3-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIStyleSheet : HMUIStyle

//立体感
+ (HMUIStyle*)badgeExtrudeWithFillColor:(UIColor*)color;

//扁平化
+ (HMUIStyle*)badgeFlattenWithFillColor:(UIColor*)color;

//扁平化,带边框
+ (HMUIStyle *)badgeFlattenBorderWithFillColor:(UIColor *)color;

//扁平化,带边框颜色宽度自定义
+ (HMUIStyle *)badgeFlattenBorderWithFillColor:(UIColor *)color border:(UIColor*)colorb width:(CGFloat)width;

@end
