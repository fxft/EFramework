//
//  HMMapCalloutView.m
//  GPSService
//
//  Created by Eric on 14-4-10.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMMapCalloutView.h"
#import "HMFoundation.h"

@interface HMMapCalloutView (){
    UILabel *  _title;
    UILabel *  _subtitle;
    UIView *   _leftView;
    UIView *   _rightView;
}
@property (HM_STRONG, nonatomic, readwrite) UILabel *  title;
@property (HM_STRONG, nonatomic, readwrite) UILabel *  subtitle;
@property (nonatomic)CALLOUTVIEWTYPE viewType;
@end

@implementation HMMapCalloutView

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize leftView = _leftView;
@synthesize rightView = _rightView;
@synthesize viewType;
@synthesize maxSubtitleWidth=_maxSubtitleWidth;

+ (instancetype)spawnWithType:(CALLOUTVIEWTYPE)type{
    HMMapCalloutView *callout = [HMMapCalloutView spawn];
    callout.viewType = type;
    return callout;
}

- (void)dealloc
{
    [_title removeFromSuperview];
    [_title release];
    [_subtitle removeFromSuperview];
    [_subtitle release];
    [_leftView removeFromSuperview];
    [_leftView release];
    [_rightView removeFromSuperview];
    [_rightView release];
    HM_SUPER_DEALLOC();
}

- (UILabel *)title{
    if (_title==nil) {
        _title = [[UILabel spawn]retain];
        _title.numberOfLines = 0;
        _title.textAlignment = UITextAlignmentLeft;
        [self addSubview:_title];
    }
    return _title;
}

- (UILabel *)subtitle{
    if (_subtitle==nil) {
        _subtitle = [[UILabel spawn]retain];
        _subtitle.numberOfLines = 0;
        _subtitle.textAlignment = UITextAlignmentLeft;
        [self addSubview:_subtitle];
    }
    return _subtitle;
}

- (void)setLeftView:(UIView *)leftView{
    if (_leftView) {
        [_leftView removeFromSuperview];
    [_leftView release];
    }
    _leftView = [leftView retain];
    if (_leftView) {
        [self addSubview:_leftView];
    }
    [self resetView];
}

- (void)setRightView:(UIView *)rightView{
    if (_rightView) {
        [_rightView removeFromSuperview];
    [_rightView release];
    }
    _rightView = [rightView retain];
    if (_rightView) {
        [self addSubview:_rightView];
    }
    [self resetView];
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    if (self.superview) {
         [self resetView];
    }
}


- (void)initSelfDefault{
    self.backgroundColor = [UIColor clearColor];
    _maxSubtitleWidth = 200.f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        
    }
    return self;
}


- (void)resetView{
    CGSize sizeTitle = CGSizeZero;
    CGSize sizeSubtitle = CGSizeZero;
    CGSize sizeLeft = _leftView.size;
    CGSize sizeRight = _rightView.size;
    CGFloat maxSubtitleWidth = _maxSubtitleWidth;

    sizeTitle = [_title.text sizeWithFont:_title.font byWidth:maxSubtitleWidth-_rightView.width-_leftView.width-4];
    CGFloat maxHeadViewHeight = MAX(sizeLeft.height, sizeRight.height);
    
    if (self.viewType==CALLOUTVIEWTYPE_SUBTITLEFULL) {
        maxHeadViewHeight = MAX(MAX(sizeLeft.height, sizeRight.height),sizeTitle.height);
        sizeTitle.height = maxHeadViewHeight;
    }
    _title.frame = CGRectMake(sizeLeft.width+2, 0, sizeTitle.width, sizeTitle.height);
    
    if (_leftView) {
        [_leftView setFrame:CGRectMakeBound(sizeLeft.width, sizeLeft.height)];
    }
    
    if (_rightView) {
        [_rightView setFrame:CGRectMake(_title.x+2+_title.width, 0, sizeRight.width, sizeRight.height)];
    }
    
    if (self.viewType==CALLOUTVIEWTYPE_SUBTITLEFULL) {
        sizeLeft.width = 0;
        maxSubtitleWidth = MIN(maxSubtitleWidth,_title.width+sizeLeft.width+sizeRight.width+4);
    }else{
        maxHeadViewHeight = sizeTitle.height;
        
    }
    sizeSubtitle = [_subtitle.text sizeWithFont:_subtitle.font byWidth:maxSubtitleWidth];
    _subtitle.frame = CGRectMake(sizeLeft.width+2, maxHeadViewHeight, sizeSubtitle.width, sizeSubtitle.height);
    
    if (self.viewType==CALLOUTVIEWTYPE_SUBTITLEFULL) {
        
        maxSubtitleWidth = MAX(maxSubtitleWidth,_title.width+sizeLeft.width+sizeRight.width+4);
        maxHeadViewHeight += _subtitle.height;
    }else{

        maxHeadViewHeight = MAX(maxHeadViewHeight+_subtitle.height, MAX(sizeLeft.height, sizeRight.height));
        
    }
    self.size = CGSizeMake(maxSubtitleWidth, maxHeadViewHeight);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
