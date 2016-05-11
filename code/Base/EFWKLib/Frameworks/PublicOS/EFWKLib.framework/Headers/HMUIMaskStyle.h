//
//  HMUIMaskStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIMaskStyle : HMUIStyle{
    UIImage* _mask;
}

@property (nonatomic, HM_STRONG) UIImage* mask;

+ (HMUIMaskStyle*)styleWithMask:(UIImage*)mask next:(HMUIStyle*)next;

@end
