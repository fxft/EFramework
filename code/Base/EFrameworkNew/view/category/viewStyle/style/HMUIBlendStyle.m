//
//  HMUIBlendStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIBlendStyle.h"

@implementation HMUIBlendStyle
@synthesize blendMode = _blendMode;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(HMUIStyle*)next {
	self = [super initWithNext:next];
    if (self) {
        _blendMode = kCGBlendModeNormal;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIBlendStyle*)styleWithBlend:(CGBlendMode)blendMode next:(HMUIStyle*)next {
    HMUIBlendStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.blendMode = blendMode;    
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark HMUIStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    if (_blendMode) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextSetBlendMode(ctx, _blendMode);
        
        [self.next draw:context];
        CGContextRestoreGState(ctx);
        
    } else {
        return [self.next draw:context];
    }
}

@end
