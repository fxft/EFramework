//
//  HMUINavigationBar.m
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUINavigationBar.h"
#import "UIImage+HMExtension.h"

@interface HMUINavigationBar()
{
    __weak_type UINavigationController *_navigationController;

}

@property (nonatomic,strong) UIView * sublayer;
@property (nonatomic,strong) UIView * baselayer;
@property (nonatomic,strong) UIImageView * imagelayer;
@property (nonatomic,strong) UIImageView * shadowlayer;

@end


@implementation HMUINavigationBar

DEF_NOTIFICATION( STYLE_CHANGED )
DEF_NOTIFICATION( STATUS_CHANGED )

DEF_INT( LEFT,	0 )
DEF_INT( RIGHT,	1 )

DEF_SIGNAL2( LEFT_TOUCHED ,HMUINavigationBar)
DEF_SIGNAL2( RIGHT_TOUCHED ,HMUINavigationBar)

@synthesize navigationController = _navigationController;
@synthesize sublayer=_sublayer;
@synthesize imagelayer = _imagelayer;
@synthesize shadowlayer = _shadowlayer;

static CGSize		__buttonSize = { 0 };

- (void)handleEvent:(HMEvent *)event
{
    if ( _navigationController )
    {
        UIViewController * vc = _navigationController.topViewController;
        if ( vc )
        {
            [event forward:vc];
        }
    }
    else
    {
        [super handleEvent:event];
    }
}

#pragma mark -

+ (CGSize)buttonSize
{
    return __buttonSize;
}

+ (void)setTitleColor:(UIColor *)color
{
    
    [HMUIConfig sharedInstance].defaultNavigationTitleColor = color;

}

+ (void)setTitleFont:(UIFont *)font{
    
    [HMUIConfig sharedInstance].defaultNavigationTitleFont = font;
    
}

+ (void)setButtonSize:(CGSize)size
{
    __buttonSize = size;
}

+ (void)setBackgroundColor:(UIColor *)color
{
    
    [HMUIConfig sharedInstance].defaultNavigationBarColor = color;

}

+ (void)setBackgroundOriginalColor:(UIColor *)color
{
    
    [HMUIConfig sharedInstance].defaultNavigationBarOriginalColor = color;
    
}


+ (void)setBackgroundImage:(UIImage *)image
{
    
    [HMUIConfig sharedInstance].defaultNavigationBarImage = image;
    
}

+ (void)setShadowImage:(UIImage *)image
{
    
    [HMUIConfig sharedInstance].defaultNavigationBarShadowImage = image;
    
}


+ (void)setBackgroundTranslucent:(BOOL)trans{
    [HMUIConfig sharedInstance].defaultNavigationBarTranslucent = trans;
}

- (CGSize)intrinsicContentSize{
    CGSize size = [super intrinsicContentSize];
    
    return size;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
}

- (CGSize)sizeThatFits:(CGSize)size{
    CGSize navigationBarSize = [super sizeThatFits:size];
//    32/44
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
//        self.frame = CGRectMake(0, IOS8_OR_LATER?0:20, navigationBarSize.width, navigationBarSize.height);
        self.frame = CGRectMake(0, 20, navigationBarSize.width, navigationBarSize.height);
    }else{
        if (!CGRectEqualToRect(CGRectMake(0, 20, navigationBarSize.width, navigationBarSize.height), self.frame)) {
            self.frame = CGRectMake(0, 20, navigationBarSize.width, navigationBarSize.height);
        }
        
    }
    self.baselayer.frame = CGRectMake(0, -self.frame.origin.y, self.frame.size.width, self.frame.origin.y+self.frame.size.height);
    self.sublayer.frame = CGRectMake(0, -self.frame.origin.y, self.frame.size.width, self.frame.origin.y+self.frame.size.height);
    self.imagelayer.frame = self.sublayer.frame;
    self.shadowlayer.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, MAX(self.shadowlayer.image.size.height,1));
    
    self.baselayer.backgroundColor = [UIColor whiteColor];
    
    return navigationBarSize;
}
- (UIView *)baselayer{
    if (_baselayer==nil) {
        _baselayer = [[UIView alloc]init];
        _baselayer.userInteractionEnabled = NO;
        _baselayer.tag = 10000;
        [self addSubview:_baselayer];
    }
    return _baselayer;
}

