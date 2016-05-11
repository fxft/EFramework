//
//  HMUIRoundedRectangleShape.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIShape.h"


@interface HMUIRoundedRectangleShape : HMUIShape

@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;

+ (HMUIRoundedRectangleShape*)shapeWithRadius:(CGFloat)radius;

+ (HMUIRoundedRectangleShape*)shapeWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight
                                 bottomRight:(CGFloat)bottomRight bottomLeft:(CGFloat)bottomLeft;

@end
