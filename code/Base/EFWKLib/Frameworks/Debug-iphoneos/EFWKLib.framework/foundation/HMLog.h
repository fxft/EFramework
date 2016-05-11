//
//  HMLog.h
//  CarAssistant
//
//  Created by Eric on 14-2-21.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMPrecompile.h"

#undef	HMLOG
#define HMLOG( TAG, ... )        [[HMLog sharedInstance] level:(id)TAG freeFormat:__VA_ARGS__,NULL];

#undef	INFO
#define INFO( ... )              HMLOG(@"INFO",__VA_ARGS__,NULL)

#undef	PROGRESS
#define PROGRESS( ... )			 HMLOG(@"PROGRESS",__VA_ARGS__,NULL)

#undef	ERROR
#define ERROR( ... )             HMLOG(@"ERROR",__VA_ARGS__,NULL)

#undef	WARN
#define WARN( ... )              HMLOG(@"WARN",__VA_ARGS__,NULL)

#undef	CC
#define CC( ... )                HMLOG(__VA_ARGS__,NULL)


#undef	FUNC
#ifdef DEBUG
#define FUNC                     INFO(@"%s",__func__)
#else
#define FUNC
#endif


//打印耗时
#ifdef DEBUG
#define LogTimeCostBegin(tag) NSDate *dateBeginFPS##tag = [NSDate date];
#define LogTimeCostEndTo(tag,to,remark) NSDate *dateBeginFPS##tag = [NSDate date];\
        printf("%s [LogCost] %s from "#tag" to "#to" cost %.3fms\n",[[dateBeginFPS##tag stringWithDateFormat:@"dd HH:mm:ss.SSS"]UTF8String],[remark UTF8String],([dateBeginFPS##tag timeIntervalSinceDate:dateBeginFPS##to]*1000.f));
#else
#define LogTimeCostBegin(tag)
#define LogTimeCostEndTo(tag,to,remark)

#endif


/**
 *  eg. INFO(@"I",@"am",@"a",@"log",@"?",@(1),@"+",@"1",@"==",@(1+1));
 console:   [INFO]	I am a log ? 1 + 1 == 2
 *  eg. CC(@"MyTag",@"I",@"am",@"a",@"log",@"?",@(1),@"+",@"1",@"==",@(1+1));
 console:   [MyTag]	I am a log ? 1 + 1 == 2

 *  默认情况下DEBUG模式下可以打印日志，发布模式会自动关闭日志输出；具体配置请查看 "HMPrecompile.h"
 *  ps:要能打印基础数据类型 要研究一下 masonary的#define MASBoxValue(value) _MASBoxValue(@encode(__typeof__((value))), (value))
 */

@interface HMLog : NSObject
@property(nonatomic,HM_STRONG,readonly)  NSMutableSet *showTags;
/**
 *  设置成YES时，日志启动标签过滤；设置成NO时关闭标签过滤
 */
@property(nonatomic)            BOOL            enableTags;
@property(nonatomic)            BOOL            showINFO;
@property(nonatomic)            BOOL            showWARN;
@property(nonatomic)            BOOL            showPROGRESS;

/**
 *  前提enableTags 设置为YES
 *
 *  @param format eg:@"INFO",@"TEST"  则只显示INFO TEST
 */
+ (void)showCustom:(NSString *)format, ...;
+ (void)showCustomAndSystem:(NSString *)format, ...;//INFO WARN ERROR PROGRESS
+ (void)hideCustom:(NSString *)format, ...;

+ (HMLog *)sharedInstance;

+ (void)showTimeAhead:(BOOL)yesOrNo;

+ (void)setEnableTags:(BOOL)enable;

+ (void)showINFO;
+ (void)hideINFO;

+ (void)showWARN;
+ (void)hideWARN;

+ (void)showPROGRESS;
+ (void)hidePROGRESS;

- (void)level:(NSString*)level freeFormat:(id)format, ...;

@end
