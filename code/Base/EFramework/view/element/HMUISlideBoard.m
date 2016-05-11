//
//  slide.m
//  EFExtend
//
//  Created by mac on 15/3/22.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUISlideBoard.h"



@interface HMUISlideBoard ()
@property (nonatomic,HM_STRONG,readwrite) UIViewController *root;//前置页面，页面切换将基于root
@property (nonatomic,HM_STRONG,readwrite) UIViewController *left;
@property (nonatomic,HM_STRONG,readwrite) UIViewController *right;
@property (nonatomic,HM_STRONG,readwrite) UIViewController *top;
@property (nonatomic,HM_STRONG,readwrite) UIViewController *bottom;
@end

@implementation HMUISlideBoard{
    NSInteger panDirection;
    BOOL    back;
    BOOL    tap;
}
@synthesize root;
@synthesize left;
@synthesize right;
@synthesize top;
@synthesize bottom;
@synthesize style=_style;
@synthesize hasNavgator = _hasNavgator;
@synthesize actionPercent=_actionPercent;
@synthesize actionPercentTop;
@synthesize actionPercentRight;
@synthesize actionPercentLeft;
@synthesize actionPercentBottom;
@synthesize showBottom=_showBottom;
@synthesize showLeft=_showLeft;
@synthesize showRight=_showRight;
@synthesize showTop=_showTop;
@synthesize state;
@synthesize disableDrag=_disableDrag;

DEF_SIGNAL2( TOGGLETO ,HMUISlideBoard)
DEF_SIGNAL2( TOGGLETOColsePre ,HMUISlideBoard)
DEF_SIGNAL2( TOGGLETOGetchild ,HMUISlideBoard)
DEF_SIGNAL2( TOGGLETOState ,HMUISlideBoard)
DEF_SIGNAL2( TOGGLETOBack ,HMUISlideBoard)
DEF_SIGNAL2( TOGGLETOHome ,HMUISlideBoard)

- (void)dealloc
{
    self.homePage = nil;
    self.root = nil;
    self.left = nil;
    self.right = nil;
    self.top = nil;
    self.bottom = nil;
    HM_SUPER_DEALLOC();
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialization];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization{
    self.leftWidth  =80;
    self.rightWidth = 100;
    self.topWidth  =80;
    self.bottomWidth = 100;
    panDirection= -1;
    _style =  UISlideStyleNor;
    _options = UISlideOptionsQQ;
    _hasNavgator = NO;
    self.actionPercent = .9;
    self.actionPercentTop = 1.0;
    self.actionPercentBottom = 1.0;
    _duration = 0.25f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.disableDrag = NO;
    self.left = [self slideControllerForPosition:SlidePositionLeft];
    self.leftWidth = [self slideWidthForPosition:SlidePositionLeft];
    if (left) {
        self.left.view.hidden = YES;
        left.myFirstBoard.parentBoard = self;
        [self addChildViewController:left];
        [self.view addSubview:left.view];
        
    }
    
    self.right = [self slideControllerForPosition:SlidePositionRight];
    self.rightWidth = [self slideWidthForPosition:SlidePositionRight];
    if (right) {
        self.right.view.hidden = YES;
        right.myFirstBoard.parentBoard = self;
        [self addChildViewController:right];
        [self.view addSubview:right.view];
        
    }
    
    self.top = [self slideControllerForPosition:SlidePositionTop];
    self.topWidth = [self slideWidthForPosition:SlidePositionTop];
    if (top) {
        self.top.view.hidden = YES;
        top.myFirstBoard.parentBoard = self;
        [self addChildViewController:top];
        [self.view addSubview:top.view];
        
    }
    
    
    
    self.bottom = [self slideControllerForPosition:SlidePositionBottom];
    self.bottomWidth = [self slideWidthForPosition:SlidePositionBottom];
    if (bottom) {
        self.bottom.view.hidden = YES;
        bottom.myFirstBoard.parentBoard = self;
        [self addChildViewController:bottom];
        [self.view addSubview:bottom.view];
        
    }
    
    self.root = [HMUIBoard board];
    if (root) {
    
        [self addChildViewController:root];
        [self.view addSubview:root.view];

        self.root.view.clipsToBounds = NO;
        root.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    }else{
        NSParameterAssert(root==nil);
    }
    
}

