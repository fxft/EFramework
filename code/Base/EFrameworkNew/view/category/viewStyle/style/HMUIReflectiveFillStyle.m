//
//  HMUIReflectiveFillStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIReflectiveFillStyle.h"

@implementation HMUIReflectiveFillStyle

@synthesize color               = _color;
@synthesize withBottomHighlight = _withBottomHighlight;


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
+ (HMUIReflectiveFillStyle*)styleWithColor:(UIColor*)color next:(HMUIStyle*)next {
    HMUIReflectiveFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.color = color;
    style.withBottomHighlight = NO;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIReflectiveFillStyle*)styleWithColor:(UIColor*)color
                     withBottomHighlight:(BOOL)withBottomHighlight next:(HMUIStyle*)next {
    HMUIReflectiveFillStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.color = color;
    style.withBottomHighlight = withBottomHighlight;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark HMUIStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = context.frame;
    
    CGContextSaveGState(ctx);
    [context.shape addToPath:rect];
    CGContextClip(ctx);
    
    // Draw the background color
    [_color setFill];
    CGContextFillRect(ctx, rect);
    
    // The highlights are drawn using an overlayed, semi-transparent gradient.
    // The values here are absolutely arbitrary. They were nabbed by inspecting the colors of
    // the "Delete Contact" buHMUIon in the Contacts app.
    UIColor* topStartHighlight = [UIColor colorWithWhite:1.0 alpha:0.685];
    UIColor* topEndHighlight = [UIColor colorWithWhite:1.0 alpha:0.13];
    UIColor* clearColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    UIColor* botEndHighlight;
    if ( _withBottomHighlight ) {
        botEndHighlight = [UIColor colorWithWhite:1.0 alpha:0.27];
        
    } else {
        botEndHighlight = clearColor;
    }
    
    UIColor __autoreleasing_type* colors[] = {
        topStartHighlight, topEndHighlight,
        clearColor,
        clearColor, botEndHighlight};
    CGFloat locations[] = {0, 0.5, 0.5, 0.6, 1.0};
    
    CGGradientRef gradient = [HMUIStyle newGradientWithColors:colors locations:locations count:5];
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(rect.origin.x, rect.origin.y),
                                CGPointMake(rect.origin.x, rect.origin.y+rect.size.height), 0);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(ctx);
    
    return [self.next draw:context];
}
@end
