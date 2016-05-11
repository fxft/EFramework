//
//  HMUIPathShape.m
//  EFExtend
//
//  Created by mac on 15/7/6.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUIPathShape.h"

@interface HMUIPathShape ()

@property (nonatomic,copy) ShapePathAction pathRef;

@end

@implementation HMUIPathShape

+ (HMUIPathShape *)shapeWithPath:(ShapePathAction)path{
    HMUIPathShape *shape = [HMUIPathShape shape];
    shape.pathRef = path;
    return shape;
}

- (void)dealloc
{
    self.pathRef = NULL;
    HM_SUPER_DEALLOC();
}

- (void)addToPath:(CGRect)rect{
    if (self.pathRef==NULL) {
        return;
    }
    [self openPath:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    self.pathRef(context,rect);
    
    [self closePath:rect];
}


@end
