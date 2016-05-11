//
//  HMUICalendarView.h
//  EFMWKLib
//
//  Created by mac on 15/3/5.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUIView.h"


typedef NS_ENUM(NSUInteger, CalendarBuildModel) {
    calendarBuildModel_DAY,
    calendarBuildModel_WEEK,
    calendarBuildModel_MULDAY,
    
};

typedef NS_ENUM(NSUInteger, CalendarStartStyle) {
    calendarStartStyle_Sunday,
    calendarStartStyle_Monday,
    
};



@class HMUICalendarView;

@protocol HMUICalendarViewDelegate <NSObject>

- (void)buildCalendar:(HMUICalendarView*)calendar data:(id)data model:(CalendarBuildModel)model;

@end

/**
 *  日历视图
 */
@interface HMUICalendarView : HMUIView

@property (HM_STRONG, nonatomic) NSDate   * date;//日历的时间
@property (HM_STRONG, nonatomic,readonly) NSDate   * currentDate;
@property (assign, nonatomic)   id<HMUICalendarViewDelegate> delegate;

@property (nonatomic,assign)    CalendarBuildModel model;
@property (nonatomic,assign)    CalendarStartStyle startStyle;//设置从周一或周天开始

@property (HM_STRONG, nonatomic) NSArray * weekTitles;//设置星期标题（默认@[@"日",@"一",@"二",@"三",@"四",@"五",@"六"]）

@property (HM_STRONG, nonatomic) NSDate * maxDate;//设置最大日期，超过的不能选中
@property (HM_STRONG, nonatomic) NSDate * minDate;//设置最小日期，超过的不能选中
@property (HM_STRONG, nonatomic) NSDate * selectDate;//设置默认选中日期不包含时间(NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit)
@property (HM_STRONG, nonatomic) NSMutableArray * mulselectDates;//设置默认选中多天不包含时间(NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit)

@property (nonatomic,assign) CGSize itemSize;//每个按钮的大小
@property (nonatomic,assign) CGFloat dayMinHorSpace;//日期按钮的左右最小间隔
@property (nonatomic,assign) CGFloat dayMinVorSpace;//日期按钮的上下最小间隔
@property (nonatomic,assign) CGFloat weekSpace;//星期与天之间的间隔

@property (nonatomic,HM_STRONG) UIColor *weekTitleColor;//星期标题颜色
@property (nonatomic,HM_STRONG) UIColor *weekenTitleColor;//周末标题颜色，可不设置
@property (nonatomic,HM_STRONG) UIFont *weekTitleNormalFont;//星期标题常规字体

@property (nonatomic,HM_STRONG) UIColor *nonTitleNormalColor;//非本月日期常规颜色
@property (nonatomic,HM_STRONG) UIColor *todayTitleNormalColor;//今天常规颜色
@property (nonatomic,HM_STRONG) UIColor *dayTitleNormalColor;//日期常规颜色
@property (nonatomic,HM_STRONG) UIColor *dayTitleHighlightColor;//日期高亮颜色
@property (nonatomic,HM_STRONG) UIColor *dayTitleSelectColor;//日期选中颜色

@property (nonatomic,HM_STRONG) UIImage *dayBackNormalImage;//日期常规背景图片
@property (nonatomic,HM_STRONG) UIImage *dayBackHighlightImage;//日期常规背景图片
@property (nonatomic,HM_STRONG) UIImage *dayBackSelectImage;//日期常规背景图片

@property (nonatomic,HM_STRONG) UIFont *dayTitleNormalFont;//日期常规字体
@property (nonatomic,HM_STRONG) UIFont *dayTitleHighlightFont;//日期高亮字体
@property (nonatomic,HM_STRONG) UIFont *dayTitleSelectFont;//日期选中字体


- (void)reloadData;

@end
