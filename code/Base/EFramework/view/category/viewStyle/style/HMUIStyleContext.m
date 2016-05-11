//
//  HMUIStyleContext.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyleContext.h"
#import "HMViewShape.h"
const NSInteger kDefaultLightSource = 125;

@implementation HMUIStyleContext
@synthesize frame           = _frame;
@synthesize contentFrame    = _contentFrame;
@synthesize shape           = _shape;
@synthesize font            = _font;
@synthesize didDrawContent  = _didDrawContent;
@synthesize layer;
//@synthesize delegate        = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [super init];
    if (self) {
        _frame = CGRectZero;
        _contentFrame = CGRectZero;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_shape release];
    _shape = nil;
    [_font release];
    _font = nil;
    self.layer = nil;
    HM_SUPER_DEALLOC();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (HMUIShape*)shape {
    if (!_shape) {
        _shape = [[HMUIRectangleShape shape] retain];
    }
    
    return _shape;
}
@end
