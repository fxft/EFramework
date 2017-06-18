//
//  HMUIInnerShadowStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIInnerShadowStyle.h"

@implementation HMUIInnerShadowStyle

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    [context.shape addToPath:context.frame];
    CGContextClip(ctx);
    
    [context.shape addInverseToPath:context.frame];
    [[UIColor whiteColor] setFill];
    
    // Due to a bug in OS versions 3.2 and 4.0, the shadow appears upside-down. It pains me to
    // write this, but a lot of research has failed to turn up a way to detect the flipped shadow
    // programmatically
    float shadowYOffset = -_offset.height;
//    NSString *osVersion = [UIDevice currentDevice].systemVersion;
//    if ([osVersion versionStringCompare:@"3.2"] != NSOrderedAscending) {
//        shadowYOffset = _offset.height;
//    }
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(_offset.width, shadowYOffset), _blur,
                                _color.CGColor);
    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    return [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(HMUIStyleContext*)context {
    if (_next) {
        return [self.next addToSize:size context:context];
        
    } else {
        return size;
    }
}

@end
