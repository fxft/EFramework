//
//  HMUICalendarView.m
//  EFMWKLib
//
//  Created by mac on 15/3/5.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUICalendarView.h"


#define MODELDAYKEY @"singleModel"
//#define MODELWEEKKEY @"weekModel"
#define MODELMULDAYKEY @"muldayModel"


@interface HMUICalendarView ()
@property (HM_STRONG, nonatomic,readwrite) NSDate   * currentDate;
//〉〈
@property (HM_STRONG,nonatomic) UILabel *leftArrow;
@property (HM_STRONG,nonatomic) UILabel *rightArrow;
@end

@implementation HMUICalendarView
{
    NSMutableArray *items;
    NSMutableDictionary *modelDic;//保存当前 类型下 btn
    NSMutableDictionary *dateDic;//保存当前类型下 时间
    BOOL _isBuilded;
}
@synthesize date,delegate,weekTitles,maxDate,minDate;
@synthesize model;
@synthesize currentDate=_currentDate;
@synthesize mulselectDates=_mulselectDates;
@synthesize leftArrow=_leftArrow;
@synthesize rightArrow=_rightArrow;
@synthesize selectDate = _selectDate;

- (void)dealloc
{
    [items release];
    [modelDic release];
    self.currentDate = nil;
    self.date = nil;
    self.delegate = nil;
    self.maxDate = nil;
    self.minDate = nil;
    self.selectDate = nil;
    self.mulselectDates = nil;
    self.weekTitles = nil;
    HM_SUPER_DEALLOC();
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //外部没有设置月份样式时，显示默认样式
        
        [self initSelfDefault];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initSelfDefault];
    }
    return self;
}

- (void)initSelfDefault{
    if (!_isBuilded) {
        _isBuilded = YES;

        if (self.weekTitles==nil) {
            self.weekTitles = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
        }
        self.backgroundColor = [UIColor clearColor];
        self.date = [NSDate date];
        items = [[NSMutableArray array]retain];
        modelDic= [[NSMutableDictionary dictionary]retain];
        dateDic = [[NSMutableDictionary dictionary]retain];
        
        self.mulselectDates = [NSMutableArray array];
        
        self.nonTitleNormalColor = RGB(201, 201, 201);
        self.todayTitleNormalColor = [UIColor redColor];
        
        self.dayTitleNormalColor = RGB(97, 97, 97);
        self.dayTitleSelectColor = [UIColor whiteColor];
        self.dayTitleSelectFont = [UIFont systemFontOfSize:16.f];
        self.dayBackSelectImage = [[UIImage imageForColor:RGB(207, 52, 60) scale:[UIScreen mainScreen].scale size:CGSizeMake(10, 10) radius:5] stretched];
//        self.dayBackNormalImage = [[UIImage imageForColor:RGB(50, 52, 60) scale:[UIScreen mainScreen].scale size:CGSizeMake(10, 10) radius:5] stretched];
        self.dayTitleNormalFont = self.dayTitleSelectFont;
        
        self.weekenTitleColor = RGB(213, 70, 70);
        self.weekTitleNormalFont = self.dayTitleNormalFont;
        self.weekTitleColor = self.dayTitleNormalColor;
        
    }
}


