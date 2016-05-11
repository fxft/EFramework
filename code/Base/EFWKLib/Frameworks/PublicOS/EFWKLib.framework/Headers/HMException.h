//
//  HMException.h
//  CarAssistant
//
//  Created by Eric on 14-4-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (UncaughtException)

- (void) onCrash_divByZero;
- (void) onCrash_deallocatedObject;
- (void) onCrash_outOfBounds;
- (void) onCrash_unimplementedSelector;

@end

/**
 *  并没什么鸟用
 */
@interface HMException : NSObject
///服务器地址 eg. @"www.on4s.com/exception?"
+ (void) setUrl:(NSString*)url;
///发送的email eg. @"chenhm@fortunetone.com"
+ (void) setEmail:(NSString*)email;
+ (void) setUserName:(NSString*)name;
//custom 自定义捕获处理函数：yes   为no：还原到系统
+ (void) setDefaultHandler:(BOOL)custom;
+ (NSUncaughtExceptionHandler*) getHandler;
@end
