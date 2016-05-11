//
//  HMUIBoxStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIBoxStyle.h"

@implementation HMUIBoxStyle

@synthesize margin    = _margin;
@synthesize padding   = _padding;
@synthesize minSize   = _minSize;
@synthesize position  = _position;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(HMUIStyle*)next {
	self = [super initWithNext:next];
    if (self) {
        _margin = UIEdgeInsetsZero;
        _padding = UIEdgeInsetsZero;
        _minSize = CGSizeZero;
        _position = TTPositionStatic;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIBoxStyle*)styleWithMargin:(UIEdgeInsets)margin next:(HMUIStyle*)next {
    return [HMUIBoxStyle styleWithMargin:margin padding:UIEdgeInsetsZero minSize:CGSizeZero position:TTPositionStatic next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIBoxStyle*)styleWithPadding:(UIEdgeInsets)padding next:(HMUIStyle*)next {
    return [HMUIBoxStyle styleWithMargin:UIEdgeInsetsZero padding:padding minSize:CGSizeZero position:TTPositionStatic next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIBoxStyle*)styleWithFloats:(TTPosition)position next:(HMUIStyle*)next {
    return [HMUIBoxStyle styleWithMargin:UIEdgeInsetsZero padding:UIEdgeInsetsZero minSize:CGSizeZero position:position next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                          next:(HMUIStyle*)next {
    return [HMUIBoxStyle styleWithMargin:margin padding:padding minSize:CGSizeZero position:TTPositionStatic next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (HMUIBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                       minSize:(CGSize)minSize position:(TTPosition)position next:(HMUIStyle*)next {
    HMUIBoxStyle* style = [[[self alloc] initWithNext:next] autorelease];
    style.margin = margin;
    style.padding = padding;
    style.minSize = minSize;
    style.position = position;
    
    return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark HMUIStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(HMUIStyleContext*)context {
    context.contentFrame = CGRectEdgeInsets(context.contentFrame, _padding);
    [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(HMUIStyleContext*)context {
    size.width += _padding.left + _padding.right;
    size.height += _padding.top + _padding.bottom;
    
    if (_next) {
        return [self.next addToSize:size context:context];
        
    } else {
        return size;
    }
}

@end
