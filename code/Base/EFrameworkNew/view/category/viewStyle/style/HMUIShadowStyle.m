//
//  HMUIShadowStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIShadowStyle.h"

@implementation HMUIShadowStyle

@synthesize color   = _color;
@synthesize blur    = _blur;
@synthesize offset  = _offset;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(HMUIStyle*)next {
	self = [super initWithNext:next];
    if (self) {
        _offset = CGSizeZero;
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
+ (HMUIShadowStyle*)styleWithColor:(UIColor*)color blur:(CGFloat)blur offset:(CGSize)offset
                            next:(HMUIStyle*)next {
    HMUIShadowStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.color = color==nil?[UIColor blackColor]:color;
    style.blur = blur;
    style.offset = offset;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    CGFloat blurSize = round(_blur / 2);
    UIEdgeInsets inset = UIEdgeInsetsMake(blurSize, blurSize, blurSize, blurSize);
    if (_offset.width < 0) {
        inset.left += fabs(_offset.width);
        inset.right -= blurSize;
        
    } else if (_offset.width > 0) {
        inset.right += fabs(_offset.width);
        inset.left -= blurSize;
    }
    if (_offset.height < 0) {
        inset.top += fabs(_offset.height);
        inset.bottom -= blurSize;
        
    } else if (_offset.height > 0) {
        inset.bottom += fabs(_offset.height);
        inset.top -= blurSize;
    }
    
    context.frame = CGRectEdgeInsets(context.frame, inset);
    context.contentFrame = CGRectEdgeInsets(context.contentFrame, inset);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    // Due to a bug in OS versions 3.2 and 4.0, the shadow appears upside-down. It pains me to
    // write this, but a lot of research has failed to turn up a way to detect the flipped shadow
    // programmatically
    float shadowYOffset = _offset.height;
//    NSString *osVersion = [UIDevice currentDevice].systemVersion;
//    if ([osVersion versionStringCompare:@"3.2"] != NSOrderedAscending) {
//        shadowYOffset = _offset.height;
//    }
    
    [context.shape addToPath:context.frame];
    CGContextSetShadowWithColor(ctx, CGSizeMake(_offset.width, shadowYOffset), _blur,
                                _color.CGColor);
    CGContextBeginTransparencyLayer(ctx, nil);
    [self.next draw:context];
    
    CGContextEndTransparencyLayer(ctx);
    
    CGContextRestoreGState(ctx);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
    CGFloat blurSize = round(_blur / 2);
    UIEdgeInsets inset = UIEdgeInsetsMake(blurSize, blurSize, blurSize, blurSize);
    if (_offset.width < 0) {
        inset.left += fabs(_offset.width);
        inset.right -= blurSize;
        
    } else if (_offset.width > 0) {
        inset.right += fabs(_offset.width);
        inset.left -= blurSize;
    }
    if (_offset.height < 0) {
        inset.top += fabs(_offset.height);
        inset.bottom -= blurSize;
        
    } else if (_offset.height > 0) {
        inset.bottom += fabs(_offset.height);
        inset.top -= blurSize;
    }
  
    insets.top += inset.top;
    insets.right += inset.right;
    insets.bottom += inset.bottom;
    insets.left += inset.left;
    
    if (self.next) {
        return [self.next addToInsets:insets forSize:size];
        
    } else {
        return insets;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(HMUIStyleContext*)context {
    CGFloat blurSize = round(_blur / 2);
    size.width += _offset.width + (_offset.width ? blurSize : 0);
    size.height += _offset.height + (_offset.height ? blurSize : 0);
    
    if (_next) {
        return [self.next addToSize:size context:context];
        
    } else {
        return size;
    }
}
@end
