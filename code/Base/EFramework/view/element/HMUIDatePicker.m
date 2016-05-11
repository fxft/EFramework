//
//  HMUIDatePicker.m
//  GPSService
//
//  Created by Eric on 14-4-15.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIDatePicker.h"
#import "HMFoundation.h"


@interface HMUIDatePicker()<HMUICalendarViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,HM_STRONG,readwrite) UIDatePicker* datePicker;
@property (nonatomic,HM_STRONG,readwrite) HMUICalendarView* calendarPicker;
@property (nonatomic,HM_STRONG,readwrite) HMUIView* lastBtn;
@property (nonatomic,HM_STRONG) UIPickerView *yearpick;
@property (nonatomic,HM_STRONG) UIPickerView *daypick;

- (void)didDateChanged;
@end


@implementation HMUIDatePicker{
    BOOL					_inited;
    UIDatePicker *			_datePicker;
    HMUICalendarView *      _calendarPicker;
    NSObject *				_userData;
}

DEF_SIGNAL2( CHANGED ,HMUIDatePicker)

@synthesize userData = _userData;

@synthesize date=_date;
@dynamic datePickerMode;
@dynamic locale;
@dynamic calendar;
@dynamic timeZone;
@dynamic minimumDate;
@dynamic maximumDate;
@dynamic countDownDuration;
@dynamic minuteInterval;

@synthesize datePickerStyle=_datePickerStyle;
@synthesize datePicker = _datePicker;
@synthesize calendarPicker = _calendarPicker;
@synthesize lastBtn;

- (void)load{
    if ( NO == _inited )
	{
        self.date = [NSDate date];
        self.datePickerStyle = UIDatePickerStyle_Date;
        _inited = YES;
    }
    
}

- (void)unload{
    [_datePicker removeFromSuperview];
	[_datePicker release];
    [_calendarPicker removeFromSuperview];
    [_calendarPicker release];
    [_daypick removeFromSuperview];
    [_daypick release];
    [_yearpick removeFromSuperview];
    [_yearpick release];
	[_userData release];
    self.lastBtn = nil;
}

