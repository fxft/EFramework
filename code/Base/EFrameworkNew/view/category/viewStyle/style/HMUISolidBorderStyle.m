//
//  HMUISolidBorderStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUISolidBorderStyle.h"

@implementation HMUISolidBorderStyle

@synthesize color = _color;
@synthesize width = _width;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(HMUIStyle*)next {
	self = [super initWithNext:next];
    if (self) {
        _width = 1;
    }
    
    return self;
}


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
+ (HMUISolidBorderStyle*)styleWithColor:(UIColor*)color width:(CGFloat)width next:(HMUIStyle*)next {
    HMUISolidBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.color = color;
    style.width = width;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark HMUIStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect strokeRect = CGRectInset(context.frame, _width/2, _width/2);
    [context.shape addToPath:strokeRect];
    
    [_color setStroke];
    CGContextSetLineWidth(ctx, _width);
    CGContextStrokePath(ctx);
    
    CGContextRestoreGState(ctx);
    
    context.frame = CGRectInset(context.frame, _width, _width);
    return [self.next draw:context];
}

@end
