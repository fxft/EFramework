//
//  HMUISolidFillStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUISolidFillStyle.h"

@implementation HMUISolidFillStyle

@synthesize color = _color;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_color release];
    
    HM_SUPER_DEALLOC();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUISolidFillStyle*)styleWithColor:(UIColor*)color next:(HMUIStyle*)next {
    HMUISolidFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.color = color;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    [context.shape addToPath:context.frame];
    
    [_color setFill];
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    return [self.next draw:context];
}

@end