- (UIDatePicker *)datePicker{
    if (_datePicker==nil) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.date = [NSDate date];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.calendar = [NSCalendar currentCalendar];
        _datePicker.maximumDate = [NSDate date];
        _datePicker.backgroundColor = [UIColor whiteColor];
        [_datePicker addTarget:self action:@selector(didDateChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (UIPickerView *)yearpick{
    if (_yearpick==nil) {
        _yearpick = [[UIPickerView alloc]init];
        _yearpick.delegate = self;
        _yearpick.dataSource = self;
        _yearpick.backgroundColor = [UIColor whiteColor];
        _yearpick.alpha = 0.f;
    }
    return _yearpick;
}


- (UIPickerView *)daypick{
    if (_daypick==nil) {
        _daypick = [[UIPickerView alloc]init];
        _daypick.delegate = self;
        _daypick.dataSource = self;
        _daypick.backgroundColor = [UIColor whiteColor];
        _daypick.alpha = 0.f;
    }
    return _daypick;
}

- (HMUICalendarView *)calendarPicker{
    if (_calendarPicker==nil) {
        _calendarPicker = [[HMUICalendarView alloc]init];
        _calendarPicker.delegate = self;
        _calendarPicker.backgroundColor = [UIColor whiteColor];
    }
    return _calendarPicker;
}

- (void)setDatePickerStyle:(UIDatePickerStyle)datePickerStyle{
    _datePickerStyle = datePickerStyle;
    
    if (_datePickerStyle==UIDatePickerStyle_Date) {
        if (self.contentView.tag!=100200) {
            
            self.contentView = [self anDatePickerView];
        }
        
    }else if (_datePickerStyle == UIDatePickerStyle_Calendar){
        if (self.contentView.tag!=100100) {
            self.contentView = [self anCalendarView];
            [self refreshUI];
        }
    }
}

- (UIView*)anDatePickerView{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *bottom = [self bottomView:screenSize];
    UIView *retview = [[[UIView alloc]init]autorelease];
    [retview addSubview:bottom];
    retview.clipsToBounds = YES;
    [retview addSubview:self.datePicker];
    bottom.y = self.datePicker.y + self.datePicker.height+5;
    [retview addSubview:bottom];
    retview.frame = CGRectMake(0, 0, self.datePicker.width, bottom.y+bottom.height);
    retview.tag = 100200;
    return retview;
}

- (void)resetFrame:(CGSize)size{
    UIView *bottom = [self.contentView viewWithTag:12012];
    UIView *sub = [bottom viewWithTagString:@"submittt"];
    UIView *canl = [bottom viewWithTagString:@"canceltt"];
    bottom.width = size.width;
    [sub setFrame:CGRectMake(bottom.width/2+5, 0, bottom.width/2-5, bottom.height)];
    [canl setFrame:CGRectMake(0, 0, bottom.width/2-5, bottom.height)];
    
    if (self.datePickerStyle == UIDatePickerStyle_Date) {
        
    }else{
        UIView *head = [self.contentView viewWithTag:11011];
        head.width = size.width;
        self.calendarPicker.width = size.width;
        UIView *y = [head viewWithTagString:@"yeartt"];
        [y setFrame:CGRectMake(0, 0, head.width/4, head.height)];
        UIView *m = [head viewWithTagString:@"mounthtt"];
        [m setFrame:CGRectMake(head.width/4, 0, head.width/4, head.height)];
        UIView *d = [head viewWithTagString:@"daytt"];
        [d setFrame:CGRectMake(head.width/2, 0, head.width/4, head.height)];
        UIView *t = [head viewWithTagString:@"timett"];
        [t setFrame:CGRectMake(head.width/4*3, 0, head.width/4, head.height)];
    }
}

- (UIView *)bottomView:(CGSize)screenSize{
    /**
     初始化 确认 取消
     */
    UIView *bottom = [[[UIView alloc]initWithFrame:CGRectMakeBound(screenSize.width-20, 35)] autorelease];
    bottom.tag = 12012;
    
    UIButten *btn = [UIButten spawn];
    btn.eventReceiver = self;
    btn.tagString = @"submittt";
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitleColor:[UIColor md_blue_400] forState:UIControlStateNormal];
    [btn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(bottom.width/2, 0, bottom.width/2-5, bottom.height)];
    [bottom addSubview:btn];
    
    btn = [UIButten spawn];
    btn.eventReceiver = self;
    btn.tagString = @"canceltt";
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, bottom.width/2-5, bottom.height)];
    [bottom addSubview:btn];
    return bottom;
}

- (UIView*)anCalendarView{
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    /**
     初始化标题
     */
    UIView *head = [[[UIView alloc]initWithFrame:CGRectMakeBound(screenSize.width-20-5, 30)] autorelease];
    head.tag = 11011;
    head.backgroundColor = [UIColor whiteColor];
    
    self.lastBtn = [HMUIView spawn];
    self.lastBtn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.3f];
    [head addSubview:lastBtn];
    
    UIButten *txt = [UIButten spawn];
    txt.eventReceiver = self;
    txt.tagString = @"yeartt";
    txt.tag=1;
    [txt setTitleColor:[UIColor md_blue_400] forState:UIControlStateNormal];
    [txt setFrame:CGRectMake(0, 0, head.width/4, head.height)];
    [head addSubview:txt];
    
    txt = [UIButten spawn];
    txt.eventReceiver = self;
    txt.tagString = @"mounthtt";
    txt.tag=2;
    [txt setTitleColor:[UIColor md_blue_400] forState:UIControlStateNormal];
    [txt setFrame:CGRectMake(head.width/4, 0, head.width/4, head.height)];
    [head addSubview:txt];
    
    txt = [UIButten spawn];
    txt.eventReceiver = self;
    txt.tagString = @"daytt";
    txt.tag=3;
    [txt setTitleColor:[UIColor md_blue_400] forState:UIControlStateNormal];
    [txt setFrame:CGRectMake(head.width/2, 0, head.width/4, head.height)];
    
    self.lastBtn.frame = txt.frame;
    [head addSubview:txt];
    
    txt = [UIButten spawn];
    txt.eventReceiver = self;
    txt.tagString = @"timett";
    txt.tag=4;
    [txt setTitleColor:[UIColor md_blue_400] forState:UIControlStateNormal];
    [txt setFrame:CGRectMake(head.width/4*3, 0, head.width/4, head.height)];
    [head addSubview:txt];
    
    UIView *bottom = [self bottomView:screenSize];
    
    /**
     *  初始化 时间选择器
     */
    self.calendarPicker.date = self.date;
    [self.calendarPicker setFrame:CGRectMakeBound(screenSize.width-20, 240)];
    
    /**
     添加到容器
     */
    UIView *retview = [[[UIView alloc]init]autorelease];
    [retview addSubview:head];
   _calendarPicker.y = head.height+2;
    self.yearpick.frame = _calendarPicker.frame;
    [retview addSubview:self.yearpick];
    self.daypick.frame = _calendarPicker.frame;
    [retview addSubview:self.daypick];
    
    [retview addSubview:_calendarPicker];
    bottom.y = _calendarPicker.y + _calendarPicker.height+5;
    [retview addSubview:bottom];
   
    
    retview.clipsToBounds = YES;
    retview.frame = CGRectMake(0, 0, _calendarPicker.width, bottom.y+bottom.height+5);
    retview.tag = 100100;
    
    return retview;
}

