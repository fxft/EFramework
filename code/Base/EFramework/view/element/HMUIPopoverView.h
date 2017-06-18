//
//  HMUIPopoverView.h
//  GPSService
//
//  Created by Eric on 14-4-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
/*
 tips:
 UITableView *tableView = nil;
 HMUIPopoverView *popover = nil;
 if (popover==nil || ![popover.contentView isKindOfClass:[UITableView class]]) {
 [popover release];
 popover = (id)[[HMUIPopoverView spawnWithReferView:btn inView:self.view]retain];
 }
 
 popover.containerMode = UIPopoverContainerModeLight;
 if (tableView==nil) {
 tableView = (id)popover.contentView;
 if (![tableView isKindOfClass:[UITableView class]]) {
 tableView = [[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain]autorelease];
 
 tableView.delegate = self;
 tableView.dataSource = self;
 if (IOS7_OR_LATER) {
 tableView.separatorInset = UIEdgeInsetsAll(0);
 }
 popover.contentView = tableView;
 popover.popoverArrowDirection  = UIPopoverArrowDirectionUnknown;
 }
 }
 popover.referView = btn;
 popover.contentRect = CGRectMakeBound(btn.width, MIN(quicks.count*41, 5*41));
 
 tableView.tagString = btn.tagString;
 [tableView reloadData];
 [popover showWithAnimated:YES];
 */

#import "HMUIView.h"

typedef enum {
    UIPopoverContainerModeLight=1UL<<0,/*淡蓝色*/
    UIPopoverContainerModeGlass=1UL<<1,/*暗色*/
    UIPopoverContainerModeBottom=1UL<<2,/*弹到底部风格*/
    UIPopoverContainerModeTop=1UL<<3,/*弹到顶部风格*/
}UIPopoverContainerMode;

typedef enum : NSUInteger {
    UIPopoverBackgroundStyle_defatul,
    UIPopoverBackgroundStyle_shadow,
    UIPopoverBackgroundStyle_glass,
} UIPopoverBackgroundStyle;

@protocol HMUIPopoverViewTableData <NSObject>

@property (nonatomic,copy)  NSString *      popoverTitle;
@property (nonatomic,HM_STRONG)  NSNumber *      popoverSelected;

@end


#define ON_PopoverView( signal) ON_SIGNAL2(HMUIPopoverView, signal)

@protocol ON_PopoverView_handle <NSObject>

ON_PopoverView( signal);

@end


@interface HMUIPopoverView : HMUIView

@property (nonatomic,HM_STRONG)    UIView *     contentView;//设置弹出框内视图(设置前请确认内容大小)
@property (nonatomic, HM_WEAK)  UIView *        referView;//参考点视图
@property (nonatomic) BOOL              touchAutoHide;
@property (nonatomic) BOOL              contentCustom;//弹出框不带箭头效果
@property (nonatomic) CGRect            contentRect;//如果设置成self.bounds且不为zero 则忽略style背景
@property (nonatomic)    CGPoint        contentOffset;
/**
 *  弹出框风格 默认定义两种配色风格，淡蓝色，暗色，支持自定义颜色
 */
@property (nonatomic)  UIPopoverContainerMode  containerMode;
//弹出框填充色
@property (nonatomic,HM_STRONG) UIColor *solidFillColor;
//弹出框阴影颜色
@property (nonatomic,HM_STRONG) UIColor *shadowColor;
//弹出框边框颜色
@property (nonatomic,HM_STRONG) UIColor *borderColor;
//弹出框玻璃质感
@property (nonatomic) BOOL showGlass;
//显示背景模糊感
@property (nonatomic) UIPopoverBackgroundStyle backgroundStyle;
//设置referview高亮
@property (nonatomic) BOOL showReferHighlight;
@property (nonatomic) CGFloat referHighlightRadius;//高亮圆角

@property (nonatomic)  UIPopoverArrowDirection popoverArrowDirection;//箭头方向

+ (instancetype)spawnWithReferView:(UIView*)view inView:(UIView *)inView;

@property (nonatomic, HM_STRONG) NSArray *tableDatas;//--dic with "popoverTitle" key  "popoverSelected" key for selce;不建议使用，建议自定义tableview添加到contentView中
+ (instancetype)spawnForTableWithReferView:(UIView*)view inView:(UIView *)inView datas:(NSArray*)datas;
AS_SIGNAL( TableCell )		//--UITableViewCell out put   input object  NSIndexPath
AS_SIGNAL( TableRows )		//--NSInterget out put
AS_SIGNAL( TableSelect )    //input object NSIndexPath

/**
 *  更新content的大小
 *
 *   rect 相对
 */
- (void)resetContentViewRect:(CGRect)rect;
/**
 *  自定义autolayout视图的支持
 *
 *   view       自定义视图
 *   autolayout 回调，contentView已被添加到父视图，建议不设置与父视图相对的属性eg.top left bottm right
 */
- (void)setContentView:(UIView*)view autolayout:(void(^)(UIView *contentView))autolayout;

- (id)initWithFrame:(CGRect)frame withReferView:(UIView*)view inView:(UIView *)inView;

/**
 *  弹出
 *
 *   animated 是否支持动画
 */
- (void)showWithAnimated:(BOOL)animated;
- (void)dissmissAnimated:(BOOL)animated;

@end
