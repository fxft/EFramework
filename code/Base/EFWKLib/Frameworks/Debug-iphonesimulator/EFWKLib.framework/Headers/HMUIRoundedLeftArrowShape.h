//
//  HMUIRoundedLeftArrowShape.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIShape.h"

@interface HMUIRoundedLeftArrowShape : HMUIShape{
    CGFloat _radius;
}

@property (nonatomic) CGFloat radius;

+ (HMUIRoundedLeftArrowShape*)shapeWithRadius:(CGFloat)radius;

@end
