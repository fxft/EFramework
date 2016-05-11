//
//  HMUIRoundedRectangleShape.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIRoundedRectangleShape.h"

@implementation HMUIRoundedRectangleShape{
    CGFloat _topLeftRadius;
    CGFloat _topRightRadius;
    CGFloat _bottomRightRadius;
    CGFloat _bottomLeftRadius;
}
@synthesize topLeftRadius     = _topLeftRadius;
@synthesize topRightRadius    = _topRightRadius;
@synthesize bottomRightRadius = _bottomRightRadius;
@synthesize bottomLeftRadius  = _bottomLeftRadius;

#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIRoundedRectangleShape*)shapeWithRadius:(CGFloat)radius {
    HMUIRoundedRectangleShape* shape = [HMUIRoundedRectangleShape shape];
    shape.topLeftRadius = shape.topRightRadius = shape.bottomRightRadius = shape.bottomLeftRadius
    = radius;
    return shape;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIRoundedRectangleShape*)shapeWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight
                                 bottomRight:(CGFloat)bottomRight bottomLeft:(CGFloat)bottomLeft {
    HMUIRoundedRectangleShape* shape = [HMUIRoundedRectangleShape shape];
    shape.topLeftRadius = topLeft;
    shape.topRightRadius = topRight;
    shape.bottomRightRadius = bottomRight;
    shape.bottomLeftRadius = bottomLeft;
    
    return shape;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addToPath:(CGRect)rect {
    [self openPath:rect];
    
    CGFloat fw = rect.size.width;
    CGFloat fh = rect.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, fw, floor(fh/2));
    CGContextAddArcToPoint(context, fw, fh, floor(fw/2), fh, RD(_bottomRightRadius));
    CGContextAddArcToPoint(context, 0, fh, 0, floor(fh/2), RD(_bottomLeftRadius));
    CGContextAddArcToPoint(context, 0, 0, floor(fw/2), 0, RD(_topLeftRadius));
    CGContextAddArcToPoint(context, fw, 0, fw, floor(fh/2), RD(_topRightRadius));
    
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
    
    CGPathMoveToPoint(path, nil, fw, floor(fh/2));
    CGPathAddArcToPoint(path, nil, fw, fh, floor(fw/2), fh, RD(_bottomRightRadius));
    CGPathAddArcToPoint(path, nil, 0, fh, 0, floor(fh/2), RD(_bottomLeftRadius));
    CGPathAddArcToPoint(path, nil, 0, 0, floor(fw/2), 0, RD(_topLeftRadius));
    CGPathAddArcToPoint(path, nil, fw, 0, fw, floor(fh/2), RD(_topRightRadius));
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
    CGFloat fh = rect.size.height;
    
    if (lightSource >= 0 && lightSource <= 90) {
        CGContextMoveToPoint(context, RD(_topLeftRadius), 0);
        
    } else {
        CGContextMoveToPoint(context, 0, RD(_topLeftRadius));
        CGContextAddArcToPoint(context, 0, 0, RD(_topLeftRadius), 0, RD(_topLeftRadius));
    }
    CGContextAddArcToPoint(context, fw, 0, fw, RD(_topRightRadius), RD(_topRightRadius));
    CGContextAddLineToPoint(context, fw, RD(_topRightRadius));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat fw = rect.size.width;
    CGFloat fh = rect.size.height;
    
    CGContextMoveToPoint(context, fw, RD(_topRightRadius));
    CGContextAddArcToPoint(context, fw, fh, fw-RD(_bottomRightRadius), fh, RD(_bottomRightRadius));
    CGContextAddLineToPoint(context, fw-RD(_bottomRightRadius), fh);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat fw = rect.size.width;
    CGFloat fh = rect.size.height;
    
    CGContextMoveToPoint(context, fw-RD(_bottomRightRadius), fh);
    CGContextAddLineToPoint(context, RD(_bottomLeftRadius), fh);
    CGContextAddArcToPoint(context, 0, fh, 0, fh-RD(_bottomLeftRadius), RD(_bottomLeftRadius));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat fh = rect.size.height;
    
    CGContextMoveToPoint(context, 0, fh-RD(_bottomLeftRadius));
    CGContextAddLineToPoint(context, 0, RD(_topLeftRadius));
    
    if (lightSource >= 0 && lightSource <= 90) {
        CGContextAddArcToPoint(context, 0, 0, RD(_topLeftRadius), 0, RD(_topLeftRadius));
    }
}

@end