- (void)setDisableDrag:(BOOL)disableDrag{
    _disableDrag = disableDrag;
    self.view.panEnabled = !disableDrag;
}

- (void)setActionPercent:(CGFloat)actionPercent{
    _actionPercent =actionPercent;
    self.actionPercentBottom = actionPercent;
    self.actionPercentLeft = actionPercent;
    self.actionPercentRight = actionPercent;
    self.actionPercentTop = actionPercent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHasNavgator:(BOOL)hasNavgator{
    _hasNavgator = hasNavgator;
    
    NSUInteger ss  = _style;
    _style=UISlideStyleNor;
    
    [self setStyle:ss];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_style==UISlideStyleNor) {
        self.style =  UISlideStyleBack;
    }
    
}

- (void)setStyle:(UISlideStyle)style{
    if (_style==style) {
        return;
    }
    _style = style;
    if (style==UISlideStyleBack) { //back 0
        if (left) {
            [self.view sendSubviewToBack:self.left.view];
            left.view.width = self.leftWidth;
            left.view.x = 0;
            left.view.y = _hasNavgator?self.navigatorBar.height:0;
            left.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
        }
        if (right) {
            [self.view sendSubviewToBack:self.right.view];
            right.view.width = self.rightWidth;
            right.view.x = self.view.width-self.rightWidth;
            right.view.y = _hasNavgator?self.navigatorBar.height:0;
            right.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        }
        
        if (top) {
            [self.view sendSubviewToBack:self.top.view];
            top.view.height = self.topWidth;
            top.view.x = 0;
            top.view.y = 0;
            top.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        }
        
        if (bottom) {
            [self.view sendSubviewToBack:self.bottom.view];
            bottom.view.height = self.bottomWidth;
            bottom.view.x = 0;
            bottom.view.y = self.view.height-self.bottomWidth;
            bottom.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        }
        [self.root.view showBackgroundShadowStyle:styleEmbossDarkLineArround];
        
    }else if (style==UISlideStyleFront){//front 1
        if (left) {
            [self.view bringSubviewToFront:self.left.view];
            left.view.width = self.leftWidth;
            left.view.x = -self.leftWidth;
            left.view.y = _hasNavgator?self.navigatorBar.height:0;
            left.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
            [left.view showBackgroundShadowStyle:styleEmbossDarkLineRight];
        }
        
        if (right) {
            [self.view bringSubviewToFront:self.right.view];
            right.view.width = self.rightWidth;
            right.view.x = self.view.width;
            right.view.y = _hasNavgator?self.navigatorBar.height:0;
            right.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
            [right.view showBackgroundShadowStyle:styleEmbossDarkLineLeft];
        }
        
        if (top) {
            [self.view bringSubviewToFront:self.top.view];
            top.view.height = self.topWidth;
            top.view.x = 0;
            top.view.y = -self.topWidth;
            top.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
            [top.view showBackgroundShadowStyle:styleEmbossDarkLineBottom];
        }
        if (bottom) {
            [self.view bringSubviewToFront:self.bottom.view];
            bottom.view.height = self.bottomWidth;
            bottom.view.x = 0;
            bottom.view.y = self.view.height;
            bottom.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
            [bottom.view showBackgroundShadowStyle:styleEmbossDarkLineTop];
        }
        
    }
    [self.view setNeedsDisplay];
    
}

#pragma mark - pan


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    tap = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchOutside:[touches anyObject]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //    [self touchOutside:[touches anyObject]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    tap = NO;
}

- (void)touchOutside:(UITouch*)touch{
    if (tap) {
        CGPoint touchPoint = [touch locationInView:self.root.view];
        if (touchPoint.x >0&&touchPoint.y>0) {
            switch (state) {
                case UISlideStateLeft:
                    self.showLeft = NO;
                    break;
                case UISlideStateRight:
                    self.showRight = NO;
                    break;
                case UISlideStateTop:
                    self.showTop = NO;
                    break;
                case UISlideStateBottom:
                    self.showBottom = NO;
                    break;
                default:
                    break;
            }
        }
    }
    
}

ON_PAN(signal){
    UIPanGestureRecognizer * panGesture = signal.inputValue;
    [self syncPanPosition:panGesture animated:YES];
}

