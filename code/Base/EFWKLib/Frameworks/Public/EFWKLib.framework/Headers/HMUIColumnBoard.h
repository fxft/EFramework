//
//  HMUIColumnBoard.h
//  EFExtend
//
//  Created by mac on 15/7/2.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

typedef NS_ENUM(NSUInteger, ColumPosition) {
    ColumPositionLeft,
    ColumPositionRight,
};

@interface HMUIColumnBoard : HMUIBoard

@property (nonatomic,HM_STRONG,readonly) UIViewController *leftController;
@property (nonatomic,HM_STRONG,readonly) UIViewController *rightController;
@property (nonatomic) CGFloat leftWidth;
@property (nonatomic) CGFloat rightWidth;


//需要子类返回上下左右控制器的对象

- (UIViewController*)columControllerForPosition:(ColumPosition)position;
- (CGFloat)columWidthForPosition:(ColumPosition)position;

@end
