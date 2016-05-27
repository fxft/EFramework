//
//  HMURLMap.h
//  GPSService
//
//  Created by Eric on 14-4-3.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMMacros.h"
#import "HMFoundation.h"

#undef URLFOR_storyboard//从storyboard中获取controller，uri eg.@"Main.MainViewController"
#define URLFOR_storyboard(uri) [NSString stringWithFormat:@"storyboard://%@",uri]

#undef URLFOR_storyboardWithNav//从storyboard中获取controller，并添加一个导航栏
#define URLFOR_storyboardWithNav(uri) [NSString stringWithFormat:@"storyboard://HMUIStack.%@",uri]

#undef URLFOR_storyboardWithNavCustom//从storyboard中获取controller，并添加一个自定义Bar的导航栏
#define URLFOR_storyboardWithNavCustom(uri) [NSString stringWithFormat:@"storyboard://HMUIStackCustom.%@",uri]


#undef URLFOR_controllerWithNav
#define URLFOR_controllerWithNav(uri) [NSString stringWithFormat:@"cc://HMUIStack.%@",uri]

#undef URLFOR_controllerWithNavCustom
#define URLFOR_controllerWithNavCustom(uri) [NSString stringWithFormat:@"cc://HMUIStackCustom.%@",uri]


#undef URLFOR_controller
#define URLFOR_controller(uri) [NSString stringWithFormat:@"cc://%@",uri]

#undef URLFOR_controllerWithNavXib
#define URLFOR_controllerWithNavXib(uri) [NSString stringWithFormat:@"cc://HMUIStack.%@.xib",uri]

#undef URLFOR_controllerWithNavCustomXib
#define URLFOR_controllerWithNavCustomXib(uri) [NSString stringWithFormat:@"cc://HMUIStackCustom.%@.xib",uri]


#undef URLFOR_controllerXib
#define URLFOR_controllerXib(uri) [NSString stringWithFormat:@"cc://%@.xib",uri]

#undef URLFOR_callTelephone
#define URLFOR_callTelephone(tel) [NSString stringWithFormat:@"telprompt://%@",tel]

//#undef URLFOR_view
//#define URLFOR_view(uri) [NSString stringWithFormat:@"vv://%@",uri]
//#undef URLFOR_viewXib
//#define URLFOR_viewXib(uri,fragment) [NSString stringWithFormat:@"vv://%@.xib#%@",uri,fragment]
#undef URLFOR_web
#define URLFOR_web(uri) (uri)
#undef DIDNOTHING
#define DIDNOTHING(nothing)

@class HMUIBoard;

typedef enum {
    HMNavigationModeNone,
    HMNavigationModeCreate,            // a new view controller is created each time
    HMNavigationModeGround,             // a new view controller is created, cached and re-used
    HMNavigationModeShare,             // a new view controller is created, cached and re-used
    HMNavigationModeModal,             // a new view controller is created and presented modally
    HMNavigationModePopover,           // a new view controller is created and presented in a popover
    HMNavigationModeExternal,          // an external app will be opened
} HMNavigationMode;

typedef NS_OPTIONS(NSUInteger, UIViewAnimationOptionsMap) {
    
    UIViewAnimationOptionTransitionFromTop  = 1 << 28,
    UIViewAnimationOptionTransitionFromBottom  = 2 << 28,
    UIViewAnimationOptionTransitionFromLeft  = 3 << 28,
    UIViewAnimationOptionTransitionFromRight  = 4 << 28,
    
    UIViewAnimationOptionGesture  = 5 << 28,
    UIViewAnimationOptionCustom  = 6 << 28,
};

/**
 *  辅助HMBaseNavigator视图转场路由导航控制器中心 进行转场属性配置
 */
@interface HMURLMAPItem : NSObject<UIViewControllerContextTransitioning>
{
    NSInteger		_type;
    NSString *		_url;
    UIViewController *	_board;
    NSString *	_bindto;
}

AS_INT( TYPE_UNKNOWN )		// unknown
AS_INT( TYPE_CLASS )			// class 初始值
AS_INT( TYPE_BOARD )			// board
AS_INT( TYPE_NAVBOARD )			// 带navigation的board
AS_INT( TYPE_VIEW )			// 普通view
AS_INT( TYPE_WINDOW )			// window
AS_INT( TYPE_EXTERNAL )			// 外部调用
AS_INT( TYPE_WEB )			// 打开网页调用

