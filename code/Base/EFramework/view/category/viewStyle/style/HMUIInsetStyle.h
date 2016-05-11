//
//  HMUIInsetStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIInsetStyle : HMUIStyle{
    UIEdgeInsets _inset;
    CGRect       _newFrame;
    CGRect       _stackFrame;
    CGRect       _stackContentFrame;
    UIEdgeInsets _stackInset;
    CGSize       _stackSize;
    int          _state;
    int          _tag;
}

@property (nonatomic) UIEdgeInsets inset;
@property (nonatomic) CGRect       newFrame;
@property (nonatomic) CGRect       stackFrame;// don't touch it
@property (nonatomic) CGRect       stackContentFrame;// don't touch it
@property (nonatomic) UIEdgeInsets stackInset;// don't touch it
@property (nonatomic) CGSize       stackSize;// don't touch it
@property (nonatomic) int          state;//0: normal  1:save for newFrame 2:restore
@property (nonatomic) int          tag;

+ (HMUIInsetStyle*)styleWithInset:(UIEdgeInsets)inset next:(HMUIStyle*)next;

+ (HMUIInsetStyle*)styleWithSaveForNewFrame:(CGRect)frame next:(HMUIStyle*)next;
+ (HMUIInsetStyle *)styleWithSaveForInset:(UIEdgeInsets)inset butWidth:(CGFloat)width height:(CGFloat)height next:(HMUIStyle *)next;
+ (HMUIInsetStyle*)styleWithRestoreNext:(HMUIStyle*)next;

@end