- (BOOL)syncPanPosition:(UIPanGestureRecognizer *)pan animated:(BOOL)animte{
    
    CGPoint point = [pan locationInView:self.view];
    
    static  CGPoint startPoint = {0,0};
    static CGFloat offset = 0;
    static CGFloat offsety = 0;
    static BOOL adding = NO;
    static CGPoint prePoint = {0,0};
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        startPoint = point;
        prePoint = startPoint;
        
        if (self.style==UISlideStyleFront) {
            if (state==UISlideStateLeft) {
                offset = self.leftWidth;
            }else if (state == UISlideStateRight){
                offset = -self.rightWidth;
            }else{
                offset = 0;
                adding = YES;
            }
            
            if (state==UISlideStateTop) {
                offsety = self.topWidth;
            }else if (state==UISlideStateBottom) {
                offsety = -self.bottomWidth;
            }else{
                offsety = 0;
                adding = YES;
            }
            
        }else if (self.style==UISlideStyleBack){
            
            offset = self.root.view.transform.tx;
            offsety = self.root.view.transform.ty;
            if (state!=UISlideStateNone) {
                
                if (state==UISlideStateLeft) {
                    offset = (2-self.actionPercentLeft)*self.leftWidth;
                }else if (state == UISlideStateRight){
                    offset = -(2-self.actionPercentRight)*self.rightWidth;
                }else if (state==UISlideStateTop) {
                    offsety = (2-self.actionPercentTop)*self.topWidth;
                }else if (state==UISlideStateBottom) {
                    offsety = -(2-self.actionPercentBottom)*self.bottomWidth;
                }
            }
        }
    }
    
    CGFloat slide=point.x-startPoint.x+offset;
    CGFloat slidey=point.y-startPoint.y+offsety;
    
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        if (panDirection==-1) {
            if (fabs((point.x-startPoint.x)/(point.y-startPoint.y))>4) {
                panDirection = 1;//左右
                
                if (state == UISlideStateNone) {
                    if ((point.x-startPoint.x)>0&&self.left!=nil) {
                        state = UISlideStateLeft;
                        self.left.view.hidden = NO;
                    }else if(self.right!=nil){
                        state = UISlideStateRight;
                        self.right.view.hidden = NO;
                    }
                }
                
            }else if (fabs((point.y-startPoint.y)/(point.x-startPoint.x))>4){
                panDirection = 2;//上下
                
                if (state == UISlideStateNone) {
                    if ((point.y-startPoint.y)>0&&self.top!=nil) {
                        state = UISlideStateTop;
                        self.top.view.hidden = NO;
                    }else if(self.bottom!=nil){
                        state = UISlideStateBottom;
                        self.bottom.view.hidden = NO;
                    }
                }
            }
        }
        if (panDirection==-1) {
            return NO;
        }
        
        if (panDirection==1) {
            if (state == UISlideStateLeft) {
                adding = (point.x - prePoint.x)>=0;
            }else{
                adding = (-point.x + prePoint.x)>=0;
            }
        }else{
            
            if (state == UISlideStateTop) {
                adding = (point.y - prePoint.y)>=0;
            }else{
                adding = (-point.y + prePoint.y)>=0;
            }
        }
        
        prePoint = point;
        
        [self panTox:slide y:slidey];
        
    }
    
    if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded) {
        
        
        if (state == UISlideStateLeft) {
            slide = adding?(self.style==UISlideStyleBack&&_options==UISlideOptionsQQ?((2-self.actionPercentLeft)*self.leftWidth):self.leftWidth):0;
        }else if (state == UISlideStateRight){
            slide = adding?-(self.style==UISlideStyleBack&&_options==UISlideOptionsQQ?((2-self.actionPercentLeft)*self.rightWidth):self.rightWidth):0;
        }else if (state == UISlideStateTop){
            slidey = adding?(self.style==UISlideStyleBack&&_options==UISlideOptionsQQ?((2-self.actionPercentLeft)*self.topWidth):self.topWidth):0;
        }else if (state == UISlideStateBottom){
            slidey = adding?-(self.style==UISlideStyleBack&&_options==UISlideOptionsQQ?((2-self.actionPercentLeft)*self.bottomWidth):self.bottomWidth):0;
        }
        
        [self switchTox:slide y:slidey show:adding animated:YES];
        
    }
    return NO;
}
- (void)panTox:(CGFloat)slidex y:(CGFloat)slidey{
    if (panDirection==-1||state==UISlideStateNone) {
        return;
    }
    
    CGFloat offset = 0;
    CGFloat offsety = 0;
    CGAffineTransform scaleTransfrom = CGAffineTransformIdentity;
    CGFloat sca = 0;
    CGFloat lsca = 0;
    
    if (state==UISlideStateRight) {
        if (self.style==UISlideStyleBack&&_options==UISlideOptionsQQ){
            offset = MAX(MIN(slidex, 0), -(2-self.actionPercentRight)*self.rightWidth);
            
            sca = 1 - (-offset/self.rightWidth) * (1-self.actionPercentRight);
            lsca = 1 - sca + self.actionPercentRight;
            scaleTransfrom = CGAffineTransformMakeScale(sca,sca);
        }else{
            offset = MAX(MIN(slidex, 0), -self.rightWidth);
        }
    }else if (state==UISlideStateLeft) {
        
        if (self.style==UISlideStyleBack&&_options==UISlideOptionsQQ){
            offset = MIN(MAX(slidex, 0),(2-self.actionPercentLeft)*self.leftWidth);
            
            sca = 1 - (offset/self.leftWidth) * (1-self.actionPercentLeft);
            lsca = 1 - sca + self.actionPercentLeft;
            scaleTransfrom = CGAffineTransformMakeScale(sca,sca);
        }else{
            offset = MIN(MAX(slidex, 0),self.leftWidth);
        }
        
    }else if (state==UISlideStateTop) {
        
        
        if (self.style==UISlideStyleBack&&_options==UISlideOptionsQQ){
            offsety = MIN(MAX(slidey, 0), (2-self.actionPercentTop)*self.topWidth);
            sca = 1 - (-offsety/self.topWidth) * (1-self.actionPercentTop);
            lsca = 1 - sca + self.actionPercentTop;
            scaleTransfrom = CGAffineTransformMakeScale(sca,sca);
        }else{
            offsety = MIN(MAX(slidey, 0), self.topWidth);
        }
        
    }else if (state==UISlideStateBottom) {
        if (self.style==UISlideStyleBack&&_options==UISlideOptionsQQ){
            offsety = MAX(MIN(slidey, 0), -(2-self.actionPercentBottom)*self.bottomWidth);
            
            sca = 1 - (offsety/self.bottomWidth) * (1-self.actionPercentBottom);
            lsca = 1 - sca + self.actionPercentBottom;
            scaleTransfrom = CGAffineTransformMakeScale(sca,sca);
        }else{
            offsety = MAX(MIN(slidey, 0), -self.bottomWidth);
        }
    }
//#ifdef DEBUG
//    INFO(@"panDirection",@(panDirection),@"state",@(state),@"x",@(offset),@"y",@(offsety));
//#endif
    CGAffineTransform transfrom = CGAffineTransformMakeTranslation(offset, offsety);
    
    if (self.style==UISlideStyleFront) {
        
        
        if (state==UISlideStateRight) {
            self.right.view.transform = transfrom;
            
        }else if (state==UISlideStateLeft) {
            
            self.left.view.transform = transfrom;
            
        }else if (state==UISlideStateTop) {
            
            self.top.view.transform = transfrom;
            
        }else if (state==UISlideStateBottom) {
            
            self.bottom.view.transform = transfrom;
            
        }
        
    }else if (self.style==UISlideStyleBack) {
        if (_options==UISlideOptionsQQ) {
            
            transfrom = CGAffineTransformConcat(transfrom, scaleTransfrom);
        }
        self.root.view.transform = transfrom;
    }
    
}

