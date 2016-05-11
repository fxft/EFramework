//
//  HMUIStack.h
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"

@class HMUIBoard;
@class HMUITransition;


@interface HMUIStack : UINavigationController
@property (nonatomic, readonly) NSArray *				boards;
@property (nonatomic, readonly) HMUIBoard *             topBoard;

/**
 *  导航控制器初始化，带有自定义的NavigationBar（HMUINavigationBar）,可支持透明的导航条
 *
 *  @param rootViewController
 *
 *  @return
 */
- (instancetype)initCustomBarWithRootViewController:(UIViewController *)rootViewController;

@end

@interface UINavigationController (HMUIStackNavigation)
- (void)updateNavigationBar;

@end