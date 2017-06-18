//
//  HMUIConfig.h
//  CarAssistant
//
//  Created by Eric on 14-3-14.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMMacros.h"

typedef enum
{
	HMUIInterfaceMode_iOS6 = 0,
	HMUIInterfaceMode_iOS7
} HMUIInterfaceMode;


/**
 *  通用配置的默认值设置
 */
@interface HMUIConfig : NSObject
AS_SINGLETON(HMUIConfig);

/**
 *  控制器横屏竖屏支持，全局默认；YES or NO  横向，纵向不能同时为NO，否则会出现导航条缩进
 *  个别页面需要自定义时可以在各自的controller的load{}方法进行设置
 */
@property (nonatomic) BOOL                         allowedPortrait;//竖屏
@property (nonatomic) BOOL                         allowedLandscape;//横屏
@property (nonatomic) BOOL                         allowedPortraitUpside;//倒屏
@property (nonatomic) BOOL                         allowedLandscapeRight;//右横屏
@property (nonatomic) UIInterfaceOrientationMask interfaceOrientationMask;


/**
 *  网络数据Log是否进行打印的设置，默认20*1024字节
 */
@property (nonatomic) NSUInteger                   allowedLogWebDataLength;//default 20480
/**
 *  并没什么鸟用
 */
@property (nonatomic) HMUIInterfaceMode            interfaceMode;
/**
 *  如果需要设置成状态栏不透过，
 *  需要将本viewcontroller放到stack中，
 *  在viewdidload中隐藏导航栏，并设置includesOpaque为YES
 */
@property (nonatomic) BOOL                         includesOpaque;

/**
 *  全局默认状态栏样式
 */
@property (nonatomic) UIStatusBarStyle             statusBarStyle;

/**
 *  是否支持左滑动返回，区别与navigation控制器
 */
@property (nonatomic) BOOL                         allowControlerGestureBack;
/**
 *  并没什么鸟用
 */
@property (nonatomic) BOOL                         allowControlerGestureAutoControl;

/**
 *  debug模式，是否显示视图的边框
 */
@property (nonatomic) BOOL                         showViewBorder;

/**
 *  设置 tint color
 */
@property (nonatomic,HM_STRONG) UIColor *          defaultNavigationBarColor;
/**
 *  原生颜色，实际设置了bar image
 */
@property (nonatomic,HM_STRONG) UIColor *          defaultNavigationBarOriginalColor;
@property (nonatomic,HM_STRONG) UIColor *          defaultNavigationTitleColor;

@property (nonatomic,HM_STRONG) UIFont *           defaultNavigationTitleFont;
@property (nonatomic,HM_STRONG) UIImage *          defaultNavigationBarImage;
/**
 *  设置阴影
 */
@property (nonatomic,HM_STRONG) UIImage *          defaultNavigationBarShadowImage;

@property (nonatomic) BOOL                         defaultNavigationBarTranslucent;


@property (nonatomic,copy) NSString *              localizable;

@end
