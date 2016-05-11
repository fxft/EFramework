//
//  HMRuntime.h
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMMacros.h"

#pragma mark -

/**
 *  类型识别
 */
@interface HMTypeEncoding : NSObject

AS_INT( UNKNOWN )
AS_INT( OBJECT )
AS_INT( NSNUMBER )
AS_INT( NSSTRING )
AS_INT( NSARRAY )
AS_INT( NSDICTIONARY )
AS_INT( NSDATE )
AS_INT( RLMARRAY )

+ (NSUInteger)typeOf:(const char *)attr;
+ (NSUInteger)typeOfAttribute:(const char *)attr;
+ (NSUInteger)typeOfObject:(id)obj;

+ (NSString *)classNameOf:(const char *)attr;
+ (NSString *)classNameOfAttribute:(const char *)attr;

+ (Class)classOfAttribute:(const char *)attr;

+ (BOOL)isAtomClass:(Class)clazz;

@end


@interface HMRuntime : NSObject

+ (NSArray *)allClasses;
+ (NSArray *)allSubClassesOf:(Class)clazz;
+ (NSArray *)allMethodOf:(Class)clazz;

@end

#pragma mark -


@interface NSObject(HMRuntime)

- (NSNumber *)asNSNumber;
- (NSString *)asNSString;
- (NSDate *)asNSDate;
- (NSData *)asNSData;	// TODO
- (NSArray *)asNSArray;
- (NSArray *)asNSArrayWithClass:(Class)clazz;
- (NSMutableArray *)asNSMutableArray;
- (NSMutableArray *)asNSMutableArrayWithClass:(Class)clazz;
- (NSDictionary *)asNSDictionary;
- (NSMutableDictionary *)asNSMutableDictionary;

/**
 *  对象转成字典、字符串、数据、RLMObject数据库支持
 */
- (id)objectToDictionary;
- (id)objectToString;
- (id)objectToData;

@end

#pragma mark -

@interface NSObject (HMRuntimeFormDict)
/**
 *  按本类进行对象声称
 *
 *  @param params 支持数组、字典、Json字符串、Json数据、以上
 *
 *  @return 常规对象、RLMObject数据库对象支持
 */
+ (id)objectsFromArray:(id)arr;
+ (id)objectFromDictionary:(id)dict;
+ (id)objectFromString:(id)str;
+ (id)objectFromData:(id)data;
+ (id)objectFromAny:(id)any;
/**
 *  快速打印类包含的方法
 */
+ (void)pritfClassMethod;

@end

#undef DEF_CONVERTPROPERTY_2_CLASS
#define DEF_CONVERTPROPERTY_2_CLASS(property,clazz) \
- (Class)convertPropertyClassFor_##property{ \
return clazz; \
}
/**
 *  属性同属性不同名称匹配，eg. {"a":1} 》》 objc.b
 *  DEF_REDIRECTPROPERTY_2_ALIAS(b,@[@"a"]),只要其中一个属性符合条件就成立
 *
 *  @param property b
 *  @param alias    a
 *
 *  @return a
 */
#undef DEF_REDIRECTPROPERTY_2_ALIAS
#define DEF_REDIRECTPROPERTY_2_ALIAS(property,alias) \
- (NSArray*)redirectPropertyAliasFor_##property{ \
NSAssert([alias isKindOfClass:[NSArray class]], @"redirectProperty error alias must be an NSArray");\
return alias;\
}



@interface NSDictionary (HMRuntimeForClass)
/**
 *  从字典创建出类(注意：支持属性名＋“__as”进行别名，支持DEF_REDIRECTPROPERTY_2_ALIAS，DEF_CONVERTPROPERTY_2_CLASS)
 *
 *  @param clazz 类
 *
 *  @return
 */
- (id)objectForClass:(Class)clazz;

/**
 *  对象打印，适用于需要使用objectForClass:的数据对象打印到控制台，打印出的结果可复制使用
 *
 *  @param name  第一个类名
 *  @param coding  是否支持<NSCoding>
 *  @param analysis 是否进行number类型转译
 *
 *  @return 
 */
- (BOOL)pritfMemberForClassName:(NSString*)name coding:(BOOL)coding numberAnalysis:(BOOL)analysis;

@end