//内置属性
@property (nonatomic, copy) NSString *	rule;
@property (nonatomic, copy) NSString *	bindto;
@property (nonatomic, assign) NSInteger	type;
@property (nonatomic, copy) NSString *	url;
@property (nonatomic, HM_STRONG) UIViewController*	board;

@property (nonatomic, assign) UIViewAnimationOptions option;//转场动画分类
@property (nonatomic, assign) NSTimeInterval duration;//转场动画播放时间
@property (nonatomic, assign)HMNavigationMode navigateMode;//暂时无用
@property (nonatomic, assign) BOOL    backing;//内部使用
@property (nonatomic, HM_STRONG) UIViewController*	backBoard;
@property (nonatomic, assign) BOOL    fullScreen;//是否计算状态栏高度

//过场动画自定义，以下两个属性需要设置 option ＝ UIViewAnimationOptionCustom
@property (nonatomic, HM_STRONG)id <UIViewControllerAnimatedTransitioning> animaterFront;
@property (nonatomic, HM_STRONG)id <UIViewControllerAnimatedTransitioning> animaterBack;

+ (HMURLMAPItem*)setupWith:(NSString*)url;

@end

@interface HMURLMap : NSObject

AS_SINGLETON(HMURLMap)
+ (void)registerScheme:(NSString*)scheme;

- (HMURLMAPItem*)mapGround:(NSString *)map URL:(NSString *)url;
- (HMURLMAPItem*)map:(NSString *)map URL:(NSString *)url;
- (HMURLMAPItem*)map:(NSString *)map bindto:(NSString*)to URL:(NSString *)url;
- (HMURLMAPItem*)map:(NSString *)map boardOrView:(id)boardOrView;

+ (HMURLMAPItem*)mapGround:(NSString *)map URL:(NSString *)url;
+ (HMURLMAPItem*)map:(NSString *)map URL:(NSString *)url;
+ (HMURLMAPItem*)map:(NSString *)map bindto:(NSString*)to URL:(NSString *)url;
+ (HMURLMAPItem*)map:(NSString *)map boardOrView:(id)boardOrView;

+ (NSArray*)allMapItem;

+ (id)boardForTopMap:(NSString*)map;
+ (id)boardForFirstMap:(NSString*)map;

+ (id)boardForMap:(NSString*)map;
- (id)boardForMap:(NSString*)map;

+ (id)objectForMap:(NSString*)map;
- (id)objectForMap:(NSString*)map;

+ (id)objectForBoard:(id)__board;
- (id)objectForBoard:(id)__board;

+ (void)removeMap:(NSString *)map;
- (void)removeMap:(NSString *)map;
- (void)removeItem:(HMURLMAPItem *)mapItem;

@end


@class HMUIStack;

@interface UIView (HMURLMap)
@property (nonatomic, copy) NSString *					urlMap;
@end

@interface UINavigationController (HMURLMap)
+ (void)hook;
@end

@interface UIViewController (HMURLMap)  //for HMUIBoard

@property (nonatomic, HM_WEAK) HMUIBoard *					parentBoard;
@property (nonatomic, copy) NSString *					urlMap;
@property (nonatomic, HM_STRONG) NSDate *       openDate;
@property (nonatomic, HM_STRONG) NSString *      nickname;


////在load方法中进行设置，可以配置ViewController支持的横屏方式
//@property (nonatomic) BOOL							allowedPortrait;
//@property (nonatomic) BOOL							allowedLandscape;
//@property (nonatomic) BOOL							allowedPortraitUpside;
//@property (nonatomic) BOOL							allowedLandscapeRight;

/**
 *  在带有Navigation控制器的视图控制器的load方法中设置，设置为YES表示视图穿透，NO表示不穿透
 */
@property (nonatomic) BOOL      includesOpaque;
@property (nonatomic) BOOL                        viewVisable;
@property (nonatomic) BOOL                        viewIsLoaded;
@property (nonatomic, readonly) HMUIStack * stack;
+ (void)hook;
+ (instancetype)boardFromXib;
+ (instancetype)board;

//根据addchilrenViewcontroller 的时间
- (UIViewController*)viewControllerBefore:(UIViewController *)pre after:(UIViewController *)after;
- (UIViewController*)viewControllerLastOne;
/**
 * The view controller that comes after this one in a navigation controller's history.
 */
- (UIViewController*)nextViewController;

- (UIViewController*)open:(NSString *)map animate:(BOOL)animate;

/*
 [A]-[B]-[C]
 In C open B can close A
 */
