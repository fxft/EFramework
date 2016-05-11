//
//  HMUIShadowStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIShadowStyle : HMUIStyle{
    UIColor*  _color;
    CGFloat   _blur;
    CGSize    _offset;
}

@property (nonatomic, HM_STRONG) UIColor*  color;
@property (nonatomic)         CGFloat   blur;
@property (nonatomic)         CGSize    offset;

+ (HMUIShadowStyle*)styleWithColor:(UIColor*)color blur:(CGFloat)blur offset:(CGSize)offset
                            next:(HMUIStyle*)next;

@end
