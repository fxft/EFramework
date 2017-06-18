//
//  UIView+HMAnimation.h
//  EFMWKLib
//
//  Created by Eric on 14-11-8.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HMAnimation)
/*
 view 按Y旋转，参数yes 顺时针，no 逆时针
 */
/**
*  view 按Y轴无限旋转，并返回旋转CAKeyframeAnimation
*
*  @param clockwise yes 顺时针，no 逆时针
*  @param durantion 时间
*
*  @return 返回可攻设置的CAKeyframeAnimation
*/
- (CAKeyframeAnimation*)animationRoateY:(BOOL)clockwise durantion:(CGFloat)durantion;
/**
 *  视图晃动
 *
 *   durantion
 *
 *   return
 */
- (CABasicAnimation*)animationShakeDurantion:(CGFloat)durantion;
/**
 *  系统
 */
+ (void)animationVibrate;

@end

#pragma mark - open页面切换 方块掉落

@interface AnimatorZBFallenBricks : NSObject <UIViewControllerAnimatedTransitioning>
AS_SINGLETON(AnimatorZBFallenBricks)

@end



/**
 Standard random float code
 @param min
 @param max
 @result random number between min and max
 */
#define RANDOM_FLOAT(MIN,MAX) (((CGFloat)arc4random() / 0x100000000) * (MAX - MIN) + MIN);


@interface AnimatorTransitionHorizontalLines : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL presenting;
@end
