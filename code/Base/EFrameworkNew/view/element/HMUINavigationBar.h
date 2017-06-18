//
//  HMUINavigationBar.h
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMFoundation.h"
#import "HMMacros.h"

#define ON_NavigationBar( signal) ON_SIGNAL2(HMUINavigationBar, signal)

@protocol ON_NavigationBar_handle <NSObject>

ON_NavigationBar( signal);

@end

/**
 *  请结合HMUIStack使用
 */
@interface HMUINavigationBar : UINavigationBar

AS_INT( LEFT )	// 左按钮
AS_INT( RIGHT )	// 右按钮

AS_SIGNAL( LEFT_TOUCHED )	// 左按钮被点击
AS_SIGNAL( RIGHT_TOUCHED )	// 右按钮被点击

AS_NOTIFICATION( STYLE_CHANGED )
AS_NOTIFICATION( STATUS_CHANGED )

@property (nonatomic, HM_WEAK) UINavigationController *	navigationController;

/**
 *  没有什么鸟用
 *
 *  @return
 */
+ (CGSize)buttonSize;
+ (void)setButtonSize:(CGSize)size;

+ (void)setTitleColor:(UIColor *)color;
+ (void)setTitleFont:(UIFont *)font;
/*带模糊的背景色*/
+ (void)setBackgroundColor:(UIColor *)color;
/*不带模糊的背景色*/
+ (void)setBackgroundOriginalColor:(UIColor *)color NS_DEPRECATED_IOS(2_0, 2_0, "使用-[UIViewController setNav****]");
/**
 *  64高度
 *
 *  @param image
 */
+ (void)setBackgroundImage:(UIImage *)image NS_DEPRECATED_IOS(2_0, 2_0, "使用-[UIViewController setNav****]");
+ (void)setShadowImage:(UIImage *)image NS_DEPRECATED_IOS(2_0, 2_0, "使用-[UIViewController setNav****]");
+ (void)setBackgroundTranslucent:(BOOL)trans NS_DEPRECATED_IOS(2_0, 2_0, "使用-[UIViewController setNav****]");

@end

#pragma mark -

@interface UIViewController(UINavigationBar)

@property (nonatomic, assign,readonly) BOOL						navigationBarShown;
@property (nonatomic, assign,readonly) BOOL						statusBarShown;

- (void)showStatusBarAnimated:(BOOL)animated;
- (void)hideStatusBarAnimated:(BOOL)animated;

- (void)showNavigationBarAnimated:(BOOL)animated;
- (void)hideNavigationBarAnimated:(BOOL)animated;

/**
 *  状态栏颜色切换
 */
- (void)statusBarTurnDark;
- (void)statusBarTurnLight;

- (UINavigationBar*)navigatorBar;
- (void)setNavigationBarTitleFont:(UIFont *)font;
- (void)setNavigationBarTitleColor:(UIColor *)color;
- (void)setNavigationBarBackgroundColor:(UIColor *)color;

- (void)setNavigationBarBackgroundImage:(UIImage *)image;
- (void)setNavigationBarTranslucent:(BOOL)translucent;
- (void)setNavigationBarShadowImage:(UIImage *)shadowImage;


/*快速设置导航条的纯色主题样式*/
- (void)setNavigationBarOriginalColor:(UIColor *)color noShadow:(BOOL)noShadow;
- (void)setNavigationBarOriginalColor:(UIColor *)color;//真的是纯色背景


- (void)showBarButton:(NSInteger)position title:(NSString *)name;
- (void)showBarButton:(NSInteger)position image:(UIImage *)image;
- (void)showBarButton:(NSInteger)position image:(UIImage *)image image:(UIImage *)image2;
- (void)showBarButton:(NSInteger)position title:(NSString *)name image:(UIImage *)image;

- (void)showBarButton:(NSInteger)position system:(UIBarButtonSystemItem)index;
- (void)showBarButton:(NSInteger)position custom:(UIView *)view;
- (void)hideBarButton:(NSInteger)position;

- (id)navigateBarCustomView:(NSInteger)position;

/**
 button tagString is "customTitleLabel" . actually is a self.navigationItem.titleView
 */

- (void)customNavTitleView:(UIView*)title;
- (UIView*)customNavTitleView;
/**
 show title activity action is true start loading,else stop loading.tag is 120120
 */
- (UIActivityIndicatorView *)showTitleActivity:(BOOL)action;
- (UIActivityIndicatorView *)showTitleGrayActivity:(BOOL)action;
/**
 button tagString is "rightBtn"
 */
- (UIButten *)customNavRightBtn;
/**
 button tagString is "leftBtn"
 */
- (UIButten *)customNavLeftBtn;

/**
 自定义右视图
 */
- (void)setCustomNavRightView:(UIView*)view;
- (UIView *)customNavRightView;
/**
 自定义左视图
 */
- (void)setCustomNavLeftView:(UIView*)view;
- (UIView *)customNavLeftView;

@end
