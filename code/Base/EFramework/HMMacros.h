//
//  HMMacros.h
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
/**
 *  宏定义文件
 *
 *
 *
 *
 */
#import <Foundation/Foundation.h>

#ifdef __OBJC__

#import "HMPrecompile.h"


#import <objc/runtime.h>
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>

#endif	// #ifdef __OBJC__

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#if !defined (HM_EXTERN)
#if defined __cplusplus

#define HM_EXTERN extern "C"
#define HM_EXTERN_C_BEGIN extern "C" {
#define HM_EXTERN_C_END }

#else

#define HM_EXTERN extern
#define HM_EXTERN_C_BEGIN
#define HM_EXTERN_C_END

#endif
#endif

/**
 *  类的单例快速定义
 *
 *   __class
 *
 *   return 单例
 */
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
- (__class *)sharedInstance; \
+ (__class *)sharedInstance;

/**
 *  类的单例快速实现
 *
 *   __class
 *
 *   return 单例
 */
#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
- (__class *)sharedInstance \
{ \
    return [__class sharedInstance]; \
} \
+ (__class *)sharedInstance \
{ \
    static dispatch_once_t once; \
    static __class * __singleton__; \
    dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
    return __singleton__; \
}

/**
 *  类的自动单例快速实现
 *
 *   __class
 *
 *   return 单例
 */
#undef	DEF_SINGLETON_AUTOLOAD
#define DEF_SINGLETON_AUTOLOAD( __class ) \
- (__class *)sharedInstance \
{ \
    return [__class sharedInstance]; \
} \
+ (__class *)sharedInstance \
{ \
    static dispatch_once_t once; \
    static __class * __singleton__; \
    dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
    return __singleton__; \
} \
+ (void)load \
{ \
    [self sharedInstance]; \
}

#pragma mark -


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0

/**
 *  日历控件的枚举适配
 *
 */
#define NSEraCalendarUnit  NSCalendarUnitEra
#define NSYearCalendarUnit NSCalendarUnitYear
#define NSMonthCalendarUnit NSCalendarUnitMonth
#define NSDayCalendarUnit NSCalendarUnitDay
#define NSHourCalendarUnit NSCalendarUnitHour
#define NSMinuteCalendarUnit NSCalendarUnitMinute
#define NSSecondCalendarUnit  NSCalendarUnitSecond
#define NSWeekCalendarUnit  kCFCalendarUnitWeek
#define NSWeekdayCalendarUnit  NSCalendarUnitWeekday
#define NSWeekdayOrdinalCalendarUnit  NSCalendarUnitWeekdayOrdinal
#define NSQuarterCalendarUnit  NSCalendarUnitQuarter
#define NSWeekOfMonthCalendarUnit  NSCalendarUnitWeekOfMonth
#define NSWeekOfYearCalendarUnit  NSCalendarUnitWeekOfYear
#define NSYearForWeekOfYearCalendarUnit  NSCalendarUnitYearForWeekOfYear
#define NSCalendarCalendarUnit  NSCalendarUnitCalendar
#define NSTimeZoneCalendarUnit  NSCalendarUnitTimeZone

#endif

//#if __IPHONE_8_0

//#endif

#pragma mark -

#undef	AS_STATIC_PROPERTY
#define AS_STATIC_PROPERTY( __name ) \
        - (NSString *)__name; \
        + (NSString *)__name;

#if __has_feature(objc_arc)