- (UIView *)sublayer{
    if (_sublayer==nil) {
        _sublayer = [[UIView alloc]init];
        _sublayer.userInteractionEnabled = NO;
        _sublayer.tag = 8000;
        [self addSubview:_sublayer];
    }
    return _sublayer;
}

- (UIImageView *)imagelayer{
    if (_imagelayer==nil) {
        _imagelayer = [[UIImageView alloc]init];
        _imagelayer.userInteractionEnabled = NO;
        _imagelayer.tag = 9000;
        [self addSubview:_imagelayer];
    }
    return _imagelayer;
}

- (UIImageView *)shadowlayer{
    if (_shadowlayer==nil) {
        _shadowlayer = [[UIImageView alloc]init];
        _shadowlayer.userInteractionEnabled = NO;
        _shadowlayer.tag = 7000;
        [self addSubview:_shadowlayer];
    }
    return _shadowlayer;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self sendSubviewToBack:self.imagelayer];
    [self sendSubviewToBack:self.sublayer];
    [self sendSubviewToBack:self.shadowlayer];
    [self sendSubviewToBack:self.baselayer];
    
}

- (void)drawRect:(CGRect)rect{
//    [super drawRect:rect];
//    if (self.translucent) {
//         self.backgroundColor = [UIColor clearColor];
//    }else{
//        self.backgroundColor = [UIColor whiteColor];
//    }
    self.backgroundColor = [UIColor clearColor];
    self.sublayer.backgroundColor = self.barTintColor;
    self.imagelayer.image = [self backgroundImageForBarPosition:self.barPosition barMetrics:UIBarMetricsDefault];
    self.shadowlayer.image = self.shadowImage;
    
    if (self.translucent) {
         self.baselayer.alpha = 0.f;
    }else{
         self.baselayer.alpha = self.sublayer.backgroundColor.alpha;
    }
   
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initSelfDefault];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSelfDefault];
    }
    return self;
}

- (void)initSelfDefault{
    self.clipsToBounds = NO;
    self.shadowImage = [UIImage imageForColor:[[UIColor grayColor] colorWithAlphaComponent:.5f] scale:[UIScreen mainScreen].scale size:CGSizeMake(1, 1)];
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
    }
    return self;
}
@end

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#pragma mark -

#undef	BUTTON_MIN_WIDTH
#define	BUTTON_MIN_WIDTH	(24.0f)

#undef	BUTTON_MIN_HEIGHT
#define	BUTTON_MIN_HEIGHT	(24.0f)

#pragma mark -

@interface UIViewController(UINavigationBarPrivate)
- (void)didLeftBarButtonTouched;
- (void)didRightBarButtonTouched;
@end

#pragma mark -

@implementation UIViewController(UINavigationBar)

@dynamic navigationBarShown;
@dynamic statusBarShown;

- (void)showStatusBarAnimated:(BOOL)animated{
    
//    if (IOS9_OR_LATER) {
//        HMUIBoard *vc = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
//        if ([vc respondsToSelector:@selector(setStatusBarHidden:)]) {
//            vc.statusBarHidden = NO;
//        }
//    }else{
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated?UIStatusBarAnimationNone:UIStatusBarAnimationSlide];
//    }
    HMUIBoard *vc = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([vc respondsToSelector:@selector(setStatusBarHidden:)]) {
        vc.statusBarHidden = NO;
    }
    vc = (HMUIBoard *)self;
    if ([vc respondsToSelector:@selector(setStatusBarHidden:)]) {
        vc.statusBarHidden = NO;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self postNotification:[HMUINavigationBar STATUS_CHANGED]];
}

