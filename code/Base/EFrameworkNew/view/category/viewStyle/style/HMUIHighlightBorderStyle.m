//
//  HMUIHighlightBorderStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIHighlightBorderStyle.h"

@implementation HMUIHighlightBorderStyle


@synthesize color           = _color;
@synthesize highlightColor  = _highlightColor;
@synthesize width           = _width;


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
    [_highlightColor release];
    
    HM_SUPER_DEALLOC();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIHighlightBorderStyle*)styleWithColor:(UIColor*)color highlightColor:(UIColor*)highlightColor
                                    width:(CGFloat)width next:(HMUIStyle*)next {
    HMUIHighlightBorderStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.color = color;
    style.highlightColor = highlightColor;
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
    
    {
        CGRect strokeRect = CGRectInset(context.frame, _width/2, _width/2);
        strokeRect.size.height-=2;
        strokeRect.origin.y++;
        [context.shape addToPath:strokeRect];
        
        [_highlightColor setStroke];
        CGContextSetLineWidth(ctx, _width);
        CGContextStrokePath(ctx);
    }
    
    {
        CGRect strokeRect = CGRectInset(context.frame, _width/2, _width/2);
        strokeRect.size.height-=2;
        [context.shape addToPath:strokeRect];
        
        [_color setStroke];
        CGContextSetLineWidth(ctx, _width);
        CGContextStrokePath(ctx);
    }
    
    context.frame = CGRectInset(context.frame, _width, _width * 2);
    return [self.next draw:context];
}


@end