- (void)switchTox:(CGFloat)slidex y:(CGFloat)slidey show:(BOOL)show animated:(BOOL)animated{
    if (panDirection==-1) {
        return;
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:_duration];
        [UIView setAnimationDelegate:self];
    }
    
    [self panTox:slidex y:slidey];
    
    if (animated) {
        [UIView setAnimationDidStopSelector:show?@selector(doTransformOk):@selector(doTransformCancel)];
        [UIView commitAnimations];
    }
    
}

- (void)doTransformOk{
    self.root.view.userInteractionEnabled = NO;
    [self slideShowed:state];
}

- (void)doTransformCancel{
    
    self.root.view.userInteractionEnabled = YES;
    [self slideHided:state];
    state=UISlideStateNone;
    self.right.view.hidden = YES;
    self.left.view.hidden = YES;
    self.bottom.view.hidden = YES;
    self.top.view.hidden = YES;
    panDirection = -1;
    
    self.right.view.transform = CGAffineTransformIdentity;
    self.left.view.transform = CGAffineTransformIdentity;
    self.bottom.view.transform = CGAffineTransformIdentity;
    self.top.view.transform = CGAffineTransformIdentity;
    self.root.view.transform = CGAffineTransformIdentity;
    
}

#pragma mark - toggle

- (void)setShowLeft:(BOOL)showLeft animated:(BOOL)animated{
    if (showLeft) {
        panDirection = 1;
        self.left.view.hidden = NO;
        state = UISlideStateLeft;
        [self switchTox:(self.style==UISlideStyleBack&&_options==UISlideOptionsQQ?((2-self.actionPercentLeft)*self.leftWidth):self.leftWidth) y:0 show:showLeft animated:YES];
    }else{
        [self switchTox:0 y:0 show:showLeft animated:YES];
    }
}
- (BOOL)showLeft{
    return !self.left.view.hidden;
}

