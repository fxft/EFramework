//
//  HMUIReflectiveFillStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIReflectiveFillStyle : HMUIStyle{
    UIColor*  _color;
    BOOL      _withBottomHighlight;
}

@property (nonatomic, HM_STRONG) UIColor* color;
@property (nonatomic) BOOL     withBottomHighlight;

+ (HMUIReflectiveFillStyle*)styleWithColor:(UIColor*)color next:(HMUIStyle*)next;
+ (HMUIReflectiveFillStyle*)styleWithColor:(UIColor*)color
                     withBottomHighlight:(BOOL)withBottomHighlight next:(HMUIStyle*)next;

@end
