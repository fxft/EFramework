//
//  UIView+HMViewStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIView.h"
#import "HMFoundation.h"


@class HMUIStyle;

@interface UILabel (HMViewStyle)
+ (void)hook;
@end

@interface UIView (HMViewStyle)//for HMUIview
//只适用于HMUIView 或支持 drawStyleInRect的视图
@property (nonatomic, HM_STRONG) HMUIStyle *    style__;

- (UIView*)addViewStyle:(HMUIStyle*)style;
- (UIView*)clearViewStyle;
- (UIView*)updateViewStyle;
- (HMUIStyleContext *)drawStyleInRect:(CGRect)rect;
- (CGRect)styleForBounds:(CGRect)bounds;
- (CGRect)styleMinBounds;
- (UIEdgeInsets)styleInsets;

@end

