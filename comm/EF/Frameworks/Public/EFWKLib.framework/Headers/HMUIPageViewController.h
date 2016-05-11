//
//  HMUIPageViewController.h
//  EFExtend
//
//  Created by mac on 15/4/21.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HMUIPageViewControllerDelegate <UIPageViewControllerDelegate>

- (void)pageViewControllerHadTaped:(UIPageViewController*)pageViewController;

@end

@interface HMUIPageViewController : UIPageViewController
@property (nonatomic, assign) id <UIPageViewControllerDelegate,HMUIPageViewControllerDelegate> delegate;
@property (nonatomic) UIEdgeInsets edgeInsets;
@end
