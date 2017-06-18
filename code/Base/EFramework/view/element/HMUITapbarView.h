//
//  HMUITapbarView.h
//  GPSService
//
//  Created by Eric on 14-4-18.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIView.h"

#define ON_TapBar( signal) ON_SIGNAL2(HMUITapbarView, signal)
@protocol ON_TapBar_handle <NSObject>

ON_TapBar( signal);

@end
#define MINSPACE 0.f

//选择示意条
typedef enum : NSUInteger {
    UITapbarSlideStyleNone=0,
    UITapbarSlideStyleTop,//顶部
    UITapbarSlideStyleBottom,//底部
    UITapbarSlideStyleCenter,//居中
    UITapbarSlideStyleFull,//整片
} UITapbarSlideStyle;

typedef enum : NSUInteger {
    UITapbarSlideAnimatedNone=0,
    UITapbarSlideAnimatedNormal,//常规移动
    UITapbarSlideAnimatedEarthworm,//蚯蚓移动
} UITapbarSlideAnimated;


//设置布局模式
typedef enum : NSUInteger {
    UITapbarStyleFitOrign=0,//自动调整间隔 indent tail无效
    UITapbarStyleFitSpace,//自动调整间隔 indent tail有效
    UITapbarStyleFitSize,//自动调整大小 indent space tail 有效
    UITapbarStyleFitWidth,//自动调整宽度，需要自行设置高度 indent space tail 有效
    UITapbarStyleCanFlexible,//不支持滚动 addFlexible addspace addspace with width
    UITapbarStyleCenter,//居中，indent tail 无效 addspace有效
    UITapbarStyleCustom,//自定义位置 配合 indent tail addspace 超出后支持滚动
    UITapbarStyleCanScroll,//排版将使用 addspace 无效  space indent tail 有效
    UITapbarStyleAutolayout
} UITapbarStyle;

//支持横向，纵向
typedef enum : NSUInteger {
    UITapbarDirectionHorizontal=0,
    UITapbarDirectionVertical,
} UITapbarDirection;

@interface HMUITapbarView : HMUIView

@property (nonatomic, HM_STRONG)UIScrollView * baseView;

@property (assign, nonatomic)   CGFloat indentation;/*头部边框距离*/
@property (assign, nonatomic)   CGFloat tail;/*尾部边框距离*/
@property (assign, nonatomic)   CGFloat space;/*每次addSpace方法调用都会插入一个space*/

@property(assign,nonatomic)  NSInteger selectedIndex;
@property (assign, nonatomic, readonly)  NSInteger preSelectedIndex;
@property (assign, nonatomic,readonly) NSInteger lastSelectedIndex;

@property (assign, nonatomic)   BOOL showSelectedState;
@property (assign, nonatomic)   BOOL autoSelectedCenter;//当子视图在屏幕外时，是否允许自动居中 default NO
@property (nonatomic, HM_STRONG)UIColor *defaultColor;//default white
@property (nonatomic, HM_STRONG)UIColor *selectedColor;//default md_blue_400

@property (nonatomic, HM_STRONG)UIColor *slideviewColor;//default md_blue_400
@property (nonatomic, HM_STRONG)HMUIView *slideview;//点击后选中效果滑动
@property (assign, nonatomic) CGFloat slideHeight;//设置滑动条的高度，宽度会自动适配
@property (assign, nonatomic)   UITapbarSlideStyle slideStyle;//请先设置slideHeight
@property (assign, nonatomic)   UITapbarSlideAnimated slideAnimate;//slider滑动动画
@property (assign, nonatomic)   NSTimeInterval slideAnimateDuration;//slider滑动动画时间

@property (assign, nonatomic)   UITapbarStyle barStyle;//布局方式
@property (assign, nonatomic)   UITapbarDirection direction;//tapbar的方向
@property (assign, nonatomic)   BOOL asViewOnly;//只用于显示

AS_SIGNAL(TAPCHANGED);
AS_SIGNAL(TAPNOSELECTED);

- (void)setSelectedIndex:(NSInteger)selectedIndex witoutSignal:(BOOL)yesOrNo;

- (void)addContentView:(UIView*)content size:(CGSize)size;

//imageName @"test.png" => @"test_up.png",@"test_down.png",@"test_select.png"
- (UIButten *)addItemWithTitle:(NSString*)title imageName:(NSString*)name size:(CGSize)size background:(BOOL)background;
- (UIButten *)addItemWithTitle:(NSString*)title imageName:(NSString*)name size:(CGSize)size;

- (void)replaceIndex:(NSInteger)index WithView:(UIView*)content animated:(BOOL)animated;
- (void)replaceIndex:(NSInteger)index WithTitle:(NSString*)title Name:(NSString *)name background:(BOOL)background animated:(BOOL)animated;
- (void)replaceIndex:(NSInteger)index WithTitle:(NSString*)title Name:(NSString *)name animated:(BOOL)animated;

- (void)addSpace;//添加间隔
- (void)addFlexible;//标记为可拉伸区域
- (void)addSpace:(CGFloat)space;//添加自定义间隔

- (id)viewWithIndex:(NSInteger)index;

- (void)clearData;
- (void)updateItems;
- (void)showMask:(BOOL)show;

@end


@interface HMUITapbarView (Segmented)
- (void)asSegmentedWithItems:(NSArray*)items itemSize:(CGSize)size itemColor:(UIColor*)color;
- (void)asSegmentedWithItems:(NSArray*)items itemSize:(CGSize)size itemColor:(UIColor*)color round:(CGFloat)round;
@end

