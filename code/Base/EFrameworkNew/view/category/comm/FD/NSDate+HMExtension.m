//
//  NSDate+HMExtension.m
//  CarAssistant
//
//  Created by Eric on 14-4-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSDate+HMExtension.h"
#import "HMMacros.h"
#import "HMFoundation.h"

@implementation NSDate (HMExtension)

@dynamic year;
@dynamic month;
@dynamic day;
@dynamic hour;
@dynamic minute;
@dynamic second;
@dynamic weekday;

- (NSInteger)year
{
	return [[NSCalendar currentCalendar] components:NSYearCalendarUnit
										   fromDate:self].year;
}

- (NSInteger)month
{
	return [[NSCalendar currentCalendar] components:NSMonthCalendarUnit
										   fromDate:self].month;
}

- (NSInteger)day
{
	return [[NSCalendar currentCalendar] components:NSDayCalendarUnit
										   fromDate:self].day;
}

- (NSInteger)hour
{
	return [[NSCalendar currentCalendar] components:NSHourCalendarUnit
										   fromDate:self].hour;
}

- (NSInteger)minute
{
	return [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit
										   fromDate:self].minute;
}

- (NSInteger)second
{
	return [[NSCalendar currentCalendar] components:NSSecondCalendarUnit
										   fromDate:self].second;
}

- (NSInteger)weekday
{
	return [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit
										   fromDate:self].weekday;
}



+ (NSDate*)date:(NSDate*)date forYear:(NSInteger)year{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit
                               fromDate:date];
    comps.year = year;
    return [cal dateFromComponents:comps];
}


+ (NSDate*)date:(NSDate*)date forMonth:(NSInteger)month{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit
                               fromDate:date];
    comps.month = month;
    return [cal dateFromComponents:comps];
}


+ (NSDate*)date:(NSDate*)date forDay:(NSInteger)day{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit
                               fromDate:date];
    comps.day = day;
    return [cal dateFromComponents:comps];
}


+ (NSDate*)date:(NSDate*)date forHour:(NSInteger)hour{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit
                               fromDate:date];
    comps.hour = hour;
    return [cal dateFromComponents:comps];
}


+ (NSDate*)date:(NSDate*)date forMinute:(NSInteger)minute{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit
                               fromDate:date];
    comps.minute = minute;
    return [cal dateFromComponents:comps];
}


+ (NSDate*)date:(NSDate*)date forSecond:(NSInteger)second{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit
                               fromDate:date];
    comps.second = second;
    return [cal dateFromComponents:comps];
}

+ (NSDate *)dateForDawn{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                  fromDate:[NSDate date]];
    return [calendar dateFromComponents:dateComponent];
}
- (NSDate *)dateForDawn{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)
                                                  fromDate:self];
    return [calendar dateFromComponents:dateComponent];
}
- (NSDate *)timeForDawn{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [calendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit)
                                                  fromDate:self];
    return [calendar dateFromComponents:dateComponent];
}
- (NSDate *)dateWithTime:(NSDate*)time{
    
    NSDate *date = [self dateByAddingTimeInterval:[time timeInterval]-[self timeInterval]];
    return date;
}
- (NSTimeInterval)timeInterval
{
    //	NSTimeZone * local = [NSTimeZone localTimeZone];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit
                                                  fromDate:self];
    //    NSDate *date = [dateComponent date];
    NSTimeInterval interval=0;
    interval = [dateComponent hour]*60*60+[dateComponent minute]*60;
    //	NSString * format = @"yyyy-MM-dd HH:mm:ss";
    //	NSString * text = [date stringWithDateFormat:@"HH:mm"];
    //    NSDate *now = [text dateFormat:@"HH:mm"];
    //    NSDate *morning =[@"00:00"dateFormat:@"HH:mm"];
    //    return [now timeIntervalSinceDate:morning];
    return interval;
}
+ (NSTimeInterval)timeIntervalSinceToday
{
    //	NSTimeZone * local = [NSTimeZone localTimeZone];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit
                                                  fromDate:[NSDate date]];
    //    NSDate *date = [dateComponent date];
    NSTimeInterval interval=0;
    interval = [dateComponent hour]*60*60+[dateComponent minute]*60;
    //	NSString * format = @"yyyy-MM-dd HH:mm:ss";
    //	NSString * text = [date stringWithDateFormat:@"HH:mm"];
    //    NSDate *now = [text dateFormat:@"HH:mm"];
    //    NSDate *morning =[@"00:00"dateFormat:@"HH:mm"];
    //    return [now timeIntervalSinceDate:morning];
    return interval;
}

- (BOOL)isSameDay:(NSDate*)date
{
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
    
    
    
    return [comp1 day]   == [comp2 day] &&
    
    [comp1 month] == [comp2 month] &&
    
    [comp1 year]  == [comp2 year];
    
}
- (NSString *)stringWithDateFormat:(NSString *)format
{
    return [self stringWithDateFormat:format forTimezone:nil];
}

- (NSString *)stringWithDateFormat:(NSString *)format forTimezone:(NSTimeZone*)timezone
{
#if 0
    
    NSTimeInterval time = [self timeIntervalSince1970];
    NSUInteger timeUint = (NSUInteger)time;
    return [[NSNumber numberWithUnsignedInteger:timeUint] stringWithDateFormat:format];
    
#else
    
    // thansk @lancy, changed: "NSDate depend on NSNumber" to "NSNumber depend on NSDate"
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSString *indent = [[NSLocale preferredLanguages]safeObjectAtIndex:0];
    NSLocale *locale = [[[NSLocale alloc]initWithLocaleIdentifier:indent]autorelease];
    [dateFormatter setLocale:locale];
    if (timezone) {
        [dateFormatter setTimeZone:timezone];
    }
    
    if (format==nil) {
        format = @"yyyy-MM-dd HH:mm:ss";
    }
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
    
#endif
}

- (NSString *)timeAgo
{
	NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:self];
	
	if (delta < 1 * MINUTE)
	{
		return @"刚刚";
	}
	else if (delta < 2 * MINUTE)
	{
		return @"1分钟前";
	}
	else if (delta < 45 * MINUTE)
	{
		int minutes = floor((double)delta/MINUTE);
		return [NSString stringWithFormat:@"%d分钟前", minutes];
	}
	else if (delta < 90 * MINUTE)
	{
		return @"1小时前";
	}
	else if (delta < 24 * HOUR)
	{
		int hours = floor((double)delta/HOUR);
		return [NSString stringWithFormat:@"%d小时前", hours];
	}
	else if (delta < 48 * HOUR)
	{
		return @"昨天";
	}
	else if (delta < 30 * DAY)
	{
		int days = floor((double)delta/DAY);
		return [NSString stringWithFormat:@"%d天前", days];
	}
	else if (delta < 12 * MONTH)
	{
		int months = floor((double)delta/MONTH);
		return months <= 1 ? @"1个月前" : [NSString stringWithFormat:@"%d个月前", months];
	}
    
	int years = floor((double)delta/MONTH/12.0);
	return years <= 1 ? @"1年前" : [NSString stringWithFormat:@"%d年前", years];
}

+ (long long)timeStamp
{
	return (long long)[[NSDate date] timeIntervalSince1970];
}
@end