- (void)refreshUI{
    if (_datePickerStyle==UIDatePickerStyle_Date) {
        
    }else if (_datePickerStyle == UIDatePickerStyle_Calendar){
        UIView *head = [self.contentView viewWithTag:11011];
        UIButten *txt = (UIButten*)[head viewWithTagString:@"yeartt"];
        [txt setTitle:[NSString stringWithFormat:@"%d",(int)[self.date year]] forState:UIControlStateNormal];
        txt = (UIButten*)[head viewWithTagString:@"mounthtt"];
        [txt setTitle:[NSString stringWithFormat:@"%d",(int)[self.date month]] forState:UIControlStateNormal];
        txt = (UIButten*)[head viewWithTagString:@"daytt"];
        [txt setTitle:[NSString stringWithFormat:@"%d",(int)[self.date day]] forState:UIControlStateNormal];
        txt = (UIButten*)[head viewWithTagString:@"timett"];
        [txt setTitle:[self.date stringWithDateFormat:@"HH:mm"] forState:UIControlStateNormal];
        
    }
}

- (void)resetContentViewRect:(CGRect)rect{
    
    [super resetContentViewRect:rect];
    
    [self resetFrame:rect.size];
    
    
    
}

- (void)toggleto:(NSInteger)index{

    _calendarPicker.alpha = 0.f;
    _datePicker.alpha = 0.f;
    _yearpick.alpha = 0.f;
    _daypick.alpha = 0.f;

    switch (index) {
        case 1:
            _yearpick.alpha = 1.f;
            break;
        case 2:
            _daypick.alpha = 1.f;
            break;
        case 3:
            _calendarPicker.alpha = 1.f;
            break;
        case 4:
            _datePicker.alpha = 1.f;
            break;
        default:
            break;
    }
}

ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"canceltt"]) {
            [self dissmissAnimated:YES];
            return;
        }else if ([btn is:@"submittt"]){
            [self sendSignal:HMUIDatePicker.CHANGED withObject:self.date];
            [self dissmissAnimated:YES];
            return;
        }
        
        
        if ([btn is:@"timett"]){
            if (self.datePicker.superview==nil) {
                [self.contentView addSubview:self.datePicker];
                self.datePicker.width = self.calendarPicker.width;
                self.datePicker.center = self.calendarPicker.center;
                
                self.datePicker.backgroundColor = [UIColor whiteColor];
                self.datePicker.maximumDate = nil;
                self.datePicker.datePickerMode = UIDatePickerModeTime;
            }
            
            self.datePicker.date = self.date;
           
        }else if ([btn is:@"yeartt"]){
            [self.yearpick selectRow:self.date.year-1970 inComponent:0 animated:YES];
        }else if ([btn is:@"mounthtt"]){
            [self.daypick selectRow:self.date.month inComponent:0 animated:YES];
        }else if ([btn is:@"daytt"]){
            self.calendarPicker.selectDate = self.date;
            [self.calendarPicker reloadData];
        }
        //动画切换选中状态
        [UIView animateWithDuration:.25f animations:^{
            
            self.lastBtn.width = fabs(btn.x-self.lastBtn.x)+self.lastBtn.width;
            self.lastBtn.x = MIN(btn.x, self.lastBtn.x);
            
            [self toggleto:btn.tag];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.15f animations:^{
                self.lastBtn.width = btn.width;
                self.lastBtn.x = btn.x;
            }];
        }];
        
    }else if ([signal is:[UIButten TOUCH_UP_CANCEL]]){
        
    }else if ([signal is:[UIButten TOUCH_CHECK_INSIDE]]){
        
    }else if ([signal is:[UIButten TOUCH_UP_OUTSIDE]]){
        
    }else if ([signal is:[UIButten TOUCH_DOWN_LONG]]){
        
    }else if ([signal is:[UIButten TOUCH_DOWN]]){
        
    }
}

