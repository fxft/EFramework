//
//  HMUIAlertView.h
//  GPSService
//
//  Created by Eric on 14-4-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMUIActionSheet;

typedef void (^ActionSheetClicked)(HMUIActionSheet *sheet,NSInteger index);
/**
 *  UIActionSheet 显示，支持读秒默认点击
 *  如果需要支持 8.0 以下 请使用旧的方式 HMUIAction7Sheet
 */
@interface HMUIActionSheet : UIAlertController
@property (nonatomic, copy) void (^clicked)(HMUIActionSheet *action,NSInteger index);
@property (nonatomic,copy)                  NSString *tagString;
@property (nonatomic) NSInteger tag;
@property (nonatomic,HM_WEAK) id<UIActionSheetDelegate> delegate;
@property(nonatomic) NSInteger cancelButtonIndex;

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message destructive:(NSString*)destructive;

- (instancetype)onClicked:(ActionSheetClicked)clk;

- (void)show;
- (void)showInView:(UIView *)view;
- (void)showInViewController:(UIViewController *)controller;

- (void)dismissAnimated:(BOOL)animated;
- (void)addCancelTitle:(NSString *)title;
- (NSInteger)addButtonWithTitle:(NSString *)title;
/**
 *  定时关闭
 *
 *  @param interval 倒计时，单位秒
 *  @param index    默认点击按钮
 *  @param animated     是否在标题动态显示读秒
 */
- (void)timeoutSec:(NSInteger)interval toClick:(NSInteger)index animated:(BOOL)animated;

@end


@class HMUIAction7Sheet;

typedef void (^Action7SheetClicked)(HMUIAction7Sheet *sheet,NSInteger index);
/**
 *  UIActionSheet 显示，支持读秒默认点击
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface HMUIAction7Sheet : UIActionSheet
#pragma clang diagnostic pop

@property (nonatomic, copy) void (^clicked)(HMUIAction7Sheet *action,NSInteger index);

- (instancetype)onClicked:(Action7SheetClicked)clk;
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message destructive:(NSString*)destructive;

- (void)show;
- (void)showInViewController:(UIViewController *)controller;

- (void)dismissAnimated:(BOOL)animated;
- (void)addCancelTitle:(NSString *)title;
/**
 *  定时关闭
 *
 *  @param interval 倒计时，单位秒
 *  @param index    默认点击按钮
 *  @param animated     是否在标题动态显示读秒
 */
- (void)timeoutSec:(NSInteger)interval toClick:(NSInteger)index animated:(BOOL)animated;

@end

@interface NSObject (Sheet)
/**
 *  兼容版
 *
 *  @param title   标题
 *  @param message 信息
 *
 *  @return 对应的数据对象(8.0:HMUIActionSheet，7.0:HMUIAction7Sheet)
 */
+ (instancetype)sheetViewWithTitle:(NSString*)title message:(NSString *)message;
/**
 *  兼容版
 *
 *  @param title   标题
 *  @param message 信息
 *  @param destructive     红色
 *
 *  @return 对应的数据对象(8.0:HMUIActionSheet，7.0:HMUIAction7Sheet)
 */
+ (instancetype)sheetViewWithTitle:(NSString*)title message:(NSString *)message destructive:(NSString*)destructive;
@end