- (void)setShowLeft:(BOOL)showLeft{
    [self setShowLeft:showLeft animated:YES];
}

- (void)setShowRight:(BOOL)showRight animated:(BOOL)animated{
    if (showRight) {
        panDirection = 1;
        self.right.view.hidden = NO;
        state = UISlideStateRight;
        [self switchTox:-(self.style==UISlideStyleBack&&_options==UISlideOptionsQQ?((2-self.actionPercentLeft)*self.rightWidth):self.rightWidth) y:0 show:showRight animated:YES];
    }else{
        [self switchTox:0 y:0 show:showRight animated:YES];
    }
}

- (BOOL)showRight{
    return !self.right.view.hidden;
}

- (void)setShowRight:(BOOL)showRight{
    [self setShowRight:showRight animated:YES];
}

- (void)setShowBottom:(BOOL)showBottom animated:(BOOL)animated{
    if (showBottom) {
        
        panDirection = 2;
        self.bottom.view.hidden = NO;
        state = UISlideStateBottom;
        [self switchTox:0 y:-(self.style==UISlideStyleBack&&_options==UISlideOptionsQQ?((2-self.actionPercentLeft)*self.bottomWidth):self.bottomWidth) show:showBottom animated:YES];
    }else{
        [self switchTox:0 y:0 show:showBottom animated:YES];
    }
}

- (BOOL)showBottom{
    return !self.bottom.view.hidden;
}

- (void)setShowBottom:(BOOL)showBottom{
    [self setShowBottom:showBottom animated:YES];
}

- (void)setShowTop:(BOOL)showTop animated:(BOOL)animated{
    if (showTop) {
        
        panDirection = 2;
        self.bottom.view.hidden = NO;
        state = UISlideStateTop;
        [self switchTox:0 y:(self.style==UISlideStyleBack&&_options==UISlideOptionsQQ?((2-self.actionPercentLeft)*self.topWidth):self.topWidth) show:showTop animated:YES];
    }else{
        [self switchTox:0 y:0 show:showTop animated:YES];
    }
}

- (BOOL)showTop{
    return !self.top.view.hidden;
}

- (void)setShowTop:(BOOL)showTop{
    [self setShowTop:showTop animated:YES];
}

- (void)toggleAuto:(UISlideState)stat animated:(BOOL)animated{
    if (stat==UISlideStateLeft) {
        [self setShowLeft:!self.showLeft animated:animated];
    }else if (stat==UISlideStateRight) {
        [self setShowRight:!self.showRight animated:animated];
    }else if (stat==UISlideStateTop) {
        [self setShowTop:!self.showTop animated:animated];
    }else if (stat==UISlideStateBottom) {
        [self setShowBottom:!self.showBottom animated:animated];
    }
}

- (void)toggleToNormal:(BOOL)animated{
    if (self.showLeft) {
        [self setShowLeft:NO animated:animated];
    }else if (self.showRight) {
        [self setShowRight:NO animated:animated];
    }else if (self.showTop) {
        [self setShowTop:NO animated:animated];
    }else if (self.showBottom) {
        [self setShowBottom:NO animated:animated];
    }
}

- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL *)isnew closePre:(BOOL)preClose complete:(void (^)(BOOL, UIViewController *))commple{
    return [self.root putChild:path map:map isNew:isnew closePre:preClose complete:commple];
}

- (HMUIBoard *)getChild:(NSString *)name{
    return [self.root getChild:name];
}

#pragma mark - overwrite
- (void)slideShowed:(UISlideState)state{
    
}

- (void)slideHided:(UISlideState)state{
    
}

- (UIViewController *)slideControllerForPosition:(SlidePosition)position{
    return [HMUIBoard board];
}

- (CGFloat)slideWidthForPosition:(SlidePosition)position{
    switch (position) {
        case SlidePositionLeft:
            return 80;
            break;
        case SlidePositionRight:
            return 100;
            break;
        case SlidePositionTop:
            return 80;
            break;
        case SlidePositionBottom:
            return 100;
            break;
        default:
            break;
    }

    return 0;
}

ON_SIGNAL3(HMUIBoard, ORIENTATION_WILL_CHANGE, signal){
    [self toggleToNormal:YES];
    signal.forward = YES;
}

ON_SIGNAL2(HMUISlideBoard, signal){
    NSDictionary *dic = signal.inputValue;
    id path = nil;
    NSString *map = nil;
    BOOL animated = YES;
    BOOL closePre = NO;
    CC(@"HMUISlideBoard",signal.name,dic);
    if ([signal is:[HMUISlideBoard TOGGLETO]]) {
        path = [dic valueForKey:@"path"];
        closePre = [[dic valueForKey:@"closePre"] boolValue];
        map = [dic valueForKey:@"map"];
        if ([path isKindOfClass:[NSString class]]) {
            if ([path is:@"HOME_)_"]) {
                path = self.homePage;
                NSAssert(self.homePage, @"这个不行的，你要设置 homePage ");
            }else if ([path is:@"MAIN_)_"]) {
                [self backWithAnimate:YES remove:closePre];
                return;
            }
        }
        
    }else if ([signal is:[HMUISlideBoard TOGGLETOGetchild]]){
        if ([path is:@"MAIN_)_"]){
            signal.returnValue = self;
        }else{
            signal.returnValue = [self getChild:path];
        }
        return;
    }else if ([signal is:[HMUISlideBoard TOGGLETOState]]) {
        path = dic;
        UISlideState s = [path integerValue];
        [self toggleAuto:s animated:YES];
        return;
    }
    
    BOOL isnew=NO;
    WS(weakSelf)
    UIViewController *ret = [self putChild:path map:[map notEmpty]?map:nil isNew:&isnew closePre:closePre complete:^(BOOL viewLoaded, UIViewController *toBoard) {
        if (!viewLoaded) toBoard.myFirstBoard.parentBoard = weakSelf;
    }];
    NSAssert(ret, @"这个不行的，你给的 path 不认识");
    [self toggleToNormal:animated];
    signal.returnValue = ret;
}

@end

@implementation UIViewController (HMUISlideBoard_toggle)

- (HMUIBoard *)slideToggleToChild:(id)path map:(NSString *)map closePre:(BOOL)closePre{
    NSDictionary *dic = @{@"closePre":@(closePre),@"path":path==nil?@"":path,@"map":map==nil?@"":map};
    HMSignal * signal = [self sendSignal:[HMUISlideBoard TOGGLETO] withObject:dic];
    return signal.returnValue;
}

- (HMUIBoard *)slideToggleToHomeAndClosePre:(BOOL)closePre{
    return [self slideToggleToChild:@"HOME_)_" map:@"HOME_)_" closePre:closePre];
}

- (HMUIBoard *)slideToggleToMainAndClose:(BOOL)close{
    return [self slideToggleToChild:@"MAIN_)_" map:nil closePre:close];
}

- (HMUIBoard *)slideGetChild:(id)path{
    HMSignal * signal = [self sendSignal:[HMUISlideBoard TOGGLETOGetchild] withObject:path];
    return signal.returnValue;
}

- (void)slideShowSide:(UISlideState)state{
    [self sendSignal:[HMUISlideBoard TOGGLETOState] withObject:@(state)];
}


@end
