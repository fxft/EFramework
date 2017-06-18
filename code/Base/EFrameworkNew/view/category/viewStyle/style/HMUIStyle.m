//
//  HMUIStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@implementation HMUIStyle
@synthesize next = _next;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(HMUIStyle*)next {
	self = [super init];
    if (self) {
        _next = [next retain];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [self initWithNext:nil];
    if (self) {
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_next release];
    
    HM_SUPER_DEALLOC();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (HMUIStyle*)next:(HMUIStyle*)next {
    self.next = next;
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
    if (self.next) {
        return [self.next addToInsets:insets forSize:size];
        
    } else {
        return insets;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(HMUIStyleContext*)context {
    if (_next) {
        return [self.next addToSize:size context:context];
        
    } else {
        return size;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addStyle:(HMUIStyle*)style {
    if (_next) {
        [_next addStyle:style];
        
    } else {
        _next = [style retain];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)firstStyleOfClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;
        
    } else {
        return [self.next firstStyleOfClass:cls];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)styleForPart:(NSString*)name {
//    HMUIStyle* style = self;
//    while (style) {
//        if ([style isKindOfClass:[TTPartStyle class]]) {
//            TTPartStyle* partStyle = (TTPartStyle*)style;
//            if ([partStyle.name isEqualToString:name]) {
//                return partStyle;
//            }
//        }
//        style = style.next;
//    }
    return nil;
}
@end



@implementation HMUIStyle (StyleInner)

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGGradientRef)newGradientWithColors:(UIColor**)colors locations:(CGFloat*)locations count:(int)count{
    CGFloat* components = malloc(sizeof(CGFloat)*4*count);
    for (int i = 0; i < count; ++i) {
        UIColor* color = colors[i];
        size_t n = CGColorGetNumberOfComponents(color.CGColor);
        const CGFloat* rgba = CGColorGetComponents(color.CGColor);
        if (n == 2) {
            components[i*4] = rgba[0];
            components[i*4+1] = rgba[0];
            components[i*4+2] = rgba[0];
            components[i*4+3] = rgba[1];
            
        } else if (n == 4) {
            components[i*4] = rgba[0];
            components[i*4+1] = rgba[1];
            components[i*4+2] = rgba[2];
            components[i*4+3] = rgba[3];
        }
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, count);
    free(components);
    
    return gradient;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGGradientRef)newGradientWithColors:(UIColor**)colors count:(int)count {
    return [self newGradientWithColors:colors locations:nil count:count];
}
@end
