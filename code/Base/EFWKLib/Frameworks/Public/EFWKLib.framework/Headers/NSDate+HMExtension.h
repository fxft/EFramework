//
//  NSDate+HMExtension.h
//  CarAssistant
//
//  Created by Eric on 14-4-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SECOND	(1)
#define MINUTE	(60 * SECOND)
#define HOUR	(60 * MINUTE)
#define DAY		(24 * HOUR)
#define MONTH	(30 * DAY)

@interface NSDate (HMExtension)

@property (nonatomic, readonly) NSInteger	year;
@property (nonatomic, readonly) NSInteger	month;
@property (nonatomic, readonly) NSInteger	day;
@property (nonatomic, readonly) NSInteger	hour;
@property (nonatomic, readonly) NSInteger	minute;
@property (nonatomic, readonly) NSInteger	second;
@property (nonatomic, readonly) NSInteger	weekday;

+ (NSDate*)date:(NSDate*)date forYear:(NSInteger)year;
+ (NSDate*)date:(NSDate*)date forMonth:(NSInteger)month;
+ (NSDate*)date:(NSDate*)date forDay:(NSInteger)day;
+ (NSDate*)date:(NSDate*)date forHour:(NSInteger)hour;
+ (NSDate*)date:(NSDate*)date forMinute:(NSInteger)minute;
+ (NSDate*)date:(NSDate*)date forSecond:(NSInteger)second;

/**
 *  获取今天0点的时间
 *
 *  @return
 */
+ (NSDate *)dateForDawn;
+ (NSTimeInterval)timeIntervalSinceToday;

- (NSDate *)dateForDawn;
- (NSDate *)timeForDawn;
- (NSDate *)dateWithTime:(NSDate*)time;

/**
 *  判断是否是同一天
 *
 *  @param date
 *
 *  @return YES 是同一天
 */
- (BOOL)isSameDay:(NSDate*)date;
/**
 *  时间格式化
 *
 *  @param format eg.@"yyyy-MM-dd HH:mm:ss.sss"
 *
 *  @return
 */
- (NSString *)stringWithDateFormat:(NSString *)format;
/**
 *  时间格式化
 *
 *  @param format   eg.@"yyyy-MM-dd HH:mm:ss.sss"
 *  @param timezone 时区
 *
 *  @return
 */
- (NSString *)stringWithDateFormat:(NSString *)format forTimezone:(NSTimeZone*)timezone;

/**
 *  时间表达
 *
 *  @return 刚刚、n分钟前、n小时前、昨天、n个月前、n年前
 */
- (NSString *)timeAgo;

+ (long long)timeStamp;
@end
