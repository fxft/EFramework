//
//  HMUIBlendStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIBlendStyle : HMUIStyle{
    CGBlendMode _blendMode;
}

@property (nonatomic) CGBlendMode blendMode;

+ (HMUIBlendStyle*)styleWithBlend:(CGBlendMode)blendMode next:(HMUIStyle*)next;


@end
