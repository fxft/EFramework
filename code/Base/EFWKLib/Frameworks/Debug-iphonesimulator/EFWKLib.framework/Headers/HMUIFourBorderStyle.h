//
//  HMUIFourBorderStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIFourBorderStyle : HMUIStyle{
    UIColor*  _top;
    UIColor*  _right;
    UIColor*  _bottom;
    UIColor*  _left;
    CGFloat   _width;
}

@property (nonatomic, HM_STRONG) UIColor*  top;
@property (nonatomic, HM_STRONG) UIColor*  right;
@property (nonatomic, HM_STRONG) UIColor*  bottom;
@property (nonatomic, HM_STRONG) UIColor*  left;
@property (nonatomic)         CGFloat   width;

+ (HMUIFourBorderStyle*)styleWithTop:(UIColor*)top right:(UIColor*)right bottom:(UIColor*)bottom
                              left:(UIColor*)left width:(CGFloat)width next:(HMUIStyle*)next;
+ (HMUIFourBorderStyle*)styleWithTop:(UIColor*)top width:(CGFloat)width next:(HMUIStyle*)next;
+ (HMUIFourBorderStyle*)styleWithRight:(UIColor*)right width:(CGFloat)width next:(HMUIStyle*)next;
+ (HMUIFourBorderStyle*)styleWithBottom:(UIColor*)bottom width:(CGFloat)width next:(HMUIStyle*)next;
+ (HMUIFourBorderStyle*)styleWithLeft:(UIColor*)left width:(CGFloat)width next:(HMUIStyle*)next;

@end
