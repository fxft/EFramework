//
//  slide.h
//  EFExtend
//
//  Created by mac on 15/3/22.
//  Copyright (c) 2015年 Eric. All rights reserved.
//
/**
 *  侧滑状态
 */
typedef NS_ENUM(NSUInteger, UISlideState){
    /**
     *  没有
     */
    UISlideStateNone,
    /**
     *  从上面
     */
    UISlideStateTop,
    /**
     *  从下面
     */
    UISlideStateBottom,
    /**
     *  从左边
     */
    UISlideStateLeft,
    /**
     *  从右边
     */
    UISlideStateRight
};

/**
 *  侧滑样式
 */
typedef NS_ENUM(NSUInteger, UISlideStyle){
    /**
     *  并没什么鸟用
     */
    UISlideStyleNor,
    /**
     *  后置侧滑
     */
    UISlideStyleBack,
    /**
     *  前置侧滑
     */
    UISlideStyleFront,
};

/**
 *  侧滑选项
 */
typedef NS_ENUM(NSUInteger, UISlideOptions){
    /**
     *  常规侧滑选项
     */
    UISlideOptionsNormal,
    /**
     *  2015版QQ侧滑选项
     */
    UISlideOptionsQQ,
};

/**
 *  侧滑控制器位置
 */
typedef NS_ENUM(NSUInteger, SlidePosition){
    /**
     *  在左边
     */
    SlidePositionLeft,
    /**
     *  在右边
     */
    SlidePositionRight,
    /**
     *  在上面
     */
    SlidePositionTop,
    /**
     *  在下面
     */
    SlidePositionBottom,
};

/**
 *  侧滑控制器,需要被继承,SlideController‘s subViewControllers can use self.parentViewController to get SlideBaseController
 */
@interface HMUISlideBoard : HMUIBoard

//传递的参数请根据 - (HMUIBoard *)putChild:(id)path isNew:(BOOL*)isnew;
AS_SIGNAL( TOGGLETO )
AS_SIGNAL( TOGGLETOColsePre )
AS_SIGNAL( TOGGLETOGetchild )
AS_SIGNAL( TOGGLETOState )
AS_SIGNAL( TOGGLETOBack )
AS_SIGNAL( TOGGLETOHome )

@property (nonatomic,HM_STRONG,readonly) UIViewController *root;//前置页面，页面切换将基于root
@property (nonatomic,HM_STRONG,readonly) UIViewController *left;
@property (nonatomic,HM_STRONG,readonly) UIViewController *right;
@property (nonatomic,HM_STRONG,readonly) UIViewController *top;
@property (nonatomic,HM_STRONG,readonly) UIViewController *bottom;

@property (nonatomic,copy) id  homePage;

@property (nonatomic) UISlideStyle style;//UISlideStyleBack:背面，UISlideStyleFront浮层
@property (nonatomic) UISlideState state;
@property (nonatomic) UISlideOptions options;
@property (nonatomic) CGFloat duration;
@property (nonatomic) BOOL hasNavgator;//目前只支持左右滑动的指定
@property (nonatomic) BOOL disableDrag;//去掉支持左右拖动导出侧滑

@property (nonatomic) CGFloat rightWidth;
@property (nonatomic) CGFloat leftWidth;
@property (nonatomic) CGFloat topWidth;
@property (nonatomic) CGFloat bottomWidth;

@property (nonatomic) CGFloat actionPercent;

@property (nonatomic) CGFloat actionPercentTop;
@property (nonatomic) CGFloat actionPercentBottom;
@property (nonatomic) CGFloat actionPercentLeft;
@property (nonatomic) CGFloat actionPercentRight;

@property (nonatomic) BOOL showLeft;
@property (nonatomic) BOOL showTop;
@property (nonatomic) BOOL showBottom;
@property (nonatomic) BOOL showRight;

//不论在什么状态下都会返回原状态
- (void)toggleToNormal:(BOOL)animated;
- (void)toggleAuto:(UISlideState)stat animated:(BOOL)animated;

//overwrite 切换回调
- (void)slideShowed:(UISlideState)state;
- (void)slideHided:(UISlideState)state;

//需要子类返回上下左右控制器的对象
- (UIViewController*)slideControllerForPosition:(SlidePosition)position;
- (CGFloat)slideWidthForPosition:(SlidePosition)position;

@end

@interface UIViewController (HMUISlideBoard_toggle)
/**
 *  切换slide控制器的root视图，调用者需要是HMUISlideBoard的子视图，例如left,right,top,bottom,root;或以上四个的子控制器
 *
 *   path     - (HMUIBoard *)putChild:(id)path isNew:(BOOL*)isnew;的path类型
 *   closePre 是否关闭上一个控制器
 *
 *   return 需要被切换的控制器
 */
- (HMUIBoard*)slideToggleToChild:(id)path map:(NSString*)map closePre:(BOOL)closePre;
- (HMUIBoard*)slideToggleToHomeAndClosePre:(BOOL)closePre;
- (HMUIBoard*)slideToggleToMainAndClose:(BOOL)close;

- (HMUIBoard*)slideGetChild:(id)path;

- (void)slideShowSide:(UISlideState)state;

@end
