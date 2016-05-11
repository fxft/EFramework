//
//  HMUIProgressView.h
//  GPSService
//
//  Created by Eric on 14-4-16.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIView.h"

typedef enum {
    UIProgressTypeCircle = 1,//圆形
    UIProgressTypeLine = 2,//线型
    
}UIProgressType;

@interface HMUIProgressView : HMUIView

@property(nonatomic, HM_STRONG) UIColor *trackTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, HM_STRONG) UIColor *progressTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, HM_STRONG) UIColor *trackBorderTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, HM_STRONG) UIColor *progressBorderTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic) NSInteger roundedCorners UI_APPEARANCE_SELECTOR; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(
@property(nonatomic) CGFloat thicknessRatio UI_APPEARANCE_SELECTOR;
@property(nonatomic) CGFloat progress;

@property(nonatomic) CGFloat indeterminateDuration UI_APPEARANCE_SELECTOR;
@property(nonatomic) NSInteger indeterminate UI_APPEARANCE_SELECTOR; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(
@property(nonatomic) CGFloat trackHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic) CGFloat radius UI_APPEARANCE_SELECTOR;
@property(nonatomic) NSInteger hasBorder UI_APPEARANCE_SELECTOR;

@property(nonatomic) UIProgressType progressType;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setProgress:(CGFloat)progress duration:(NSTimeInterval)duration;
- (void)delayToHide:(NSTimeInterval)delay;

@property(nonatomic, HM_STRONG) UIView *indeterminateView;//如果存在，indeterminate时将出现不停旋转的视图

@end
