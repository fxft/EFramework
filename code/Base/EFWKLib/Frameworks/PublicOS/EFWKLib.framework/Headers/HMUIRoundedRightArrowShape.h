//
//  HMUIRoundedRightArrowShape.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIShape.h"

@interface HMUIRoundedRightArrowShape : HMUIShape

@property (nonatomic) CGFloat radius;

+ (HMUIRoundedRightArrowShape*)shapeWithRadius:(CGFloat)radius;

@end
