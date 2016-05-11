//
//  HMUIBevelBorderStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIBevelBorderStyle : HMUIStyle{
    UIColor*  _highlight;
    UIColor*  _shadow;
    CGFloat   _width;
    NSInteger _lightSource;
}

@property (nonatomic, HM_STRONG) UIColor*  highlight;
@property (nonatomic, HM_STRONG) UIColor*  shadow;
@property (nonatomic)         CGFloat   width;
@property (nonatomic)         NSInteger lightSource;

+ (HMUIBevelBorderStyle*)styleWithColor:(UIColor*)color width:(CGFloat)width next:(HMUIStyle*)next;

+ (HMUIBevelBorderStyle*)styleWithHighlight:(UIColor*)highlight
                                   shadow:(UIColor*)shadow
                                    width:(CGFloat)width
                              lightSource:(NSInteger)lightSource
                                     next:(HMUIStyle*)next;

@end