- (void)hideStatusBarAnimated:(BOOL)animated{
//    if (IOS9_OR_LATER) {
//        HMUIBoard *vc = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
//        if ([vc respondsToSelector:@selector(setStatusBarHidden:)]) {
//            vc.statusBarHidden = YES;
//        }
//    }else{
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated?UIStatusBarAnimationNone:UIStatusBarAnimationSlide];
//    }
    HMUIBoard *vc = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([vc respondsToSelector:@selector(setStatusBarHidden:)]) {
        vc.statusBarHidden = YES;
    }
    vc = (HMUIBoard *)self;
    if ([vc respondsToSelector:@selector(setStatusBarHidden:)]) {
        vc.statusBarHidden = YES;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self postNotification:[HMUINavigationBar STATUS_CHANGED]];
}

- (BOOL)statusBarShown{
    HMUIBoard *vc = (HMUIBoard *)self;
    if ([vc respondsToSelector:@selector(setStatusBarHidden:)]) {
        return vc.statusBarHidden;
    }
    return ![UIApplication sharedApplication].isStatusBarHidden;
}

- (void)showNavigationBarAnimated:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)hideNavigationBarAnimated:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (BOOL)navigationBarShown
{
    return self.navigationController.navigationBarHidden ? NO : YES;
}
- (void)setNavigationBarShown:(BOOL)flag
{
    if ( [self isViewLoaded] && self.view.window )
    {
        if ( flag )
        {
            [self showNavigationBarAnimated:YES];
        }
        else
        {
            [self hideNavigationBarAnimated:YES];
        }
    }
    else
    {
        if ( flag )
        {
            [self showNavigationBarAnimated:NO];
        }
        else
        {
            [self hideNavigationBarAnimated:NO];
        }
    }
}

- (void)didLeftBarButtonTouched
{
    [self sendSignal:HMUINavigationBar.LEFT_TOUCHED];
}

- (void)didRightBarButtonTouched
{
    [self sendSignal:HMUINavigationBar.RIGHT_TOUCHED];
}

- (void)showBarButton:(NSInteger)position title:(NSString *)name
{
    if ( HMUINavigationBar.LEFT == position )
    {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:name
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(didLeftBarButtonTouched)] autorelease];
    }
    else if ( HMUINavigationBar.RIGHT == position )
    {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:name
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(didRightBarButtonTouched)] autorelease];
    }
}

- (void)showBarButton:(NSInteger)position image:(UIImage *)image
{
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width + 10.0f, self.navigationController.navigationBar.frame.size.height);
    
    if ( buttonFrame.size.width <= BUTTON_MIN_WIDTH )
    {
        buttonFrame.size.width = BUTTON_MIN_WIDTH;
    }
    
    if ( buttonFrame.size.height <= BUTTON_MIN_HEIGHT )
    {
        buttonFrame.size.height = BUTTON_MIN_HEIGHT;
    }
    
    UIButton * button = [[[UIButton alloc] initWithFrame:buttonFrame] autorelease];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.backgroundColor = [UIColor clearColor];
    
    if ( HMUINavigationBar.LEFT == position )
    {
        [button addTarget:self action:@selector(didLeftBarButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    }
    else if ( HMUINavigationBar.RIGHT == position )
    {
        [button addTarget:self action:@selector(didRightBarButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    }
}

- (void)showBarButton:(NSInteger)position image:(UIImage *)image image:(UIImage *)image2
{
    [self showBarButton:position image:[image merge:image2]];
}

- (void)showBarButton:(NSInteger)position title:(NSString *)title image:(UIImage *)image
{
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width + 10.0f, self.navigationController.navigationBar.frame.size.height);
    
    if ( buttonFrame.size.width <= BUTTON_MIN_WIDTH )
    {
        buttonFrame.size.width = BUTTON_MIN_WIDTH;
    }
    
    if ( buttonFrame.size.height <= BUTTON_MIN_HEIGHT )
    {
        buttonFrame.size.height = BUTTON_MIN_HEIGHT;
    }
    
    UIButton * button = [[[UIButton alloc] initWithFrame:buttonFrame] autorelease];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.backgroundColor = [UIColor clearColor];
    
    if ( HMUINavigationBar.LEFT == position )
    {
        [button addTarget:self action:@selector(didLeftBarButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    }
    else if ( HMUINavigationBar.RIGHT == position )
    {
        [button addTarget:self action:@selector(didRightBarButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    }
}

- (void)showBarButton:(NSInteger)position system:(UIBarButtonSystemItem)index
{
    if ( HMUINavigationBar.LEFT == position )
    {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:index
                                                                                               target:self
                                                                                               action:@selector(didLeftBarButtonTouched)] autorelease];
    }
    else if ( HMUINavigationBar.RIGHT == position )
    {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:index
                                                                                                target:self
                                                                                                action:@selector(didRightBarButtonTouched)] autorelease];
    }
}

- (void)showBarButton:(NSInteger)position custom:(UIView *)view
{
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:view] autorelease];
    if ( HMUINavigationBar.LEFT == position )
    {
        if (IOS7_OR_LATER) {
            UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                        target:self
                                                                                        action:nil]autorelease];
            flexSpacer.width = -10;
            [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:flexSpacer,item, nil]];
            
        }else{
            self.navigationItem.leftBarButtonItem = item;
        }
    }
    else if ( HMUINavigationBar.RIGHT == position )
    {
        if (IOS7_OR_LATER) {
            UIBarButtonItem *flexSpacer = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                        target:self
                                                                                        action:nil]autorelease];
            flexSpacer.width = -10;
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:flexSpacer,item, nil]];
            
        }else{
            self.navigationItem.rightBarButtonItem = item;
        }
    }
}

