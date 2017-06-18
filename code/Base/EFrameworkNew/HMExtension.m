//
//  HMExtension.m
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMExtension.h"


@implementation HMExtension

+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UILabel hook];
        [UINavigationController hook];
        [UIViewController hook];
        //    [UIWindow hook];
        
//        NSArray *selStringsArray = @[@"setText:"];
//        
//        [selStringsArray enumerateObjectsUsingBlock:^(NSString *selString, NSUInteger idx, BOOL *stop) {
//            NSString *mySelString = [@"sd_" stringByAppendingString:selString];
//            
//            Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(selString));
//            Method myMethod = class_getInstanceMethod(self, NSSelectorFromString(mySelString));
//            method_exchangeImplementations(originalMethod, myMethod);
//        }];
    });
}

@end
