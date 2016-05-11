//
//  HMUIShapeStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIShapeStyle.h"

@implementation HMUIShapeStyle
@synthesize shape = _shape;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_shape release];
    
    HM_SUPER_DEALLOC();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIShapeStyle*)styleWithShape:(HMUIShape*)shape next:(HMUIStyle*)next {
    HMUIShapeStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.shape = shape;
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark HMUIStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    UIEdgeInsets shapeInsets = [_shape insetsForSize:context.frame.size];
    context.contentFrame = CGRectEdgeInsets(context.contentFrame, shapeInsets);
    context.shape = _shape;
    [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
    UIEdgeInsets shapeInsets = [_shape insetsForSize:size];
    insets.top += shapeInsets.top;
    insets.right += shapeInsets.right;
    insets.bottom += shapeInsets.bottom;
    insets.left += shapeInsets.left;
    
    if (self.next) {
        return [self.next addToInsets:insets forSize:size];
        
    } else {
        return insets;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(HMUIStyleContext*)context {
    CGSize innerSize = [self.next addToSize:size context:context];
    UIEdgeInsets shapeInsets = [_shape insetsForSize:innerSize];
    innerSize.width += shapeInsets.left + shapeInsets.right;
    innerSize.height += shapeInsets.top + shapeInsets.bottom;
    
    return innerSize;
}

@end
