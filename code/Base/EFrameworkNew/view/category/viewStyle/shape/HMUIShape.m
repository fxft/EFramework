//
//  HMUIShape.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIShape.h"

@implementation HMUIShape

#pragma mark -
#pragma mark Public
const CGFloat ttkRounded = -1.0f;
const CGFloat kArrowPointWidth  = 2.8f;
const CGFloat kArrowRadius      = 2.0f;

+ (instancetype)shape{
    return [[[self alloc]init]autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
   
    }
    return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openPath:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextBeginPath(context);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)closePath:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)insetsForSize:(CGSize)size {
    return UIEdgeInsetsZero;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addToPath:(CGRect)rect {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addInverseToPath:(CGRect)rect {
}

@end
