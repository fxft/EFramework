//
//  HMUIRectangleShape.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIRectangleShape.h"

@implementation HMUIRectangleShape

#pragma mark -
#pragma mark Public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addToPath:(CGRect)rect {
    [self openPath:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    [self closePath:rect];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addInverseToPath:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat fw = rect.size.width;
    CGFloat fh = rect.size.height;
    
    CGFloat width = 5.0f;
    CGRect shadowRect = CGRectMake(-width, -width, fw+width*2, fh+width*2);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, shadowRect);
    CGPathCloseSubpath(path);
    
    CGPathAddRect(path, nil, rect);
    CGPathCloseSubpath(path);
    
    [self openPath:rect];
    CGContextAddPath(context, path);
    [self closePath:rect];
    
    CGPathRelease(path);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat fw = rect.size.width;
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, fw, 0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat fw = rect.size.width;
    CGFloat fh = rect.size.height;
    
    CGContextMoveToPoint(context, fw, 0);
    CGContextAddLineToPoint(context, fw, fh);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat fw = rect.size.width;
    CGFloat fh = rect.size.height;
    
    CGContextMoveToPoint(context, fw, fh);
    CGContextAddLineToPoint(context, 0, fh);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat fh = rect.size.height;
    
    CGContextMoveToPoint(context, 0, fh);
    CGContextAddLineToPoint(context, 0, 0);
}

@end
