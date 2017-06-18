//
//  HMUIStarView.h
//  EFExtend
//
//  Created by mac on 15/8/18.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
/**
 *  评星控件
 */
@interface HMUIStarView : UIControl

@property (nonatomic) IBInspectable NSUInteger maximumValue;//最大
@property (nonatomic) IBInspectable CGFloat minimumValue;//最小
@property (nonatomic) IBInspectable CGFloat value;//但前数值
@property (nonatomic) IBInspectable CGFloat spacing;//星星间隔
@property (nonatomic) IBInspectable BOOL allowsHalfStars;//是否支持半星

@property (nonatomic, strong) IBInspectable UIImage *emptyStarImage;//空图
@property (nonatomic, strong) IBInspectable UIImage *halfStarImage;//半星图，可为空
@property (nonatomic, strong) IBInspectable UIImage *filledStarImage;//全星图

@end
