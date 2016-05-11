//
//  HMUILinearGradientBorderStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUILinearGradientBorderStyle.h"

@implementation HMUILinearGradientBorderStyle

@synthesize color1    = _color1;
@synthesize color2    = _color2;
@synthesize location1 = _location1;
@synthesize location2 = _location2;
@synthesize width     = _width;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(HMUIStyle*)next {
	self = [super initWithNext:next];
    if (self) {
        _location2 = 1;
        _width = 1;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_color1 release];
    [_color2 release];
    
    HM_SUPER_DEALLOC();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUILinearGradientBorderStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                                          width:(CGFloat)width next:(HMUIStyle*)next {
    HMUILinearGradientBorderStyle* style = [[[HMUILinearGradientBorderStyle alloc] initWithNext:next]
                                            autorelease];
    style.color1 = color1;
    style.color2 = color2;
    style.width = width;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUILinearGradientBorderStyle*)styleWithColor1:(UIColor*)color1 location1:(CGFloat)location1
                                         color2:(UIColor*)color2 location2:(CGFloat)location2
                                          width:(CGFloat)width next:(HMUIStyle*)next {
    HMUILinearGradientBorderStyle* style = [[[HMUILinearGradientBorderStyle alloc] initWithNext:next]
                                            autorelease];
    style.color1 = color1;
    style.color2 = color2;
    style.width = width;
    style.location1 = location1;
    style.location2 = location2;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = context.frame;
    
    CGContextSaveGState(ctx);
    
    CGRect strokeRect = CGRectInset(context.frame, _width/2, _width/2);
    [context.shape addToPath:strokeRect];
    CGContextSetLineWidth(ctx, _width);
    CGContextReplacePathWithStrokedPath(ctx);
    CGContextClip(ctx);
    
    UIColor __autoreleasing_type * colors[] = {_color1, _color2};
    CGFloat locations[] = {_location1, _location2};
    CGGradientRef gradient = [HMUIStyle newGradientWithColors:colors locations:locations count:2];
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(rect.origin.x, rect.origin.y),
                                CGPointMake(rect.origin.x, rect.origin.y+rect.size.height),
                                kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(ctx);
    
    context.frame = CGRectInset(context.frame, _width, _width);
    return [self.next draw:context];
}

@end
