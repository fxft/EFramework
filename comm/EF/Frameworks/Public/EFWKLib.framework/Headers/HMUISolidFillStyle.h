//
//  HMUISolidFillStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUISolidFillStyle : HMUIStyle{
    UIColor* _color;
}

@property (nonatomic, HM_STRONG) UIColor* color;

+ (HMUISolidFillStyle*)styleWithColor:(UIColor*)color next:(HMUIStyle*)next;

@end
