//
//  HMUIHighlightBorderStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIHighlightBorderStyle : HMUIStyle{
    UIColor*  _color;
    UIColor*  _highlightColor;
    CGFloat   _width;
}

@property (nonatomic, HM_STRONG) UIColor*  color;
@property (nonatomic, HM_STRONG) UIColor*  highlightColor;
@property (nonatomic)         CGFloat   width;

+ (HMUIHighlightBorderStyle*)styleWithColor:(UIColor*)color highlightColor:(UIColor*)highlightColor
                                    width:(CGFloat)width next:(HMUIStyle*)next;

@end
