//
//  HMUIBevelBorderStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIBevelBorderStyle.h"

@implementation HMUIBevelBorderStyle

@synthesize highlight   = _highlight;
@synthesize shadow      = _shadow;
@synthesize width       = _width;
@synthesize lightSource = _lightSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(HMUIStyle*)next {
	self = [super initWithNext:next];
    if (self) {
        _width = 1;
        _lightSource = kDefaultLightSource;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_highlight release];
    [_shadow release];
    
    HM_SUPER_DEALLOC();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIBevelBorderStyle*)styleWithColor:(UIColor*)color width:(CGFloat)width next:(HMUIStyle*)next {
    return [self styleWithHighlight:[color highlight] shadow:[color shadow] width:width
                        lightSource:kDefaultLightSource next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIBevelBorderStyle*)styleWithHighlight:(UIColor*)highlight
                                   shadow:(UIColor*)shadowColor
                                    width:(CGFloat)width
                              lightSource:(NSInteger)lightSource
                                     next:(HMUIStyle*)next {
    HMUIBevelBorderStyle* style = [[[HMUIBevelBorderStyle alloc] initWithNext:next] autorelease];
    style.highlight = highlight;
    style.shadow = shadowColor;
    style.width = width;
    style.lightSource = lightSource;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark HMUIStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    CGRect strokeRect = CGRectInset(context.frame, _width/2, _width/2);
    [context.shape openPath:strokeRect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, _width);
    
    UIColor* topColor = _lightSource >= 0 && _lightSource <= 180 ? _highlight : _shadow;
    UIColor* leftColor = _lightSource >= 90 && _lightSource <= 270
    ? _highlight : _shadow;
    UIColor* bottomColor = (_lightSource >= 180 && _lightSource <= 360) || _lightSource == 0
    ? _highlight : _shadow;
    UIColor* rightColor = (_lightSource >= 270 && _lightSource <= 360)
    || (_lightSource >= 0 && _lightSource <= 90)
    ? _highlight : _shadow;
    
    CGRect rect = context.frame;
    
    [context.shape addTopEdgeToPath:strokeRect lightSource:_lightSource];
    if (topColor) {
        [topColor setStroke];
        
        rect.origin.y += _width;
        rect.size.height -= _width;
        
    } else {
        [[UIColor clearColor] setStroke];
    }
    CGContextStrokePath(ctx);
    
    [context.shape addRightEdgeToPath:strokeRect lightSource:_lightSource];
    if (rightColor) {
        [rightColor setStroke];
        
        rect.size.width -= _width;
        
    } else {
        [[UIColor clearColor] setStroke];
    }
    CGContextStrokePath(ctx);
    
    [context.shape addBottomEdgeToPath:strokeRect lightSource:_lightSource];
    if (bottomColor) {
        [bottomColor setStroke];
        
        rect.size.height -= _width;
        
    } else {
        [[UIColor clearColor] setStroke];
    }
    CGContextStrokePath(ctx);
    
    [context.shape addLeftEdgeToPath:strokeRect lightSource:_lightSource];
    if (leftColor) {
        [leftColor setStroke];
        
        rect.origin.x += _width;
        rect.size.width -= _width;
        
    } else {
        [[UIColor clearColor] setStroke];
    }
    CGContextStrokePath(ctx);
    
    CGContextRestoreGState(ctx);
    
    context.frame = rect;
    return [self.next draw:context];
}
@end
