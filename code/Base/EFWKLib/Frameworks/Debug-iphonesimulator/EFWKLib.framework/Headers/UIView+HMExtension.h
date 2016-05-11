//
//  UIView+HMExtension.h
//  CarAssistant
//
//  Created by Eric on 14-3-9.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"
#import "HMUIView.h"

typedef NS_ENUM(NSUInteger, BadgeAutoPosition) {
    badgeAutoPosition_None,
    badgeAutoPosition_Custom,
    badgeAutoPosition_Top_right,
    badgeAutoPosition_Top_left,
    badgeAutoPosition_Center,
    badgeAutoPosition_Center_right,
    badgeAutoPosition_Center_left,
    badgeAutoPosition_Bottom_right,
    badgeAutoPosition_Bottom_left,
};

typedef NS_ENUM(NSUInteger, BadgeType) {
    badgeType_Extrude=0,
    badgeType_Flatten,
    badgeType_FlattenBorder
};

/**
 *  角标
 */
@interface HMBadgeLabel : HMUIView
@property (nonatomic) BadgeType type;
@property (nonatomic,HM_STRONG) UIColor *color;
@property (nonatomic,HM_STRONG) UILabel *textLabel;
@property (nonatomic,HM_STRONG) NSString *text;
@property (nonatomic)CGSize     maxSize;
@property (nonatomic)CGPoint     customPosition;
@property (nonatomic)BadgeAutoPosition  autoPosition;//0:none 1:top-right 2:top-left 3:center  4:bottom-right 5:bottom-left
@end

/**
 *  阴影ImageView
 */
@interface HMUIShadowImageView : UIImageView
@property (nonatomic)  StyleEmbossShadow style;
@property (nonatomic)  CGFloat blur;
@property (nonatomic)  CGFloat level;
@property (nonatomic)  CGPoint shadowOffset;

@property (nonatomic,HM_STRONG) UIColor *color;
@end


@interface UIView (HMExtension)

@property (nonatomic, HM_STRONG) NSString *		tagString;

//背景
@property (nonatomic, readonly) UIImageView *	backgroundImageView;
@property (nonatomic, HM_STRONG) UIImage *		backgroundImage;

//角标内容
@property (nonatomic, HM_STRONG) NSString *		badgeText;
@property (nonatomic, HM_STRONG,readonly) UILabel *		badgeTextLabel;

- (HMBadgeLabel*)setBadgeType:(NSInteger)type color:(UIColor*)color maxSize:(CGSize)maxSize;
- (HMBadgeLabel *)badgeLabel;

/*
 *  生成边框阴影，非实时,style > styleEmbossDarkLineBottom 时依附视图最小20x20
 */
- (UIImageView *)showBackgroundShadowStyle:(StyleEmbossShadow)style blur:(CGFloat)blur level:(CGFloat)level offset:(CGPoint)offset color:(UIColor*)shadowColor;

- (UIImageView *)showBackgroundShadowStyle:(StyleEmbossShadow)style blur:(CGFloat)blur level:(CGFloat)level color:(UIColor*)shadowColor;

- (UIImageView *)showBackgroundShadowStyle:(StyleEmbossShadow)style color:(UIColor*)shadowColor;

- (UIImageView *)showBackgroundShadowStyle:(StyleEmbossShadow)style;

- (HMUIShadowImageView *)shadowImageViewWithStyle:(StyleEmbossShadow)style;

- (void)hideBackgroundShadowStyle:(StyleEmbossShadow)style;

/**
 *  根据view的类名加载xib文件
 *
 *  @return 最后一个
 */
+ (instancetype)viewFromXib;

- (UIView *)viewWithTagString:(NSString *)value;
/**
 *  获取view归属的controller
 *
 *  @return 
 */
- (UIViewController *)viewController;
/**
 *  debug模式下 需要显示视图的frame信息，会在视图左上角显示
 *
 *  @param yesOrNo
 *
 *  @return 
 */
- (UILabel *)showFrameText:(BOOL)yesOrNo;
/**
 *  在视图中间显示holder
 *
 *  @param holder  需要显示的holder 只需要关心大小
 *  @param yesOrNo 显示或隐藏
 */
- (void)showHolder:(UIView *)holder show:(BOOL)yesOrNo animated:(BOOL)animated;
- (void)showHolder:(UIView *)holder show:(BOOL)yesOrNo center:(CGPoint)center animated:(BOOL)animated;

//这个会很卡
- (void)showshadowColor:(UIColor*)shadowColor;

//现实倒影
- (void)showReflection;
@end
