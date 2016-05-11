//
//  HMUIDatePicker.h
//  GPSService
//
//  Created by Eric on 14-4-15.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIPopoverView.h"
#import "HMEvent.h"
#import "HMUICalendarView.h"

#define ON_DatePicker( signal) ON_SIGNAL2(HMUIDatePicker, signal)

typedef NS_ENUM(NSUInteger, UIDatePickerStyle) {
    UIDatePickerStyle_Date=1,
    UIDatePickerStyle_Calendar,
};

@protocol ON_DatePicker_handle <NSObject>

ON_DatePicker( signal);

@end
/**
 *  日期选择器 UIDatePicker 设置基本一致
 */
@interface HMUIDatePicker : HMUIPopoverView

AS_SIGNAL( CHANGED )		// 日期改变  retuen dic for key @"date"

@property (nonatomic,HM_STRONG,readonly) UIDatePicker* datePicker;//时间选择
@property (nonatomic,HM_STRONG,readonly) HMUICalendarView* calendarPicker;//日期选择
@property (nonatomic,HM_STRONG,readonly) HMUIView* lastBtn;//可以设置样式

@property (nonatomic, HM_STRONG) NSObject *		userData;//用户数据
@property (nonatomic, HM_STRONG) NSDate *		date;

@property (nonatomic, assign) UIDatePickerStyle	datePickerStyle;

//支持 UIDatePickerStyle_Date 模式下的设置
@property (nonatomic, assign) UIDatePickerMode	datePickerMode;
@property (nonatomic, HM_STRONG) NSLocale *		locale;
@property (nonatomic, HM_STRONG) NSCalendar *		calendar;
@property (nonatomic, HM_STRONG) NSTimeZone *		timeZone;
@property (nonatomic, assign) NSTimeInterval	countDownDuration;
@property (nonatomic, assign) NSInteger			minuteInterval;

//支持 UIDatePickerStyle_Calendar&UIDatePickerStyle_Date 模式下的设置
@property (nonatomic, HM_STRONG) NSDate *			minimumDate;
@property (nonatomic, HM_STRONG) NSDate *			maximumDate;

//支持 UIDatePickerStyle_Date 模式下的设置
- (void)setDate:(NSDate *)date animated:(BOOL)animated;

@end
