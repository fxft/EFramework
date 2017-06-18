//
//  NSObject+HMExtension.h
//  CloudDog
//
//  Created by Eric on 14-6-30.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

#define as(TYPE) as([TYPE class])

@interface NSObject (HMExtension)
/**
 *  runtime
 *
 *   origSelector 被黑的选择器(方法)
 *   newSelector  新选择器(方法)
 *
 *   return 被黑的选择器(方法)
 */
+ (IMP)swizzleSelector:(SEL)origSelector withIMP:(SEL)newSelector;

/**
 *  压缩解压,必须使用ZipArchive类
 *
 *   path 路径
 *   toDirectory  解压目录
 */
- (void)unzip:(NSString*)path toDirectory:(NSString*)toDirectory;
- (void)zip:(NSString*)path newName:(NSString*)newName;

@end
