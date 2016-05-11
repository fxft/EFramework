//
//  HMUIPathShape.h
//  EFExtend
//
//  Created by mac on 15/7/6.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUIShape.h"
typedef void(^ShapePathAction)(CGContextRef context,CGRect rect);

@interface HMUIPathShape : HMUIShape
+ (HMUIPathShape*)shapeWithPath:(ShapePathAction)path;


@end
