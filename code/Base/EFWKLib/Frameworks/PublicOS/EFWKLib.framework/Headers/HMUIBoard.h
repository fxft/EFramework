//
//  HMUIBoard.h
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"
#import "HMFoundation.h"
#import "HMUIConfig.h"

@interface PresentWindow : NSObject

AS_SINGLETON(PresentWindow);

@property (nonatomic,assign) UIWindow *mainWindow;
@property (nonatomic,HM_STRONG) UIWindow *window;

+ (UIViewController*)rootViewController;
/**
 *  针对present 页面切换 出现 输入响应问题
 */
+ (void)makeKeyWindow;
/**
 *  注销 window
 *
 *  @param animated 是否支持动画
 */
+ (void)resignKeyWindow:(BOOL)animated;
@end

#define ON_UIBoard( signal ) ON_SIGNAL2(HMUIBoard, signal)

@protocol ON_UIBoard_handle <NSObject>

ON_UIBoard( signal );

@end


/**
 *  ViewController模版，适配了HMBaseNavigator的一些特性，内置常用的tableview。
 *  HMURLMap文件中有很多是ViewController的扩展属性
 */
@interface HMUIBoard : UIViewController<UITableViewDelegate,UITableViewDataSource>

//在load方法中进行设置，可以配置ViewController支持的横屏方式
@property (nonatomic) BOOL							allowedPortrait;
@property (nonatomic) BOOL							allowedLandscape;
@property (nonatomic) BOOL							allowedPortraitUpside;
@property (nonatomic) BOOL							allowedLandscapeRight;

//状态栏样式
@property (nonatomic) UIStatusBarStyle              statusBarStyle;
@property (nonatomic) BOOL                          statusBarHidden;
@property (nonatomic,HM_STRONG) UITableView *       tableView;


AS_SIGNAL( ORIENTATION_WILL_CHANGE )	// 方向变化
AS_SIGNAL( ORIENTATION_DID_CHANGED )	// 方向变化

+ (void)setDefaultBackgroundImage:(UIImage*)image;
+ (void)setDefaultBackgroundColor:(UIColor*)color;

@end