- (void)clearSubView{
    [items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (items.count != 0) {
        [items removeAllObjects];
    }
}

- (void)reloadData{
    
    [self buildCalendar];
    
    [self updateStatus];
}

- (void)buildCalendar{
    
    NSAssert(self.date!=nil, @"请先设置 date");
    
    NSDate *d = self.date;
    //获取当前月第一天
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit
                               fromDate:d];
    comps.day = 1;
    NSDate *firstDay = [cal dateFromComponents:comps];
    //获取1号是星期几
    NSInteger firstWeekDay = [firstDay weekday]-1;
    if (firstWeekDay==0&&self.startStyle==calendarStartStyle_Sunday) {//如果1号是星期天,切需要从星期天开始排
        firstDay = [firstDay dateByAddingTimeInterval:-(7*3600*24)];
    }else if(self.startStyle==calendarStartStyle_Monday){
        firstWeekDay -= 1;
    }
    //获取第一格日历中的时间
    NSDate *firstMetre = [firstDay dateByAddingTimeInterval:-(firstWeekDay*3600*24)];
    
    NSInteger section = 7;//self.weekTitles.count;//列数
    NSInteger row = 7;//行数
    NSInteger count = row*section;
    
    //计算大小间距
    CGFloat spaceHor = self.dayMinHorSpace;
    CGFloat spaceVor = self.dayMinVorSpace;
    //计算出每个单元格的大小，确认左右间隔，上下间隔（星期置顶，需扣除星期与日期的间隔）
    CGSize itemSize = CGSizeZero;
    if (!CGSizeEqualToSize(self.itemSize, CGSizeZero)) {//如果有设置单元格大小
        itemSize = self.itemSize;
        
        if (!CGSizeEqualToSize(self.size, CGSizeZero)) {
            spaceHor = MAX((self.width-itemSize.width*section)/(2*section), spaceHor);
            spaceVor = MAX((self.height-itemSize.height*row-self.weekSpace)/(2*row), spaceVor);
        }
       
    }else{
        if (CGSizeEqualToSize(self.size, CGSizeZero))return;//没有设置视图尺寸将计算不出单元格大小
            itemSize = CGSizeMake((self.width-spaceHor*(section*2))/section, (self.height-spaceVor*(row*2)-self.weekSpace)/row);
        
    }
    //总体居中
    CGPoint offset = {0,0};
    if (!CGSizeEqualToSize(self.size, CGSizeZero)){
        offset.x = (self.size.width-itemSize.width*section-spaceHor*(section*2))/2;
        offset.y = (self.size.height-itemSize.height*row-spaceVor*(row*2)-self.weekSpace)/2;
    }
    
    if (items.count>count) {
        [items removeObjectsInRange:NSMakeRange(count, items.count-count)];
        
    }
    
    NSDate *dawn = [NSDate dateForDawn];
    
    for (int i = 0; i<count; i++) {
        
        UIButten * dayBtn = [items safeObjectAtIndex:i];
        if (dayBtn==nil) {
            dayBtn = [UIButten spawn];
            [items insertObject:dayBtn atIndex:i];
            [self addSubview:dayBtn];
            dayBtn.eventReceiver = self;
        }
        dayBtn.tag = i;
        dayBtn.enabled = YES;
        dayBtn.selected = NO;
        //
        int remainder = i%section;
        int mul = i/row;
        NSString *title = nil;
        NSDate *cDate = nil;
       
        
        if (mul==0) {//第一行
            NSInteger index = self.startStyle==calendarStartStyle_Sunday?i:((i+1)==7?0:(i+1));
            title = [weekTitles safeObjectAtIndex:index];
            
            UIColor *color = self.weekTitleColor;

            [dayBtn setTitleColor:color forState:UIControlStateNormal];
            [dayBtn setTitleFont:self.weekTitleNormalFont forState:UIControlStateNormal];
            
        }else{
            
            cDate = [firstMetre dateByAddingTimeInterval:(i-section)*3600*24];
            dayBtn.userInfo = cDate;
            title = [NSString stringWithFormat:@"%d",(int)cDate.day];//[cDate stringWithDateFormat:@"dd"];
            
            UIColor *color = nil;
            if (cDate.month == d.month) {//本月
                color = self.dayTitleNormalColor;

                if (self.weekenTitleColor) {//周末是否颜色区分
                    if ((self.startStyle==calendarStartStyle_Sunday&&(remainder==0 || remainder==(section-1)))
                        ||(self.startStyle==calendarStartStyle_Monday&&(remainder==(section-2) || remainder==(section-1)))) {
                        
                        color = self.weekenTitleColor;
                        
                    }
                }
            }
            else
            {
                color = self.nonTitleNormalColor;
            }
            dayBtn.tagString = @"date";
            
            if ([cDate isSameDay:dawn]) {
                color = self.todayTitleNormalColor;
            }
            
            [dayBtn setTitleColor:color forState:UIControlStateNormal];
            [dayBtn setTitleColor:self.dayTitleSelectColor forState:UIControlStateSelected];
            [dayBtn setTitleColor:self.dayTitleHighlightColor forState:UIControlStateHighlighted];
            
            [dayBtn setTitleFont:self.dayTitleNormalFont forState:UIControlStateNormal];
            [dayBtn setTitleFont:self.dayTitleSelectFont forState:UIControlStateSelected];
            [dayBtn setTitleFont:self.dayTitleHighlightFont forState:UIControlStateHighlighted];
            
            [dayBtn setBackgroundImage:self.dayBackNormalImage forState:UIControlStateNormal];
            [dayBtn setBackgroundImage:self.dayBackHighlightImage forState:UIControlStateHighlighted];
            [dayBtn setBackgroundImage:self.dayBackSelectImage forState:UIControlStateSelected];
            
            //maxdate设置最大日期,超过的不能选中
            if ([cDate compare:self.maxDate] == NSOrderedDescending||[cDate compare:self.minDate] == NSOrderedAscending) {
                dayBtn.enabled = NO;
            }
        
        }
        
        [dayBtn setTitle:title forState:UIControlStateNormal];
        
        
        dayBtn.origin = CGPointMake(remainder*itemSize.width+(remainder*2+1)*spaceHor+offset.x, mul*itemSize.height+(mul*2+1)*spaceVor+(mul > 0? self.weekSpace:0)+offset.y);
        dayBtn.size = itemSize;
        
    }
}

