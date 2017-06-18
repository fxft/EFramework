//
//  HMUILinearGradientFillStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUILinearGradientFillStyle.h"

@implementation HMUILinearGradientFillStyle

@synthesize color1 = _color1;
@synthesize color2 = _color2;
@synthesize angle = _angle;

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
+ (HMUILinearGradientFillStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                                          angle:(CGFloat)angle
                                           next:(HMUIStyle*)next {
    HMUILinearGradientFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.color1 = color1;
    style.color2 = color2;
    style.angle = angle;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUILinearGradientFillStyle*)styleWithColor1:(UIColor*)color1 color2:(UIColor*)color2
                                         next:(HMUIStyle*)next {
    return [HMUILinearGradientFillStyle styleWithColor1:color1 color2:color2 angle:0.f next:next];
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
    [context.shape addToPath:rect];
    CGContextClip(ctx);
    
    UIColor __autoreleasing_type * colors[] = {_color1, _color2};
    CGGradientRef gradient = [HMUIStyle newGradientWithColors:colors count:2];
    
    CGFloat tx = 0.f;
    CGFloat ty = 0.f;
    if (_angle==0.f) {
        ty = rect.size.height;
    }else if (_angle==90.f) {
        tx = rect.size.width;
    }else if (_angle==45.f){
        ty = rect.size.width;
        tx = rect.size.width;
    }
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(rect.origin.x, rect.origin.y),
                                CGPointMake(rect.origin.x+tx, rect.origin.y+ty),
                                kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(ctx);
    
    return [self.next draw:context];
}


@end