- (void)setDate:(NSDate *)date
{
    [_date release];
    _date = [date retain];
	_datePicker.date = date;
    _calendarPicker.selectDate = date;
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated
{
	[_datePicker setDate:date animated:animated];
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
	_datePicker.datePickerMode = datePickerMode;
}

- (UIDatePickerMode)datePickerMode
{
	return _datePicker.datePickerMode;
}

- (void)setLocale:(NSLocale *)locale
{
	_datePicker.locale = locale;
}

- (NSLocale *)locale
{
	return _datePicker.locale;
}

- (void)setCalendar:(NSCalendar *)calendar
{
	_datePicker.calendar = calendar;
}

- (NSCalendar *)calendar
{
	return _datePicker.calendar;
}

- (void)setTimeZone:(NSTimeZone *)timeZone
{
	_datePicker.timeZone = timeZone;
}

- (NSTimeZone *)timeZone
{
	return _datePicker.timeZone;
}

- (void)setMinimumDate:(NSDate *)minimumDate
{
	_datePicker.minimumDate = minimumDate;
    _calendarPicker.minDate = minimumDate;
}

- (NSDate *)minimumDate
{
    if (_datePicker) {
        return _datePicker.minimumDate;
    }
    if (_calendarPicker) {
        return _calendarPicker.minDate;
    }
    return nil;
}

- (void)setMaximumDate:(NSDate *)maximumDate
{
	_datePicker.maximumDate = maximumDate;
    _calendarPicker.maxDate = maximumDate;
}

- (NSDate *)maximumDate
{
    if (_datePicker) {
        return _datePicker.maximumDate;
    }
    if (_calendarPicker) {
        return _calendarPicker.maxDate;
    }
    return nil;
}

- (void)setCountDownDuration:(NSTimeInterval)countDownDuration
{
	_datePicker.countDownDuration = countDownDuration;
}

- (NSTimeInterval)countDownDuration
{
	return _datePicker.countDownDuration;
}

- (void)setMinuteInterval:(NSInteger)minuteInterval
{
	_datePicker.minuteInterval = minuteInterval;
}

- (NSInteger)minuteInterval
{
	return _datePicker.minuteInterval;
}


- (void)didDateChanged
{

    self.date = _datePicker.date;
    [self refreshUI];

}

- (void)buildCalendar:(HMUICalendarView *)calendar data:(id)data model:(CalendarBuildModel)model{
    
    if ([data isKindOfClass:[NSDate class]]) {
        
        self.date = [NSDate date:self.date forDay:[(NSDate*)data day]];
        [self refreshUI];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (pickerView==self.yearpick) {
        
    }
    return pickerView.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 35;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView==self.yearpick) {
        return (self.maximumDate.year==0?[NSDate date].year+60:self.maximumDate.year)-(self.minimumDate.year==0?[NSDate date].year-60:self.minimumDate.year)+1;
    }
    return 12;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView==self.yearpick) {
        return [NSString stringWithFormat:@"%d年",(int)(1970+row)];
    }
    return [NSString stringWithFormat:@"%d月",(int)row+1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView==self.yearpick) {
        self.date = [NSDate date:self.date forYear:1970+row];
    }else{
        self.date = [NSDate date:self.date forMonth:row+1];
    }
    self.calendarPicker.date = self.date;
    [self refreshUI];
}

@end
