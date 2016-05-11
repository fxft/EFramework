//
//  HMUIKeyboard.h
//  CarAssistant
//
//  Created by Eric on 14-3-19.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
/*
tips:输入框挡住控制样例
 ON_TextField(signal){
     UITextField *textfield  = signal.source;
     if ([signal is:[HMUITextField WILL_ACTIVE]]) {
         [HMUIKeyboard sharedInstance].accessor =  self.textFieldView;
         [HMUIKeyboard sharedInstance].accessorVisableRect = textfield.frame;
     }
 }
 */


#import <Foundation/Foundation.h>
#import "HMMacros.h"
#import "HMFoundation.h"


typedef void (^AccessorAnimationBlock)(BOOL showing, UIView* accessor) ;

@interface HMUIKeyboard : NSObject

AS_NOTIFICATION( SHOWN )			// 键盘弹出
AS_NOTIFICATION( HIDDEN )			// 键盘收起
AS_NOTIFICATION( HEIGHT_CHANGED )	// 输入法切换

AS_SINGLETON( HMUIKeyboard )

@property (nonatomic, readonly) BOOL					shown;//是否已显示
@property (nonatomic, readonly) BOOL					animating;//是否正在动画中
@property (nonatomic, readonly) CGFloat					height;//键盘高度
@property (nonatomic, HM_STRONG) UIView *					accessor;//可见协助视图
@property (nonatomic, HM_STRONG) UIView *					visabler;//保持可见视图

@property (nonatomic,HM_WEAK) UIResponder*         lastResponder;//不要拿出来用
@property (nonatomic,HM_WEAK) UIResponder*         resignResponder;//不要拿出来用

@property (nonatomic, readonly) NSTimeInterval			animationDuration;//键盘弹出时间
@property (nonatomic, readonly) UIViewAnimationCurve	animationCurve;//动画方式

@property (nonatomic, copy) AccessorAnimationBlock      accessorBlock;//键盘显示或关闭时出发

+ (void)hideKeyboard;

/**
 *  辅助方法
 */
- (void)hideKeyboard;
- (void)setAccessor:(UIView *)view;
- (void)showAccessor:(UIView *)view animated:(BOOL)animated;
- (void)hideAccessor:(UIView *)view animated:(BOOL)animated;
- (void)updateAccessorAnimated:(BOOL)animated duration:(NSTimeInterval)duration show:(BOOL)show;

@end
