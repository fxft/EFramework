//
//  HMUIAlertView.h
//  GPSService
//
//  Created by Eric on 14-4-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMUIAlertView;

typedef void (^AlertViewClicked)(HMUIAlertView *alert,NSInteger index);
/**
 *  HMUIAlertView 显示，支持读秒默认点击
 *  如果需要支持 8.0 以下 请使用旧的方式 HMUIAlert7View
 */

NS_CLASS_AVAILABLE_IOS(8_0) @interface HMUIAlertView : UIAlertController
@property (nonatomic,copy)                  NSString *tagString;
@property (nonatomic) NSInteger tag;

@property (nonatomic,HM_WEAK) id<UIAlertViewDelegate> delegate;
@property(nonatomic) NSInteger cancelButtonIndex;


@property (nonatomic, copy) AlertViewClicked clicked ;//void (^clicked)(HMUIAlertView * alert,NSInteger index);
// Alert view style - defaults to UIAlertViewStyleDefault
@property(nonatomic,assign) UIAlertViewStyle alertViewStyle NS_AVAILABLE_IOS(5_0);

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex NS_AVAILABLE_IOS(5_0);

+ (instancetype)alertWithTitle:(NSString *)title message:( NSString *)message;

- (instancetype)onClicked:(AlertViewClicked)clk;

- (void)show;
- (void)showInView:( UIView *)view;
- (void)showInViewController:( UIViewController *)controller;

- (NSInteger)addButtonWithTitle:(NSString *)title;    // returns index of button. 0 based.
- (void)dismissAnimated:(BOOL)animated;
- (void)addCancelTitle:( NSString *)title;
/**
 *  定时关闭
 *
 *   interval 倒计时，单位秒
 *   index    默认点击按钮
 *   animated     是否在标题动态显示读秒
 */
- (void)timeoutSec:(NSInteger)interval toClick:(NSInteger)index animated:(BOOL)animated;

@end

@class HMUIAlert7View;

typedef void (^Alert7ViewClicked)(HMUIAlert7View *alert,NSInteger index);
/**
 *  HMUIAlertView 显示，支持读秒默认点击
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface HMUIAlert7View : UIAlertView
#pragma clang diagnostic pop

@property (nonatomic, copy) void (^clicked)(HMUIAlert7View * alert,NSInteger index);

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message;

- (instancetype)onClicked:(Alert7ViewClicked)clk;

- (void)showInView:( UIView *)view;
- (void)showInViewController:( UIViewController *)controller;

- (void)dismissAnimated:(BOOL)animated;
- (void)addCancelTitle:( NSString *)title;
/**
 *  定时关闭
 *
 *   interval 倒计时，单位秒
 *   index    默认点击按钮
 *   animated     是否在标题动态显示读秒
 */
- (void)timeoutSec:(NSInteger)interval toClick:(NSInteger)index animated:(BOOL)animated;

@end

@interface NSObject (Alert)
/**
 *  兼容版
 *
 *   title   标题
 *   message 信息
 *
 *   return 对应的数据对象(8.0:HMUIAlertView，7.0:HMUIAlert7View)
 */
+ (instancetype)alertViewWithTitle:(NSString*)title message:(NSString *)message;

@end