- (UIViewController*)open:(NSString *)map close:(NSString *)close animate:(BOOL)animate;
/*
 [A]-[B]-[C]-[D]
 In D open A can close [B,C,D]
 */
- (UIViewController*)open:(NSString *)map closes:(NSArray *)closes animate:(BOOL)animate;
- (UIViewController*)open:(NSString *)map closes:(NSArray *)closes animate:(BOOL)animate complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;
/*
 [A]-[B]-[C]
 In C opento A will close [B]、[C]
 */
- (UIViewController*)opento:(NSString *)map animate:(BOOL)animate;
- (UIViewController *)opento:(NSString *)map animate:(BOOL)animate complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;
/*
 针对一些不想使用URLMap的用户,直接使用open默认方式跳转，name是别名
 */
- (UIViewController*)open:(NSString *)map name:(NSString*)name animate:(BOOL)animate;
- (UIViewController*)open:(NSString *)map name:(NSString *)name animate:(BOOL)animate mapItem:(void (^)(HMURLMAPItem *mapItem))mapItem;
/*
 需要注意complete，viewLoaded:YES表示视图已经加载，NO表示控制器已经初始化；
 */
- (UIViewController*)open:(NSString *)map name:(NSString *)name animate:(BOOL)animate complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;
- (UIViewController*)open:(NSString *)map name:(NSString *)name animate:(BOOL)animate mapItem:(void (^)(HMURLMAPItem *mapItem))mapItem complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;

- (void)close:(NSString *)close;
- (void)closeAll;

- (void)backWithAnimate:(BOOL)animate;
- (void)backAndRemoveWithAnimate:(BOOL)animate;
- (void)backWithAnimate:(BOOL)animate remove:(BOOL)remove;
- (void)backWithAnimate:(BOOL)animate remove:(BOOL)remove complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;//只支持viewLoaded为NO
/*
 针对 stack 返回
 */
- (void)backToRootWithAnimate:(BOOL)animate;
- (void)backToPreMapClose:(BOOL)close animate:(BOOL)animate;
- (void)backToMap:(NSString*)map animate:(BOOL)animate;
- (void)backToMap:(NSString*)map close:(NSString*)close animate:(BOOL)animate;
- (void)backToMap:(NSString*)map close:(NSString*)close animate:(BOOL)animate complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;//只支持viewLoaded为NO

- (void)load;
- (void)unload;
/**
 *  push or present
 *
 *  @param path  <UIViewController> <NSString>  URLFOR_controller(@"xxx") or Main.HMUIStack.DetailBoard or Main.DetailBoard
 *  @param animated
 *
 *  @return target uiview controller
 */
- (UIViewController*)pushToPath:(id)path animated:(BOOL)animated;
/*map for name*/
- (UIViewController*)pushToPath:(id)path map:(NSString*)map animated:(BOOL)animated;
- (UIViewController*)pushToPath:(id)path map:(NSString*)map animated:(BOOL)animated complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;
/**
 *   present
 *
 *  @param path  <UIViewController> <NSString>  URLFOR_controller(@"xxx") or Main.HMUIStack.DetailBoard or Main.DetailBoard
 *  @param animated
 *
 *  @return target uiview controller
 */
/*map for name*/
- (UIViewController*)presentToPath:(id)path map:(NSString*)map animated:(BOOL)animated;
- (UIViewController*)presentToPath:(id)path map:(NSString*)map animated:(BOOL)animated complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;

/**
 *  add to parenController. if exited bringtofront
 *
 *  @param path  <UIViewController> <NSString>  URLFOR_controller(@"xxx") or @"Main.HMUIStack.DetailBoard" or @"Main.DetailBoard"
 *  @param isnew if created isnew return YES
 *
 *  @return the target
 */
- (HMUIBoard *)putChild:(id)path isNew:(BOOL*)isnew;
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew;
/*name is path<NSString>*/
- (HMUIBoard*)getChild:(NSString*)name;
/*如果是navigationviewcontroller则返回相应页面，否则*/
- (UIViewController*)myTopBoard;
- (UIViewController*)myFirstBoard;

- (HMUIBoard *)putChild:(id)path isNew:(BOOL*)isnew closePre:(BOOL)preClose;
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew closePre:(BOOL)preClose;
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew closePre:(BOOL)preClose complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;

/*closepath 请自行判断是采用 map 还是 path*/
- (HMUIBoard *)putChild:(id)path isNew:(BOOL*)isnew close:(id)closepath;
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew close:(id)closepath;
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew close:(id)closepath complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;

@end