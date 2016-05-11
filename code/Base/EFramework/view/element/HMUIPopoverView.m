//
//  HMUIPopoverView.m
//  GPSService
//
//  Created by Eric on 14-4-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIPopoverView.h"
#import "HMViewCategory.h"

@interface HMUIPopoverView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, HM_STRONG) HMUIShape *popoverShape;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic, HM_STRONG) UIImageView *      backImageview;
@end

@implementation HMUIPopoverView{
    UIView *        _referView;
    CGFloat         _arrowOffset;//顺时针增加
    CGFloat         _radius;
    CGSize          _arrowSize;
    HMUIView *      _popoverViewContainer;
    UIView *        _superView;
    UIPopoverArrowDirection _directionTmp;
    BOOL            _hasArrow;
    CGRect          _referFrame;
}

@synthesize contentView = _contentView;
@synthesize contentRect = _contentRect;
@synthesize contentCustom = _contentCustom;
@synthesize shadowOffset;
@synthesize popoverArrowDirection = _popoverArrowDirection;
@synthesize popoverShape;
@synthesize referView = _referView;
@synthesize containerMode = _containerMode;
@synthesize tableDatas=_tableDatas;
@synthesize touchAutoHide;
@synthesize shadowColor=_shadowColor;
@synthesize solidFillColor=_solidFillColor;
@synthesize borderColor=_borderColor;
@synthesize showGlass=_showGlass;
@synthesize backImageview;
@synthesize backgroundStyle=_backgroundStyle;
@synthesize referHighlightRadius;
@synthesize showReferHighlight;

+ (instancetype)spawnWithReferView:(UIView*)view inView:(UIView *)inView{
    return [[[self alloc]initWithFrame:(inView?inView.bounds:[UIScreen mainScreen].bounds) withReferView:view inView:inView]autorelease];
}

+ (instancetype)spawnForTableWithReferView:(UIView*)view inView:(UIView *)inView datas:(NSArray *)datas{
    HMUIPopoverView * popover = [[[self alloc]initWithFrame:(inView?inView.bounds:[UIScreen mainScreen].bounds) withReferView:view inView:inView]autorelease];
    UITableView *tableView = [[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain]autorelease];
    popover.tableDatas = datas;
    tableView.delegate = popover;
    tableView.dataSource = popover;
    if (IOS7_OR_LATER) {
        tableView.separatorInset = UIEdgeInsetsAll(0);
    }
    popover.contentView = tableView;
    
    return popover;
}

- (void)setTableDatas:(NSArray *)tableDatas{
    if (_tableDatas) {
        [_tableDatas release];
    }
    _tableDatas = [tableDatas retain];
    if ([self.contentView isKindOfClass:[UITableView class]]) {
        [(UITableView *)self.contentView reloadData];
    }
}

- (id)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame withReferView:nil inView:nil];
}

- (id)initWithFrame:(CGRect)frame withReferView:(UIView*)view inView:(UIView *)inView{
    self = [super initWithFrame:frame];
    if (self) {
        _referView = view;
        if (inView) {
            _superView = inView;
        }
        [self resetSelf];
        
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
       
       [self resetSelf];
        
    }
    return self;
}

- (void)resetSelf{
    
    if (_superView==nil) {
        _superView = [[HMUIApplication sharedInstance] window];
    }
    self.containerMode = UIPopoverContainerModeLight;
    
    touchAutoHide = YES;
     _arrowOffset = .5;
    _radius = 5;
    _arrowSize = CGSizeMake(20, 10);
    
    self.backImageview = [[[UIImageView alloc]init]autorelease];
    self.backImageview.contentMode = UIViewContentModeBottom;
    self.backImageview.clipsToBounds = YES;
    [self addSubview:self.backImageview];
    
    _popoverViewContainer = [[HMUIView spawn]retain];
    _popoverViewContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:_popoverViewContainer];
    
    self.popoverShape = [HMUISpeechBubbleShape shapeBottomWithRadius:_radius arrow:_arrowOffset pointSize:CGSizeMake(20,10)];
    _popoverArrowDirection = UIPopoverArrowDirectionUnknown;
    
    
    [self load];
    
}

