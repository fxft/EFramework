//
//  BounceBlurTransitionAnimator.h
//  EFDemo
//
//  Created by mac on 16/5/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BounceBlurTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign) UINavigationControllerOperation operation;

@end
