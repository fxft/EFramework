//
//  HMUIShapeStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@class HMUIShape;

@interface HMUIShapeStyle : HMUIStyle{
    HMUIShape* _shape;
}

@property (nonatomic, HM_STRONG) HMUIShape* shape;

+ (HMUIShapeStyle*)styleWithShape:(HMUIShape*)shape next:(HMUIStyle*)next;

@end
