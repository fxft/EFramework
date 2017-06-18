//
//  HMUIButton.h
//  CarAssistant
//
//  Created by Eric on 14-3-19.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"
#import "HMEvent.h"


@class UIButten;

typedef enum{
    UIButtenTypeNormal = 0,
    UIButtenTypeAutoSelect = 1UL<<1,/*常规情况下附带选中操作*/
    UIButtenTypeIconSideRight = (1UL<<2),/*Icon放在右边*/
    UIButtenTypeIconSideTop = (1UL<<3),
    UIButtenTypeIconSideLeft = (1UL<<4),
    UIButtenTypeIconSideBottom = (1UL<<5),
    UIButtenTypeCheckBox = (1UL<<6 | UIButtenTypeAutoSelect),/*自带选中操作*/
    UIButtenTypeIconClickedInside = (1UL<<7),/*点击checkbox区别与点击其他区域的事件*/
    UIButtenTypeShaped=1UL<<8,/*点击在图片的透明部分不响应事件*/
    UIButtenTypeContenSideLeft = (1UL<<9),/*整体靠左*/
    UIButtenTypeContenSideRight = (1UL<<10),/*整体靠右*/
    UIButtenTypeContenSideTop = (1UL<<11),/*整体靠上*/
    UIButtenTypeContenSideBottom = (1UL<<12),/*整体靠下*/
}UIButtenType;

typedef void (^ButtenClicked)(NSString* state);

#define ON_BUTTON_TOUCH_UP_INSIDE( signal) ON_SIGNAL3(UIButton, TOUCH_UP_INSIDE, signal)

#define ON_Button( signal) ON_SIGNAL2(UIButten, signal)

@protocol ON_Button <NSObject>

ON_Button( signal);

@optional
ON_BUTTON_TOUCH_UP_INSIDE( signal);

@end
/**
 *  Button的扩展，不需要繁琐的添加事件监听，只需要实现 ON_BUTTON方法
 */
@interface UIButten : UIButton

AS_SIGNAL( TOUCH_DOWN )			// 按下
AS_SIGNAL( TOUCH_DOWN_LONG )	// 长按
AS_SIGNAL( TOUCH_DOWN_REPEAT )	// 双击
AS_SIGNAL( TOUCH_UP_INSIDE )	// 抬起（击中）
AS_SIGNAL( TOUCH_UP_OUTSIDE )	// 抬起（未击中）
AS_SIGNAL( TOUCH_UP_CANCEL )	// 撤销
AS_SIGNAL( TOUCH_CHECK_INSIDE )	// 抬起（击中，当button 是check类型时）

AS_SIGNAL( DRAG_INSIDE )		// 拖出
AS_SIGNAL( DRAG_OUTSIDE )		// 拖入
AS_SIGNAL( DRAG_ENTER )			// 进入
AS_SIGNAL( DRAG_EXIT )			// 退出

#define kAlphaVisibleThreshold (0.1f)
@property(nonatomic)          UIEdgeInsets backgroundImageEdgeInsets;                // default is UIEdgeInsetsZero
@property (nonatomic) BOOL					enableAllEvents;//默认关闭，只支持TOUCH_UP_INSIDE
/*保持图片的大小，居中*/
@property (nonatomic) CGSize               imageSize;//设置图片大小
@property (nonatomic) CGFloat               textMargin;//设置图片与文字间隔
/*chenckBox的样式，box在左边,title在右边*/
@property (nonatomic) UIButtenType         buttenType;//按钮样式

@property (nonatomic,HM_STRONG) id          userInfo;//用户附加数据

- (BOOL)is:(NSString *)string;

- (instancetype)onClicked:(ButtenClicked)clk;//当设置改属性时，将不相应On_Button{}

/**
 *  设置网络图片
 *
 *   url 是完整的地址
 *   state 
 *  note 注意释放控件前请积极调用 [self disableHttpRespondersByTagString:@"btnTagstring"]
 */
- (void)setImageWithURLString:(NSString *)url forState:(UIControlState)state;

- (void)setImageWithURLString:(NSString *)url forState:(UIControlState)state placeholder:(UIImage*)placeholderImage;

- (void)setBackgroundImageWithURLString:(NSString *)url forState:(UIControlState)state;

- (void)setBackgroundImageWithURLString:(NSString *)url forState:(UIControlState)state placeholder:(UIImage*)placeholderImage;


/**
 *  设置背景图片，已对图片进行stretched处理
 *
 *   name  @"test.png" => @"test_up.png",@"test_down.png",@"test_select.png",@"test_disable.png"
 *   title 设置normal的标题
 */
- (void)setBackgroundImagePrefixName:(NSString*)name title:(NSString *)title;
/**
 *  设置前景图片
 *
 *   name  @"test.png" => @"test_up.png",@"test_down.png",@"test_select.png",@"test_disable.png"
 *   title
 */
- (void)setImagePrefixName:(NSString*)name title:(NSString *)title;

/**
 *  设置字体
 *
 *   font  字体
 *   state 控制状态
 */
- (void)setTitleFont:(UIFont *)font forState:(UIControlState)state;

@end