- (void)initSelfDefault{
    self.backgroundColor = [UIColor clearColor];
    self.containerMode = UIPopoverContainerModeLight;
    self.style__ = [HMUILinearGradientFillStyle styleWithColor1:RGBA(0, 0, 0, .15) color2:RGBA(0, 0, 0, .65) next:nil];
    self.showGlass = YES;
    self.showReferHighlight = YES;
}

- (void)dealloc
{
    [self unload];
    self.popoverShape = nil;
    self.tableDatas = nil;
    [_popoverViewContainer release];
    _popoverViewContainer = nil;
    [_contentView release];
    self.shadowColor = nil;
    self.solidFillColor = nil;
    self.borderColor = nil;
    self.backImageview = nil;
    HM_SUPER_DEALLOC();
}


- (void)setShadowColor:(UIColor *)shadowColor{
    if (_shadowColor!=shadowColor) {
        [_shadowColor release];
        _shadowColor = [shadowColor retain];
    }
    [self initStyle:_directionTmp<UIPopoverArrowDirectionAny];
    [_popoverViewContainer setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor{
    if (_borderColor!=borderColor) {
        [_borderColor release];
        _borderColor = [borderColor retain];
    }
    [self initStyle:_directionTmp<UIPopoverArrowDirectionAny];
    [_popoverViewContainer setNeedsDisplay];
}

- (void)setSolidFillColor:(UIColor *)solidFillColor{
    if (_solidFillColor!=solidFillColor) {
        [_solidFillColor release];
        _solidFillColor = [solidFillColor retain];
    }
    [self initStyle:_directionTmp<UIPopoverArrowDirectionAny];
    [_popoverViewContainer setNeedsDisplay];
}

- (void)setShowGlass:(BOOL)showGlass{
    _showGlass = showGlass;
    [self initStyle:_directionTmp<UIPopoverArrowDirectionAny];
    [_popoverViewContainer setNeedsDisplay];
}

- (void)setBackgroundStyle:(UIPopoverBackgroundStyle)backgroundStyle{
    _backgroundStyle = backgroundStyle;
    if (_backgroundStyle==UIPopoverBackgroundStyle_shadow) {
        
    }else{
        self.style__ = nil;
    }
    [self setNeedsDisplay];
}

- (void)setContentRect:(CGRect)contentRect{
    _contentRect = contentRect;
    _directionTmp = UIPopoverArrowDirectionUnknown;
    _contentView.size = _contentRect.size;
    [self resetFrame];
}

- (void)setReferView:(UIView *)referView{
    BOOL changed = NO;
    if (_referView!=referView) {
        changed = YES;
        _popoverArrowDirection = UIPopoverArrowDirectionUnknown;
    }
    _referView = referView;
    _directionTmp = UIPopoverArrowDirectionUnknown;
    [self resetFrame];
    if (changed) {
        [self setNeedsDisplay];
    }
    
}

- (UIView *)contentView{

    return _contentView;
}

- (void)setContentView:(UIView *)contentView autolayout:(void (^)(UIView *))autolayout{
    if ( _contentView != contentView )
    {
        if (_contentView.superview == _popoverViewContainer) {
            [_contentView removeFromSuperview];
            
        }
        [_contentView release];
        _contentView = [contentView retain];
        
        if ( _contentView.superview != _popoverViewContainer )
        {
            [_contentView removeFromSuperview];
        }
        if (_contentView) {
            [_popoverViewContainer addSubview:_contentView];
            _contentRect = contentView.bounds;
            if (autolayout) {
                autolayout(contentView);
                if (!contentView.translatesAutoresizingMaskIntoConstraints) {
                    [contentView needsUpdateConstraints];
                    [contentView updateConstraints];
                    CGSize ss = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
                    _contentRect.size = ss;
                }else{
                    _contentRect = contentView.bounds;
                }
            }
            _directionTmp = UIPopoverArrowDirectionUnknown;
            [self resetFrame];
        }
        
    }
}

- (void)setContentView:(UIView *)contentView{
    
    [self setContentView:contentView autolayout:nil];
}

- (void)showWithAnimated:(BOOL)animated{
    if (self.superview==nil) {

        if (_backgroundStyle==UIPopoverBackgroundStyle_glass) {
            CGRect rr = [_referView frameInWindow];
            if (!CGRectEqualToRect(rr, CGRectZero)) {
                CGRect ss = [_superView frameInWindow];
                rr.origin.y -= ss.origin.y;
                rr.origin.x -= ss.origin.x;
            }

            UIColor *color = self.solidFillColor.saturation < 0.2?[UIColor colorWithWhite:0.1 alpha:0.4]:self.solidFillColor;
            
            UIImage *image = [[_superView capture] imageByApplyingBlurWithRadius:5.0 tintColor:color blendRect:rr];//[[_superView capture] blurryImageWithBlurLevel:.5 iterations:2 tintColor:color blendRect:rr radius:referHighlightRadius];

            self.backImageview.image = image;
        }else{
            self.backImageview.image = nil;
        }
        
        
        [_superView addSubview:self];
        if (animated) {
            CGAffineTransform scale = CGAffineTransformMakeScale(.9, .1);
            CGAffineTransform tran = CGAffineTransformMakeTranslation(0, _popoverViewContainer.height/2);
            
            switch (_directionTmp) {
                case UIPopoverArrowDirectionAny:
                    scale = CGAffineTransformMakeScale(.9, .9);
                    tran = CGAffineTransformMakeTranslation(0, _popoverViewContainer.height/2);
                    break;
                case UIPopoverArrowDirectionDown:
                    scale = CGAffineTransformMakeScale(.95, .95);
                    tran = CGAffineTransformMakeTranslation(0, _popoverViewContainer.height/2);
                    tran = CGAffineTransformIdentity;
                    break;
                case UIPopoverArrowDirectionUp:
                    scale = CGAffineTransformMakeScale(.95, .95);
                    tran = CGAffineTransformMakeTranslation(0, -_popoverViewContainer.height/2);
                    tran = CGAffineTransformIdentity;
                    break;
                case UIPopoverArrowDirectionLeft:
                    scale = CGAffineTransformMakeScale(.95, .95);
                    tran = CGAffineTransformMakeTranslation(-_popoverViewContainer.width/2, 0);
                    tran = CGAffineTransformIdentity;
                    break;
                case UIPopoverArrowDirectionRight:
                    scale = CGAffineTransformMakeScale(.95, .95);
                    tran = CGAffineTransformMakeTranslation(_popoverViewContainer.width/2, 0);
                    tran = CGAffineTransformIdentity;
                    break;
                default:
                    break;
            }
            
            CGRect rect = self.bounds;
            CGRect torect = self.bounds;
            if (_containerMode&UIPopoverContainerModeTop){
                tran = CGAffineTransformMakeTranslation(0, -_popoverViewContainer.height/2);
                scale = CGAffineTransformIdentity;
                if (_backgroundStyle==UIPopoverBackgroundStyle_glass) {
                    rect.size.height = 0;
                    torect.size.height = _popoverViewContainer.height+10;
                    tran = CGAffineTransformMakeTranslation(0, -_popoverViewContainer.height-10);
                }
            }else if (_containerMode&UIPopoverContainerModeBottom){
                scale = CGAffineTransformIdentity;
                if (_backgroundStyle==UIPopoverBackgroundStyle_glass) {
                    rect.size.height = 0;
                    rect.origin.y = self.height-10;
                    torect.size.height = _popoverViewContainer.height+10;
                    torect.origin.y = self.height-torect.size.height;
                    tran = CGAffineTransformMakeTranslation(0, _popoverViewContainer.height+10);
                }
            }else{
                _popoverViewContainer.alpha=.0f;
                self.backImageview.alpha = 0.f;
            }
            if (_backgroundStyle!=UIPopoverBackgroundStyle_glass) {
                self.alpha = .0f;
            }
            CGAffineTransform concat = CGAffineTransformConcat(scale, tran);
            
            _popoverViewContainer.transform = concat;
            self.backImageview.frame = rect;
            [UIView animateWithDuration:0.35f animations:^{
                if (_backgroundStyle==UIPopoverBackgroundStyle_glass) {
                    
                    if (!(_containerMode&UIPopoverContainerModeBottom)&&!(_containerMode&UIPopoverContainerModeTop)) {
                        self.backImageview.alpha = 1.f;
                    }else{
                        self.backImageview.frame = torect;
                    }
                    
                }else{
                    self.alpha = 1.f;
                }
                _popoverViewContainer.alpha=1.0f;
                _popoverViewContainer.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (void)dissmissAnimated:(BOOL)animated{
    if (animated) {
        CGAffineTransform scale = CGAffineTransformMakeScale(.9, .1);
        CGAffineTransform tran = CGAffineTransformMakeTranslation(0, _popoverViewContainer.height/2);
        
        
        switch (_directionTmp) {
            case UIPopoverArrowDirectionAny:
                scale = CGAffineTransformMakeScale(.9, .9);
                tran = CGAffineTransformMakeTranslation(0, _popoverViewContainer.height/2);
                break;
            case UIPopoverArrowDirectionDown:
                scale = CGAffineTransformMakeScale(.95, .95);
                tran = CGAffineTransformMakeTranslation(0, _popoverViewContainer.height/2);
                tran = CGAffineTransformIdentity;
                break;
            case UIPopoverArrowDirectionUp:
                scale = CGAffineTransformMakeScale(.95, .95);
                tran = CGAffineTransformMakeTranslation(0, -_popoverViewContainer.height/2);
                tran = CGAffineTransformIdentity;
                break;
            case UIPopoverArrowDirectionLeft:
                scale = CGAffineTransformMakeScale(.95, .95);
                tran = CGAffineTransformMakeTranslation(-_popoverViewContainer.width/2, 0);
                tran = CGAffineTransformIdentity;
                break;
            case UIPopoverArrowDirectionRight:
                scale = CGAffineTransformMakeScale(.95, .95);
                tran = CGAffineTransformMakeTranslation(_popoverViewContainer.width/2, 0);
                tran = CGAffineTransformIdentity;
                break;
            default:
                break;
        }

        CGRect rect = self.bounds;
        if (_containerMode&UIPopoverContainerModeTop){
            tran = CGAffineTransformMakeTranslation(0, -_popoverViewContainer.height/2);
            scale = CGAffineTransformIdentity;
            if (_backgroundStyle==UIPopoverBackgroundStyle_glass) {
                rect.size.height = 0;
                tran = CGAffineTransformMakeTranslation(0, -_popoverViewContainer.height-10);
            }
        }else if (_containerMode&UIPopoverContainerModeBottom){
            scale = CGAffineTransformIdentity;
            if (_backgroundStyle==UIPopoverBackgroundStyle_glass) {
                rect.size.height = 0;
                rect.origin.y = self.height;
                tran = CGAffineTransformMakeTranslation(0, _popoverViewContainer.height+10);
            }
        }
        
        CGAffineTransform concat = CGAffineTransformConcat(scale, tran);
        
        [UIView animateWithDuration:.35f animations:^{
            if (_backgroundStyle==UIPopoverBackgroundStyle_glass) {
                self.backImageview.frame = rect;
                self.backImageview.alpha = 0.f;
            }else{
                self.alpha = 0.f;
            }
            _popoverViewContainer.transform = concat;
            _popoverViewContainer.alpha=.0f;
            
        }completion:^(BOOL finished) {
            
            _popoverViewContainer.alpha=1.0f;
            self.alpha = 1.f;
            _popoverViewContainer.transform = CGAffineTransformIdentity;
            [self removeFromSuperview];
        }];
    }else{
        [self removeFromSuperview];
    }

}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point  = [(UITouch*)touches.anyObject locationInView:self];
    if (CGRectContainsPoint(_popoverViewContainer.frame, point)) {
        return;
    }
    
    if (self.touchAutoHide) {
        [self dissmissAnimated:YES];
    }
    
}

- (CGPoint)getArrow:(BOOL*)hasArrow direction:(UIPopoverArrowDirection*)directionInner directionOffset:(CGFloat*)arrowOffsetInner minRect:(CGRect)minRect   {
    //计算出popover 的x,y
    //参照视图相对window的位置
    CGRect referFrame = [_referView frameInWindow];
    CGRect superFrame = [_superView frameInWindow];
    referFrame.origin.x -= superFrame.origin.x;
    referFrame.origin.y -= superFrame.origin.y;
    _referFrame = referFrame;
    
    if (_referView==nil) {
        referFrame = self.bounds;
        referFrame.size = CGSizeZero;
        referFrame.origin.x = self.width/2;
        referFrame.origin.y = (self.height - minRect.size.height)/2;
        *directionInner = UIPopoverArrowDirectionAny;
    }else{
        
        CGPoint referCenter = CGPointMake(referFrame.origin.x+referFrame.size.width/2, referFrame.origin.y+referFrame.size.height/2);
        CGFloat offsetx = referCenter.x-minRect.size.width/2;
        CGFloat offsetxR = self.width-referCenter.x-minRect.size.width/2;
        CGFloat offsety = referCenter.y-minRect.size.height/2;
        CGFloat offsetyB = self.height-referCenter.y-minRect.size.height/2;
        
        //如果参照视图上方可以容下popver
        
        
        if ((referFrame.origin.y>minRect.size.height
             &&_popoverArrowDirection==UIPopoverArrowDirectionUnknown)
            ||_popoverArrowDirection==UIPopoverArrowDirectionDown){
            
            minRect.origin.x = offsetx>0 ? (offsetxR<0?(referCenter.x+offsetxR-minRect.size.width/2):offsetx):0;
            minRect.origin.y = referFrame.origin.y - minRect.size.height;
            *arrowOffsetInner = offsetx<0?.5f-(offsetx/(minRect.size.width-2*_radius-_arrowSize.width)):.5f+(offsetxR<0?(offsetxR/(minRect.size.width-2*_radius-_arrowSize.width)):0);
            *arrowOffsetInner = MIN(*arrowOffsetInner, .9999);
            *directionInner = UIPopoverArrowDirectionDown;
            
        }else if ((self.height-referFrame.origin.y-referFrame.size.height>minRect.size.height
                   &&_popoverArrowDirection==UIPopoverArrowDirectionUnknown)
                  ||_popoverArrowDirection==UIPopoverArrowDirectionUp){
            
            minRect.origin.x = offsetx>0 ? (offsetxR<0?(referCenter.x+offsetxR-minRect.size.width/2):offsetx):0;
            minRect.origin.y = referFrame.origin.y + referFrame.size.height;
            *arrowOffsetInner = offsetx<0?.5f+(offsetx/(minRect.size.width-2*_radius-_arrowSize.width)):.5f+(offsetxR<0?-(offsetxR/(minRect.size.width-2*_radius-_arrowSize.width)):0);
            *arrowOffsetInner = MIN(*arrowOffsetInner, .9999);
            *directionInner = UIPopoverArrowDirectionUp;
            
            
        }else if ((referFrame.origin.x>minRect.size.width
                   &&_popoverArrowDirection==UIPopoverArrowDirectionUnknown)
                  ||_popoverArrowDirection==UIPopoverArrowDirectionRight){ //如果参照视图左方可以容下popver
            
            minRect.origin.y = offsety>0 ? (offsetyB<0?(referCenter.y+offsetyB-minRect.size.height/2):offsety):0;
            minRect.origin.x = referFrame.origin.x - minRect.size.width;
            *arrowOffsetInner = offsety<0?(.5f+(offsety/(minRect.size.height-2*_radius-_arrowSize.width))):(.5f+(offsetyB<0?-(offsetyB/(minRect.size.height-2*_radius-_arrowSize.width)):0));
            *arrowOffsetInner = MIN(*arrowOffsetInner, .9999);
            *directionInner = UIPopoverArrowDirectionRight;
            
            
        }else if ((self.width-referFrame.origin.x-referFrame.size.width>minRect.size.width
                   &&_popoverArrowDirection==UIPopoverArrowDirectionUnknown)
                  ||_popoverArrowDirection==UIPopoverArrowDirectionLeft){//如果参照视图右方可以容下popver
            
            minRect.origin.y = offsety>0 ? (offsetyB<0?(referCenter.y+offsetyB-minRect.size.height/2):offsety):0;
            minRect.origin.x = referFrame.origin.x + referFrame.size.width;
            *arrowOffsetInner = offsety<0?.5f+(offsety/(minRect.size.height-2*_radius-_arrowSize.width)):.5f+(offsetyB<0?-(offsetyB/(minRect.size.height-2*_radius-_arrowSize.width)):0);
            *arrowOffsetInner = MIN(*arrowOffsetInner, .9999);
            *directionInner = UIPopoverArrowDirectionLeft;
            
        }else{
            *directionInner = UIPopoverArrowDirectionAny;
            
        }
    }
    
    if (*directionInner == UIPopoverArrowDirectionAny) {
        *hasArrow = NO;
        minRect.origin = CGPointMake(self.centerX-minRect.size.width/2, self.centerY-minRect.size.height/2);
    }
    return minRect.origin;
}

- (void)resetFrame{
    if (_popoverViewContainer==nil) {
        return;
    }
    if (CGRectEqualToRect(_contentRect, CGRectZero)) {
        return;
    }
    //得到popover 的w,h.可能会有style边缘不与结果不匹配的问题
    [self initStyle:YES];
    
    CGRect minRect = [_popoverViewContainer styleMinBounds];
    
    minRect.size.width += MIN(_contentRect.size.width, self.width-minRect.size.width);
    minRect.size.height += MIN(_contentRect.size.height, self.height-minRect.size.height);
//    CGRect popoverMinRect = minRect;
    
    /*计算出style的箭头+箭头位置*/
    UIPopoverArrowDirection directionInner = UIPopoverArrowDirectionUnknown;
    CGFloat arrowOffsetInner = _arrowOffset;
    BOOL hasArrow=YES;
    
    //有临界状态,第一次打开时没有方向,计算后变成有方向的，
    //原因styleMinBounds 变小了，导致minRect计算出来刚好能在refer周围
    BOOL reset = _directionTmp==UIPopoverArrowDirectionUnknown?YES:NO;
    
    CGPoint containerPoint;
    if (_containerMode&UIPopoverContainerModeBottom){
        containerPoint =  CGPointMake(self.centerX-minRect.size.width/2, self.height-minRect.size.height);
        hasArrow = NO;
        reset = NO;
    }else if (_containerMode&UIPopoverContainerModeTop){
        containerPoint =  CGPointMake(self.centerX-minRect.size.width/2, 0);
        hasArrow = NO;
        reset = NO;
    }else{
        containerPoint =  [self getArrow:&hasArrow direction:&directionInner directionOffset:&arrowOffsetInner minRect:minRect];
    }
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"UIPopover",@"<<<%@ arrow  direction:%d arrowOffset:%.1f minRect[x:%.2f y:%.2f w:%.2f h:%.2f]",hasArrow?@"has":@"no",directionInner,arrowOffsetInner,containerPoint.x,containerPoint.y,minRect.size.width,minRect.size.height);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    if (_hasArrow!=hasArrow
        ||_directionTmp!=directionInner
        ||_arrowOffset!=arrowOffsetInner) {
        
        _hasArrow = hasArrow;
        _directionTmp = directionInner;
        _arrowOffset = arrowOffsetInner;
        
        [self initStyle:hasArrow];
        
        
        minRect = [_popoverViewContainer styleMinBounds];
        minRect.size.width += MIN(_contentRect.size.width, self.width-minRect.size.width);
        minRect.size.height += MIN(_contentRect.size.height, self.height-minRect.size.height);
    }

    if (reset) {
        [self resetFrame];
    }else{
        
        minRect.origin = containerPoint;
        //重新计算一次 minRect
        //popoverMinRect //前面计算后得到的container的大小,包含了可能错误的style
        [_popoverViewContainer setFrame:minRect];
        
        CGRect popoverMinRect = CGRectEdgeInsets(_popoverViewContainer.bounds, [_popoverViewContainer styleInsets]);
        
        [self resetContentViewRect:popoverMinRect];
    }
}

- (void)resetContentViewRect:(CGRect)rect{
    if (!_contentView.translatesAutoresizingMaskIntoConstraints) {

        [_popoverViewContainer removeConstraints:_popoverViewContainer.constraints];
        
        NSDictionary *dic = NSDictionaryOfVariableBindings(_contentView);
        NSString *VFL = [NSString stringWithFormat:@"V:|-%f-[_contentView]",rect.origin.y];
        NSArray *ar = [NSLayoutConstraint constraintsWithVisualFormat:VFL options:0 metrics:nil views:dic];
        [_popoverViewContainer addConstraints:ar];
        
        VFL = [NSString stringWithFormat:@"|-%f-[_contentView]",rect.origin.x];
        ar = [NSLayoutConstraint constraintsWithVisualFormat:VFL options:0 metrics:nil views:dic];

        [_popoverViewContainer addConstraints:ar];
    }else{
        _contentView.frame = rect;
    }
}

-(void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
    
    [self resetFrame];
}

- (void)setPopoverArrowDirection:(UIPopoverArrowDirection)popoverArrowDirection{
    
    _popoverArrowDirection = popoverArrowDirection;
    [self resetFrame];
}

- (void)setContentCustom:(BOOL)contentCustom{
    _contentCustom = contentCustom;
    [self resetFrame];
}

- (void)setContainerMode:(UIPopoverContainerMode)containerMode{
    _containerMode = containerMode;
    
    if (_containerMode&UIPopoverContainerModeGlass) {
        self.solidFillColor = RGBA(56, 56, 56,.7);
        self.shadowColor = RGBA(0, 0, 0, .7);
        self.borderColor = RGBA(19, 19, 19, .7);
    }else{
        self.solidFillColor = RGBA(255, 255, 255, .7);
        self.shadowColor = RGBA(114, 156, 202, .7);
        self.borderColor = RGBA(100, 136, 182, .7);
    }
    [self resetFrame];
}

- (void)initStyle:(BOOL)hasArrow{
    
    if (!CGRectEqualToRect(_contentRect, CGRectZero)) {
        if (CGRectEqualToRect(self.bounds, _contentRect)||self.contentCustom) {
            _popoverViewContainer.style__ = nil;
            self.shadowOffset = CGSizeZero;
            return;
        }
    }else{
        return;
    }
    CGFloat shadow = 5;
    CGFloat contentInner = 7;
    self.shadowOffset = CGSizeMake(0, 5);
    UIEdgeInsets glassInset = UIEdgeInsetsAll(2);
    HMUIShape *shape = [HMUIRoundedRectangleShape shapeWithRadius:2.5];

    CGFloat arrowHeight = hasArrow?_arrowSize.height:0;
    
    UIEdgeInsets inset = UIEdgeInsetsTBAndHor(arrowHeight+contentInner, contentInner, contentInner);
    if (UIPopoverArrowDirectionUp==_directionTmp) {
        inset = UIEdgeInsetsTBAndHor(arrowHeight+contentInner, contentInner, contentInner);
        shape = self.popoverShape;
        glassInset = UIEdgeInsetsTBAndHor(1, 2, 2);
        self.popoverShape = [HMUISpeechBubbleShape shapeTopWithRadius:_radius arrow:_arrowOffset pointSize:_arrowSize];
        
    }else if (UIPopoverArrowDirectionDown==_directionTmp){
        inset = UIEdgeInsetsTBAndHor(contentInner, arrowHeight+contentInner, contentInner);
        self.popoverShape = [HMUISpeechBubbleShape shapeBottomWithRadius:_radius arrow:_arrowOffset pointSize:_arrowSize];
        
    }else if (UIPopoverArrowDirectionLeft==_directionTmp){
        inset = UIEdgeInsetsVerAndLR(contentInner, arrowHeight+contentInner, contentInner);

        glassInset = UIEdgeInsetsVerAndLR(2, 2+arrowHeight, 2);
        self.popoverShape = [HMUISpeechBubbleShape shapeRightWithRadius:_radius arrow:_arrowOffset pointSize:CGSizeMake(_arrowSize.height,_arrowSize.width)];
        
    }else if (UIPopoverArrowDirectionRight==_directionTmp){
        inset = UIEdgeInsetsVerAndLR(contentInner, contentInner, arrowHeight+contentInner);
        glassInset = UIEdgeInsetsVerAndLR(2, 2, 2+arrowHeight);
        self.popoverShape = [HMUISpeechBubbleShape shapeRightWithRadius:_radius arrow:_arrowOffset pointSize:CGSizeMake(_arrowSize.height,_arrowSize.width)];
        
    }else if (_directionTmp == UIPopoverArrowDirectionAny) {
        self.popoverShape = [HMUIRoundedRectangleShape shapeWithRadius:_radius];
    }

    
    //shadow
    HMUIStyle *shadowStyle = nil;
    if (self.shadowColor) {
        shadowStyle = [HMUIShadowStyle styleWithColor:self.shadowColor blur:shadow offset:CGSizeMake(0, 3) next:nil];
//        style.next = shadowStyle;
    }
    //fill color
    HMUIStyle *fillColorStyle =[HMUISolidFillStyle styleWithColor:self.solidFillColor next:nil];
    [HMUIInsetStyle styleWithInset:UIEdgeInsetsAll(3.25) next:
     [HMUISolidFillStyle styleWithColor:self.solidFillColor next:
      [HMUIInsetStyle styleWithInset:UIEdgeInsetsAll(-3.25) next:nil]]];
    if (shadowStyle) {
        shadowStyle.next = fillColorStyle;
    }else{
        shadowStyle = fillColorStyle;
    }
    
    // border
    HMUIStyle *borderStyle = [HMUISolidBorderStyle styleWithColor:self.borderColor width:1 next:nil];
    fillColorStyle.next = borderStyle;
    
    //box glass
    HMUIStyle *glassStyle = nil;
    if (self.showGlass) {
        glassStyle = [HMUIShapeStyle styleWithShape:shape next:
                                 //inset save for new frame
                                 [HMUIInsetStyle styleWithSaveForInset:glassInset butWidth:0 height:1.5*_arrowSize.height next:
                                  [HMUIReflectiveFillStyle styleWithColor:RGBGLASSB next:
                                   //inset save end
                                   [HMUIInsetStyle styleWithRestoreNext:nil]]]];
        //box end
        borderStyle.next = glassStyle;
    }
    //set inset
    HMUIStyle *insetStyle = [HMUIInsetStyle styleWithInset:inset next:nil];
    if (glassStyle) {
        glassStyle.next = insetStyle;
    }else{
        borderStyle.next = insetStyle;
    }
    
    //rect
    HMUIStyle *style = [HMUIShapeStyle styleWithShape:
                        self.popoverShape next:shadowStyle];
    
    _popoverViewContainer.style__ = style;
    
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (_referView&&self.showReferHighlight) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGContextSetBlendMode(ctx, kCGBlendModeClear);
        if (self.referHighlightRadius<=0) {
            CGContextAddRect(ctx, _referFrame);
        }else{
            CGContextMoveToPoint(ctx, _referFrame.origin.x+self.referHighlightRadius, _referFrame.origin.y);
            CGContextAddArcToPoint(ctx, _referFrame.origin.x+_referFrame.size.width, _referFrame.origin.y,  _referFrame.origin.x+_referFrame.size.width, _referFrame.origin.y+_referFrame.size.height, self.referHighlightRadius);
            CGContextAddArcToPoint(ctx, _referFrame.origin.x+_referFrame.size.width, _referFrame.origin.y+_referFrame.size.height,  _referFrame.origin.x, _referFrame.origin.y+_referFrame.size.height, self.referHighlightRadius);
            CGContextAddArcToPoint(ctx, _referFrame.origin.x, _referFrame.origin.y+_referFrame.size.height,  _referFrame.origin.x, _referFrame.origin.y, self.referHighlightRadius);
            CGContextAddArcToPoint(ctx, _referFrame.origin.x, _referFrame.origin.y,  _referFrame.origin.x+_referFrame.size.width, _referFrame.origin.y, self.referHighlightRadius);
            CGContextClosePath(ctx);
        }
        CGContextFillPath(ctx);
        CGContextRestoreGState(ctx);
    }
    
}

#pragma mark - for table
DEF_SIGNAL2(TableCell, HMUIPopoverView)
DEF_SIGNAL2(TableRows, HMUIPopoverView)
DEF_SIGNAL2(TableSelect, HMUIPopoverView)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    HMSignal *signal = [self sendSignal:[HMUIPopoverView TableRows]];
    if (signal.returnValue) {
        return [signal.returnValue integerValue];
    }
    if (self.tableDatas) {
        return self.tableDatas.count;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HMSignal *signal = [self sendSignal:[HMUIPopoverView TableCell] withObject:indexPath];
    if (signal.returnValue&&[signal.returnValue isKindOfClass:[UITableViewCell class]]) {
        return signal.returnValue;
    }
    
    static NSString *CellIdentifier = @"PopoverViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
        
    }
    
    NSDictionary *dic = [self.tableDatas safeObjectAtIndex:indexPath.row];
    if (dic) {
        cell.textLabel.text = [dic valueForKey:@"popoverTitle"];
        BOOL selected = [[dic valueForKey:@"popoverSelected"] boolValue];
        if (selected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self sendSignal:[HMUIPopoverView TableSelect] withObject:indexPath];
}

@end



