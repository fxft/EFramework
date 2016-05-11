//
//  HMUILinearGradientFillStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUILinearGradientFillStyle : HMUIStyle{
    UIColor* _color1;
    UIColor* _color2;
    CGFloat  _angle;
}

@property (nonatomic, HM_STRONG) UIColor* color1;
@property (nonatomic, HM_STRONG) UIColor* color2;
@property (nonatomic) CGFloat    angle;//0{|}  90{-} 45{\}


+ (HMUILinearGradientFillStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                                         next:(HMUIStyle*)next;

+ (HMUILinearGradientFillStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                                          angle:(CGFloat)angle
                                           next:(HMUIStyle*)next;

@end
