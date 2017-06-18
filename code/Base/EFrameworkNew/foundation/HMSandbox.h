//
//  HMSandbox.h
//  CarAssistant
//
//  Created by Eric on 14-3-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMSandbox : NSObject

+ (NSString *)appPath;		// 程序目录，不能存任何东西
+ (NSString *)docPath;		// 文档目录，需要ITUNES同步备份的数据存这里
+ (NSString *)libPrefPath;	// 配置目录，配置文件存这里
+ (NSString *)libCachePath;	// 缓存目录，系统永远不会删除这里的文件，ITUNES会删除
+ (NSString *)tmpPath;		// 缓存目录，APP退出后，系统可能会删除这里的内容
/*目录生成*/
+ (BOOL)touch:(NSString *)path;
/*文件生成*/
+ (BOOL)touchFile:(NSString *)path;
/*目录生成 忽略名字*/
+ (BOOL)touchIgnoreName:(NSString *)path;
+ (NSString *)pathWithbundleName:(NSString*)bundleName fileName:(NSString *)file;
//可以通过 localizedStringForKey 方法获取不同的表单的字符串

@end
