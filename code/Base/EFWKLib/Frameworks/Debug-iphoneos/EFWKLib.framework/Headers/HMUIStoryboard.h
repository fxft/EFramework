//
//  HMUIStoryboard.h
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface  UIStoryboard(HMUIStoryboard)

+ (UIStoryboard *)storyBoard:(NSString *)boardName;

+ (UIViewController *)firstBoardInStory:(NSString *)board;
+ (UIViewController *)boardWithName:(NSString *)name inStory:(NSString *)board;

- (UIViewController *)firstBoard;
- (UIViewController *)boardWithName:(NSString *)name;

@end
