//
//  NSObject+HMKeyedArchiver.h
//  CarAssistant
//
//  Created by Eric on 14-4-23.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (HMKeyedArchiver)
- (NSString*)filePathArchiver;
//[NSString stringWithFormat:@"%@/archiver",[HMSandbox libCachePath]]
/**
 *  支持 NSCoding协议的对象保存
 *
 *   name 支持path路径
 *
 *   return 存储地址
 */
- (NSString *)saveWithArchiver:(NSString*)name;
+ (instancetype)restoreWithArchiver:(NSString*)name;
+ (BOOL)hadSavedWithArchiver:(NSString*)name;
- (void)removeAllObjectsForArchiver:(NSString *)branch;
- (void)removeArchiver:(NSString *)name;

@end

@interface NSObject (HMPlist)
- (NSString*)filePathPlist;
/**
 *  NSArray NSDictionary对象保存
 *
 *   name 支持path路径
 *
 *   return 存储地址
 */
- (NSString *)saveWithPlist:(NSString*)name;
+ (instancetype)restoreWithPlist:(NSString*)name;
+ (BOOL)hadSavedWithPlist:(NSString*)name;
- (void)removeAllObjectsForPlist:(NSString *)branch;
- (void)removePlist:(NSString *)name;

@end