//获取日期所在的按钮
- (UIButten*)btnByDate:(NSDate *)mydate{
    if (mydate==nil) {
        return nil;
    }
    NSDate *dram = mydate;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInfo == %@",dram];
    NSArray *arry = [items filteredArrayUsingPredicate:predicate];
    
    return [arry firstObject];
}

//获取日期表所有可见的按钮
- (NSArray*)btnByDates:(NSArray *)mydate{
    if (mydate==nil) {
        return nil;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInfo IN %@",mydate];
    NSArray *arry = [items filteredArrayUsingPredicate:predicate];
    
    return arry;
}

//获取按钮所指定的日期
- (NSDate*)dateByBtn:(UIButten*)btn{
    return btn.userInfo;
}

//根据选中的按钮获取日期表
- (NSArray*)datesByBtns:(NSArray*)btns{
    NSMutableArray *arry = [NSMutableArray array];
    for (UIButten *btn in btns) {
        
        if ([btn.userInfo isKindOfClass:[NSDate class]]) {
            [arry addObject:btn.userInfo];
        }
        
    }
    return arry;
}

//获取一周日期表
- (NSArray *)calerWeek:(NSDate *)touchDate{
    
    //判断是否已选

    NSMutableArray * dateArray = [NSMutableArray array];

    //得到将要选的组(从星期天开始:weekday 1-7)
    NSInteger sunday = touchDate.weekday-(self.startStyle==calendarStartStyle_Monday?2:1);
    
    if (sunday==-1) {
        sunday = 6;
    }
    
    for (NSInteger i=0; i<7; i++) {
        [dateArray addObject:[NSDate date:touchDate forDay:touchDate.day+i-sunday]];
    }
    
    return dateArray;
}

- (void)touchDate:(NSDate*)tdate{
    self.currentDate = tdate;
    if (self.model==calendarBuildModel_MULDAY){
        UIButten *btn = [self btnByDate:tdate];
        btn.selected = !btn.selected;
        
        if (btn.selected) {
            [self.mulselectDates addObject:btn.userInfo];
        }else{
            for (NSDate *atdate in self.mulselectDates) {
                if ([atdate isEqualToDate:btn.userInfo]) {
                    [self.mulselectDates removeObject:atdate];
                    break;
                }
            }
        }
    }
    [self updateStatus];
}

- (NSDate *)selectDate{
    return self.currentDate;
}

- (void)setSelectDate:(NSDate *)selectDate{
    if (selectDate) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [cal
                                   components:NSYearCalendarUnit | NSMonthCalendarUnit|NSDayCalendarUnit
                                   fromDate:selectDate];
        NSDate *firstDay = [cal dateFromComponents:comps];
        
        self.currentDate = firstDay;
    }
    
}

- (void)updateStatus{
    
    NSDate *touchDate = self.currentDate;
    if (touchDate==nil) {
        return;
    }
    NSArray *preDateArray = [modelDic valueForKey:MODELMULDAYKEY];//获取已选中按钮
    for (UIButten *btn in preDateArray) {
        btn.selected = NO;
    }
    UIButten *preBtn = [modelDic valueForKey:MODELDAYKEY];
    preBtn.selected = NO;
    
    if (self.model==calendarBuildModel_DAY) {//单选
        
        UIButten *btn = [self btnByDate:touchDate];
        btn.selected = YES;
        
        [modelDic setValue:btn forKey:MODELDAYKEY];
        
        if ([self.delegate respondsToSelector:@selector(buildCalendar:data:model:)]) {
            [self.delegate buildCalendar:self data:touchDate model:self.model];
        }
        
    }else if (self.model==calendarBuildModel_WEEK){
        
        self.mulselectDates = [NSMutableArray arrayWithArray:[self calerWeek:touchDate]];//获取需要选中的日期表
        
        NSArray *dateArray = [self btnByDates:self.mulselectDates];//获取可见按钮表
        for (UIButten *btn in dateArray) {
            btn.selected = YES;
        }
        
        [modelDic setValue:dateArray forKey:MODELMULDAYKEY];
        
        
        if ([self.delegate respondsToSelector:@selector(buildCalendar:data:model:)]) {
            [self.delegate buildCalendar:self data:dateArray model:self.model];
        }
        
    }else if (self.model==calendarBuildModel_MULDAY){
      
        
        for (UIButten *btn in self.mulselectDates) {
            btn.selected = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(buildCalendar:data:model:)]) {
            [self.delegate buildCalendar:self data:self.mulselectDates model:self.model];
        }
        
    }

}

ON_Button(signal)
{
    UIButten *btn = signal.source;
    
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        
        
        if ([btn is:@"date"]) {
            
            NSDate *btnDate = btn.userInfo;
            
            [self touchDate:btnDate];
            
        }
        
    }
}



- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self reloadData];

}


@end
