//
//  HMUIMaskStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIMaskStyle.h"

@implementation HMUIMaskStyle

@synthesize mask = _mask;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_mask release];
    
    HM_SUPER_DEALLOC();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIMaskStyle*)styleWithMask:(UIImage*)mask next:(HMUIStyle*)next {
    HMUIMaskStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.mask = mask;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark HMUIStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    if (_mask) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        // Translate context upside-down to invert the clip-to-mask, which turns the mask upside down
        CGContextTranslateCTM(ctx, 0, context.frame.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        CGRect maskRect = CGRectMake(0, 0, _mask.size.width, _mask.size.height);
        CGContextClipToMask(ctx, maskRect, _mask.CGImage);
        
        [self.next draw:context];
        CGContextRestoreGState(ctx);
        
    } else {
        return [self.next draw:context];
    }
}

@end
