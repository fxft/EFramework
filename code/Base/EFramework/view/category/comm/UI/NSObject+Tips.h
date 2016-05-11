//
//  NSObject+Tips.h
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
// https://github.com/matej/MBProgressHUD.git

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface HMMBProgressHUD : MBProgressHUD

@property (nonatomic) CGRect touchFrame;

@end

typedef NS_ENUM(NSUInteger, TouchRange) {
    TouchRange_All = 0xFFFF,//整个导航条可点击
    TouchRange_Left = 1<<1,//导航条左半部分可点击
    TouchRange_Center = 1<<2,//导航条中半部分可点击
    TouchRange_Right = 1<<3,//导航条右半部分可点击
    TouchRange_Screen = 1<<4,//整个页面部分可点击
};

/**
 *  共享的MBProgressHUD 添加到了 Window上
 */
@interface NSObject (Tips)
#ifdef DEBUG
-(void)test_Tips;
#endif
- (void)tipsDismiss;
- (void)tipsDismissNoAnimated;

- (HMMBProgressHUD *)showSuccessTip:(NSString *)string timeOut:(NSTimeInterval)interval;

- (HMMBProgressHUD *)showLoaddingTip:(NSString *)string timeOut:(NSTimeInterval)interval;

- (HMMBProgressHUD *)showFailureTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval;

- (HMMBProgressHUD *)showMessageTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval;

- (HMMBProgressHUD *)showCustomTip:(NSString *)string custom:(UIView*)custom timeOut:(NSTimeInterval)interval;

- (HMMBProgressHUD *)showModeTip:(NSString *)string detail:(NSString*)detail custom:(UIView*)custom mode:(MBProgressHUDMode)mode timeOut:(NSTimeInterval)interval;



- (HMMBProgressHUD *)showSuccessTip:(NSString *)string timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView;

- (HMMBProgressHUD *)showLoaddingTip:(NSString *)string timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView;

- (HMMBProgressHUD *)showFailureTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView;

- (HMMBProgressHUD *)showMessageTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView;

- (HMMBProgressHUD *)showCustomTip:(NSString *)string custom:(UIView*)custom timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView;

/**
 *  支持多种配置
 *
 *  @param string    标题
 *  @param detail    副标题
 *  @param custom    自定义视图
 *  @param mode      详见 MBProgressHUDMode
 *  @param interval  超时时间（-1表示无限时间）
 *  @param touchView 允许点击的位置
 *
 *  @return HMMBProgressHUD
 */
- (HMMBProgressHUD *)showModeTip:(NSString *)string detail:(NSString*)detail custom:(UIView*)custom mode:(MBProgressHUDMode)mode timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView;

/**
 *  实例化一个HUD，不是共享的
 *
 *  @param animated
 *  @param touchView 可点击区域，可为空
 *
 *  @return
 */
- (HMMBProgressHUD *)showHUDViewAnimated:(BOOL)animated touchView:(UIView *)touchView;
- (HMMBProgressHUD *)hideHUDViewAnimated:(BOOL)animated;
- (HMMBProgressHUD *)myHUDView;


- (HMMBProgressHUD *)showSuccessTip:(NSString *)string timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange;

- (HMMBProgressHUD *)showLoaddingTip:(NSString *)string timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange;

- (HMMBProgressHUD *)showFailureTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange;

- (HMMBProgressHUD *)showMessageTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange;

- (HMMBProgressHUD *)showCustomTip:(NSString *)string custom:(UIView*)custom timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange;


- (HMMBProgressHUD *)showModeTip:(NSString *)string detail:(NSString*)detail custom:(UIView*)custom mode:(MBProgressHUDMode)mode timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange;




@end
