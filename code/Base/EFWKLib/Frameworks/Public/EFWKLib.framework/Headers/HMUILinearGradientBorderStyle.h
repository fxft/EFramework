//
//  HMUILinearGradientBorderStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUILinearGradientBorderStyle : HMUIStyle{
    UIColor*  _color1;
    UIColor*  _color2;
    CGFloat   _location1;
    CGFloat   _location2;
    CGFloat   _width;
}

@property (nonatomic, HM_STRONG) UIColor*  color1;
@property (nonatomic, HM_STRONG) UIColor*  color2;
@property (nonatomic)         CGFloat   location1;
@property (nonatomic)         CGFloat   location2;
@property (nonatomic)         CGFloat   width;

+ (HMUILinearGradientBorderStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                                          width:(CGFloat)width next:(HMUIStyle*)next;
+ (HMUILinearGradientBorderStyle*)styleWithColor1:(UIColor*)color1 location1:(CGFloat)location1
                                         color2:(UIColor*)color2 location2:(CGFloat)location2
                                          width:(CGFloat)width next:(HMUIStyle*)next;



@end
