//
//  NSObject+HMNotification.h
//  CarAssistant
//
//  Created by Eric on 14-3-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
/**
 *  通知服务的快捷方法
 *  ON_NOTIFICATION是监听通知的入口
 *  可通过DEF_NOTIFICATION定义通知名称
 *
 */
#import <Foundation/Foundation.h>
#import "HMMacros.h"

#pragma mark -

#define AS_NOTIFICATION( __name )	AS_STATIC_PROPERTY( __name )
#define DEF_NOTIFICATION( __name )	DEF_STATIC_PROPERTY3( __name, @"notify", [[self class] description] )

#define DEF_NOTIFICATION2( __name ,clazz)	DEF_STATIC_PROPERTY3( __name, @"notify", [clazz description] )

#undef	ON_NOTIFICATION
#define ON_NOTIFICATION( __notification ) \
- (void)handleNotification:(NSNotification *)__notification

#undef	ON_NOTIFICATION2
#define ON_NOTIFICATION2( __filter, __notification ) \
- (void)handleNotification_##__filter:(NSNotification *)__notification

#undef	ON_NOTIFICATION3
#define ON_NOTIFICATION3( __class, __name, __notification ) \
- (void)handleNotification_##__class##_##__name:(NSNotification *)__notification

@protocol ON_NOTIFICATION_handle <NSObject>

@optional
ON_NOTIFICATION( __notification );
ON_NOTIFICATION2( __filter, __notification );
ON_NOTIFICATION3( __class, __name, __notification );

@end

#pragma mark -

@interface NSNotification(HMNotification)

- (BOOL)is:(NSString *)name;
- (BOOL)isKindOf:(NSString *)prefix;

@end

#pragma mark -

@interface NSObject(HMNotification)

+ (NSString *)NOTIFICATION;
+ (NSString *)NOTIFICATION_TYPE;

- (void)handleNotification:(NSNotification *)notification;

- (void)observeNotification:(NSString *)name;
- (void)unobserveNotification:(NSString *)name;
- (void)unobserveAllNotifications;

+ (BOOL)postNotification:(NSString *)name;
+ (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object;

- (BOOL)postNotification:(NSString *)name;
- (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object;

@end