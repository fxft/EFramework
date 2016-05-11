//
//  HMUISolidBorderStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUISolidBorderStyle : HMUIStyle{
    UIColor*  _color;
    CGFloat   _width;
}

@property (nonatomic, HM_STRONG) UIColor*  color;
@property (nonatomic)         CGFloat   width;

+ (HMUISolidBorderStyle*)styleWithColor:(UIColor*)color width:(CGFloat)width next:(HMUIStyle*)next;

@end