- (void)hideBarButton:(NSInteger)position
{
    if ( HMUINavigationBar.LEFT == position )
    {
        if (IOS7_OR_LATER) {
            self.navigationItem.leftBarButtonItems = nil;
        }else{
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    else if ( HMUINavigationBar.RIGHT == position )
    {
        if (IOS7_OR_LATER) {
            self.navigationItem.rightBarButtonItems = nil;
        }else{
            self.navigationItem.rightBarButtonItem = nil;
        }
        
    }
}

- (id)navigateBarCustomView:(NSInteger)position{
    if ( HMUINavigationBar.LEFT == position )
    {
        if (IOS7_OR_LATER) {
            return [(UIBarButtonItem*)self.navigationItem.leftBarButtonItems.lastObject customView];
        }else{
            return [(UIBarButtonItem*)self.navigationItem.leftBarButtonItems.firstObject customView];
        }
    }
    else if ( HMUINavigationBar.RIGHT == position )
    {
        if (IOS7_OR_LATER) {
            return [(UIBarButtonItem*)self.navigationItem.rightBarButtonItems.lastObject customView];
        }else{
            return [(UIBarButtonItem*)self.navigationItem.rightBarButtonItems.firstObject customView];
        }
    }
    return nil;
}

- (UINavigationBar *)navigatorBar{
    return self.navigationController.navigationBar;
}

- (void)setNavigationBarTranslucent:(BOOL)translucent{
    
    self.navigatorBar.translucent = translucent;
    
}

- (void)setNavigationBarOriginalColor:(UIColor *)defaultNavigationBarOriginalColor{
    
    UIImage *transparentBackground = [UIImage imageForColor:defaultNavigationBarOriginalColor scale:[UIScreen mainScreen].scale size:CGSizeMake(1, 1)];
    
    //    [self setDefaultNavigationBarColor:defaultNavigationBarOriginalColor];
    [self setNavigationBarBackgroundImage:transparentBackground];
    [self setNavigationBarTranslucent:NO];
}

- (void)setNavigationBarOriginalColor:(UIColor *)color noShadow:(BOOL)noShadow{
    [self setNavigationBarBackgroundColor:color];
    [self setNavigationBarTranslucent:NO];
    if (noShadow) {
        [self setNavigationBarShadowImage:nil];
    }
//    [self setNavigationBarBackgroundImage:nil];
}

- (void)setNavigationBarShadowImage:(UIImage *)shadowImage{
    if (shadowImage==nil) {
        shadowImage = [[UIImage new] autorelease];
    }
    self.navigatorBar.shadowImage = shadowImage;
}

- (void)setNavigationBarBackgroundColor:(UIColor *)color{
    self.navigatorBar.barTintColor = color;
}

- (void)setNavigationBarTitleColor:(UIColor *)color{

    NSMutableDictionary * attrs = nil;
    if (color) {
        attrs = [NSMutableDictionary dictionaryWithDictionary:self.navigatorBar.titleTextAttributes];
        [attrs setObject:color forKey:NSForegroundColorAttributeName];
        
    }
    [self.navigatorBar setTitleTextAttributes:attrs];
}

- (void)setNavigationBarTitleFont:(UIFont *)font{
    NSMutableDictionary * attrs = nil;
    if (font) {
        attrs = [NSMutableDictionary dictionaryWithDictionary:self.navigatorBar.titleTextAttributes];
        [attrs setObject:font forKey:NSFontAttributeName];
        
    }
    [self.navigatorBar setTitleTextAttributes:attrs];
}

- (void)setNavigationBarBackgroundImage:(UIImage *)image{
    if (image==nil) {
        image = [[UIImage new] autorelease];
    }
    [self.navigatorBar setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
}

- (void)statusBarTurnDark{

    HMUIBoard* vc = (id)self;
    if ([vc isKindOfClass:[HMUIBoard class]]) {
        [(HMUIBoard *)vc setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)statusBarTurnLight{
    
    HMUIBoard* vc = (id)self;
    if ([vc isKindOfClass:[HMUIBoard class]]) {
        [(HMUIBoard *)vc setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIActivityIndicatorView *)showTitleActivity:(BOOL)action{
    UILabel *labelTitle = (UILabel*)self.navigationItem.titleView;
    if (labelTitle==nil) {
        labelTitle = (id)self.navigatorBar;
    }
    
    UIActivityIndicatorView *activity = (id)[labelTitle viewWithTag:120120];
    if (activity==nil) {
        activity = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        activity.x = (labelTitle.width-activity.width)/2;;
        activity.y = (labelTitle.height-activity.height)/2;
        activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [labelTitle addSubview:activity];
        activity.tag = 120120;
    }
    
    if (action) {
        [activity startAnimating];
        activity.hidden = NO;
    }else{
        [activity stopAnimating];
        activity.hidden = YES;
    }
    return activity;
    return nil;
}

- (void)customNavTitleView:(UIView *)title{
    self.navigationItem.titleView = title;
}
- (UIView *)customNavTitleView{
    return self.navigationItem.titleView;
}

- (UIButten *)customNavRightBtn{
    UIButten *rightBtn = [self navigateBarCustomView:HMUINavigationBar.RIGHT];
    if (![rightBtn isKindOfClass:[UIButten class]]||![rightBtn.tagString isEqual:@"rightBtn"]) {
        rightBtn = [[UIButten alloc]init];
        rightBtn.tagString = @"rightBtn";
        rightBtn.eventReceiver = self;
        [self showBarButton:HMUINavigationBar.RIGHT custom:rightBtn];
        [rightBtn release];
    }
    return rightBtn;
}

- (UIButten *)customNavLeftBtn{
    UIButten *leftBtn = [self navigateBarCustomView:HMUINavigationBar.LEFT];
    if (![leftBtn isKindOfClass:[UIButten class]]||![leftBtn.tagString isEqual:@"leftBtn"]) {
        leftBtn = [[UIButten alloc]init];
        leftBtn.tagString = @"leftBtn";
        leftBtn.eventReceiver = self;
        [self showBarButton:HMUINavigationBar.LEFT custom:leftBtn];
        [leftBtn release];
    }
    return leftBtn;
}

- (void)setCustomNavLeftView:(UIView*)view{
    [self showBarButton:HMUINavigationBar.LEFT custom:view];
}

- (UIView *)customNavLeftView{
    return [self navigateBarCustomView:HMUINavigationBar.LEFT];
}

- (void)setCustomNavRightView:(UIView*)view{
    [self showBarButton:HMUINavigationBar.RIGHT custom:view];
}

- (UIView *)customNavRightView{
    return [self navigateBarCustomView:HMUINavigationBar.RIGHT];
}

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)