#undef	DEF_STATIC_PROPERTY
#define DEF_STATIC_PROPERTY( __name ) \
        - (NSString *)__name \
        { \
            return (NSString *)[[self class] __name]; \
        } \
        + (NSString *)__name \
        { \
            static NSString * __local = nil; \
            if ( nil == __local ) \
            { \
                __local = [NSString stringWithFormat:@"%s", #__name]; \
            } \
            return __local; \
        }

#else

#undef	DEF_STATIC_PROPERTY
#define DEF_STATIC_PROPERTY( __name ) \
        - (NSString *)__name \
        { \
            return (NSString *)[[self class] __name]; \
        } \
        + (NSString *)__name \
        { \
            static NSString * __local = nil; \
            if ( nil == __local ) \
            { \
                __local = [[NSString stringWithFormat:@"%s", #__name] retain]; \
            } \
            return __local; \
        }

#endif

#if __has_feature(objc_arc)

#undef	DEF_STATIC_PROPERTY2
#define DEF_STATIC_PROPERTY2( __name, __prefix ) \
        - (NSString *)__name \
        { \
            return (NSString *)[[self class] __name]; \
        } \
        + (NSString *)__name \
        { \
            static NSString * __local = nil; \
            if ( nil == __local ) \
            { \
                __local = [NSString stringWithFormat:@"%@.%s", __prefix, #__name]; \
            } \
            return __local; \
        }

#else

#undef	DEF_STATIC_PROPERTY2
#define DEF_STATIC_PROPERTY2( __name, __prefix ) \
        - (NSString *)__name \
        { \
            return (NSString *)[[self class] __name]; \
        } \
        + (NSString *)__name \
        { \
            static NSString * __local = nil; \
            if ( nil == __local ) \
            { \
                __local = [[NSString stringWithFormat:@"%@.%s", __prefix, #__name] retain]; \
            } \
            return __local; \
        }

#endif

#if __has_feature(objc_arc)

#undef	DEF_STATIC_PROPERTY3
#define DEF_STATIC_PROPERTY3( __name, __prefix, __prefix2 ) \
        - (NSString *)__name \
        { \
            return (NSString *)[[self class] __name]; \
        } \
        + (NSString *)__name \
        { \
            static NSString * __local = nil; \
            if ( nil == __local ) \
            { \
                __local = [NSString stringWithFormat:@"%@.%@.%s", __prefix, __prefix2, #__name]; \
            } \
            return __local; \
        }

#else

#undef	DEF_STATIC_PROPERTY3
#define DEF_STATIC_PROPERTY3( __name, __prefix, __prefix2 ) \
        - (NSString *)__name \
        { \
            return (NSString *)[[self class] __name]; \
        } \
        + (NSString *)__name \
        { \
            static NSString * __local = nil; \
            if ( nil == __local ) \
            { \
                __local = [[NSString stringWithFormat:@"%@.%@.%s", __prefix, __prefix2, #__name] retain]; \
            } \
            return __local; \
        }

#endif

#if __has_feature(objc_arc)

#undef	DEF_STATIC_PROPERTY4
#define DEF_STATIC_PROPERTY4( __name, __value, __prefix, __prefix2 ) \
        - (NSString *)__name \
        { \
            return (NSString *)[[self class] __name]; \
        } \
        + (NSString *)__name \
        { \
            static NSString * __local = nil; \
            if ( nil == __local ) \
            { \
                __local = [NSString stringWithFormat:@"%@.%@.%s", __prefix, __prefix2, #__value]; \
            } \
            return __local; \
        }

#else

#undef	DEF_STATIC_PROPERTY4
#define DEF_STATIC_PROPERTY4( __name, __value, __prefix, __prefix2 ) \
        - (NSString *)__name \
        { \
            return (NSString *)[[self class] __name]; \
        } \
        + (NSString *)__name \
        { \
            static NSString * __local = nil; \
            if ( nil == __local ) \
            { \
                __local = [[NSString stringWithFormat:@"%@.%@.%s", __prefix, __prefix2, #__value] retain]; \
            } \
            return __local; \
        }

#endif
#pragma mark -

#undef	AS_STATIC_PROPERTY_INT
#define AS_STATIC_PROPERTY_INT( __name ) \
- (NSInteger)__name; \
+ (NSInteger)__name;

#undef	DEF_STATIC_PROPERTY_INT
#define DEF_STATIC_PROPERTY_INT( __name, __value ) \
- (NSInteger)__name \
{ \
    return (NSInteger)[[self class] __name]; \
} \
+ (NSInteger)__name \
{ \
    return __value; \
}

#undef	AS_INT
#define AS_INT	AS_STATIC_PROPERTY_INT

#undef	DEF_INT
#define DEF_INT	DEF_STATIC_PROPERTY_INT

#pragma mark -

#undef	AS_STATIC_PROPERTY_NUMBER
#define AS_STATIC_PROPERTY_NUMBER( __name ) \
- (NSNumber *)__name; \
+ (NSNumber *)__name;

#undef	DEF_STATIC_PROPERTY_NUMBER
#define DEF_STATIC_PROPERTY_NUMBER( __name, __value ) \
- (NSNumber *)__name \
{ \
    return (NSNumber *)[[self class] __name]; \
} \
+ (NSNumber *)__name \
{ \
    return [NSNumber numberWithInt:__value]; \
}

#undef	AS_NUMBER
#define AS_NUMBER	AS_STATIC_PROPERTY_NUMBER

#undef	DEF_NUMBER
#define DEF_NUMBER	DEF_STATIC_PROPERTY_NUMBER

#pragma mark -

#undef	AS_STATIC_PROPERTY_STRING
#define AS_STATIC_PROPERTY_STRING( __name ) \
- (NSString *)__name; \
+ (NSString *)__name;

#undef	DEF_STATIC_PROPERTY_STRING
#define DEF_STATIC_PROPERTY_STRING( __name, __value ) \
- (NSString *)__name \
{ \
    return [[self class] __name]; \
} \
+ (NSString *)__name \
{ \
    return __value; \
}

/**
 *  快速定义一个字符属性
 *
 *   属性名称
 *
 *   return
 */
#undef	AS_STRING
#define AS_STRING	AS_STATIC_PROPERTY_STRING

/**
 *  快速实现一个字符属性
 *
 *   属性名称,属性值
 *
 *   return
 */
#undef	DEF_STRING
#define DEF_STRING	DEF_STATIC_PROPERTY_STRING


#define WS(weakSelf)  __unsafe_unretained __typeof(&*self)weakSelf = self;//__weak_type __typeof(&*self)weakSelf = self;
#define SS(strongSelf)  __strong_type __typeof(&*self)strongSelf = weakSelf;


/**
 *  语法糖
 *
 *
 */
//不允许被继承
/*
 使用这个属性可以定义一个 Final Class，也就是说，一个不可被继承的类，假设我们有个名叫 Eunuch（太监） 的类，但并不希望有人可以继承自它：
 __attribute__((objc_subclassing_restricted))
 @interface Eunuch : NSObject
 @end
 @interface Child : Eunuch // <--- Compile Error
 @end
 */
//需要调用父类方法
/*
 aka: NS_REQUIRES_SUPER，标志子类继承这个方法时需要调用 super，否则给出编译警告：
 @interface Father : NSObject
 - (void)hailHydra __attribute__((objc_requires_super));
 @end
 @implementation Father
 - (void)hailHydra {
 NSLog(@"hail hydra!");
 }
 @end
 @interface Son : Father
 @end
 @implementation Son
 - (void)hailHydra {
 } // <--- Warning missing [super hailHydra]
 @end
 */
/*
 Objective-C 中的 @(...) 语法糖可以将基本数据类型 box 成 NSNumber 对象，假如想 box 一个 struct 类型或是 union 类型成 NSValue 对象，可以使用这个属性：
 
 typedef struct __attribute__((objc_boxable)) {
 CGFloat x, y, width, height;
 } XXRect;
 
 CGRect rect1 = {1, 2, 3, 4};
 NSValue *value1 = @(rect1); // <--- Compile Error
 XXRect rect2 = {1, 2, 3, 4};
 NSValue *value2 = @(rect2); // √
 */
/*
 构造器和析构器，加上这两个属性的函数会在分别在可执行文件（或 shared library）load 和 unload 时被调用，可以理解为在 main() 函数调用前和 return 后执行：
 __attribute__((constructor))
 static void beforeMain(void) {
 NSLog(@"beforeMain");
 }
 __attribute__((destructor))
 static void afterMain(void) {
 NSLog(@"afterMain");
 }
 int main(int argc, const char * argv[]) {
 NSLog(@"main");
 return 0;
 }
 
 // Console:
 // "beforeMain" -> "main" -> "afterMain"
 */
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#pragma mark -
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)


@interface UIView(LifeCycle)

+ (instancetype)spawn;
+ (instancetype)view;	// same as spawn
- (void)initSelfDefault;

- (void)load;
- (void)unload;

@end

#pragma mark -

@interface UIControl(LifeCycle)

- (void)initSelfDefault;
- (void)load;
- (void)unload;

@end
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@interface HMMacros : NSObject

@end



