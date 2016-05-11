//
//  HMCache.h
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
/**
 *  本地简单存储
 */


#import "HMPrecompile.h"

/**
 *  协议接口
 */
#import "HMCacheProtocol.h"
/**
 *  文件存储
 */
#import "HMFileCache.h"
/**
 *  内存存储
 */
#import "HMMemoryCache.h"
/**
 *  加密存储，适用于简短的密码或需要加密存储的用户数据
 */
#import "HMKeychain.h"

/**
 *  存储快捷使用工具
 */
#import "NSObject+HMKeychain.h"
#import "NSObject+HMUserDefaults.h"
#import "NSObject+HMKeyedArchiver.h"