//
//  HMUIBoard.m
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIBoard.h"
#import "HMURLMap.h"

@implementation PresentWindow{
    UIWindow *_window;
}
DEF_SINGLETON(PresentWindow);
@synthesize mainWindow;
@synthesize window=_window;

- (instancetype)init
{
    self = [super init];
    if (self) {
        @synchronized(_window){
            if ( nil == _window )
            {
                _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                _window.hidden = YES;
                _window.windowLevel = UIWindowLevelNormal+1;
                _window.rootViewController = [[[UIViewController alloc]init]autorelease];
            }
        }
        
    }
    return self;
}


+ (UIViewController*)rootViewController{
    return [PresentWindow sharedInstance].window.rootViewController;
}

+ (void)makeKeyWindow{
    
    if ([PresentWindow sharedInstance].window.hidden) {
        [PresentWindow sharedInstance].window.hidden = NO;
    }
    [PresentWindow sharedInstance].mainWindow = [UIApplication sharedApplication].keyWindow;
    [[PresentWindow sharedInstance].window makeKeyAndVisible];
}

+ (void)resignKeyWindow:(BOOL)animated{
    if (![PresentWindow sharedInstance].window.hidden) {
        if (animated) {
            [self delay:.25f invoke:^(){
                [PresentWindow sharedInstance].window.hidden = YES;
            }];
        }else{
            [PresentWindow sharedInstance].window.hidden = YES;
        }
        
    }
    [[PresentWindow sharedInstance].mainWindow makeKeyWindow];
}

@end


@interface HMUIBoard ()

@end

UIImage * defalutBackgroundImage;
UIColor * defalutBackgroundColor;

@implementation HMUIBoard{
    
    BOOL                        _viewBuilt;
//    UIStatusBarStyle            _statusBarStyle;
    BOOL                        _statusBarHidden;
    
    BOOL                        _allowedPortrait;
    BOOL                        _allowedLandscape;
}
DEF_SIGNAL2( ORIENTATION_WILL_CHANGE ,HMUIBoard)
DEF_SIGNAL2( ORIENTATION_DID_CHANGED ,HMUIBoard)

@synthesize allowedPortrait = _allowedPortrait;
@synthesize allowedLandscape = _allowedLandscape;
@synthesize statusBarStyle = _statusBarStyle;
@synthesize statusBarHidden = _statusBarHidden;
@synthesize tableView=_tableView;
@synthesize allowedLandscapeRight=_allowedLandscapeRight;
@synthesize allowedPortraitUpside = _allowedPortraitUpside;

+ (void)setDefaultBackgroundImage:(UIImage *)image{
    if (defalutBackgroundImage) {
        [defalutBackgroundImage release];
    }
    defalutBackgroundImage = [image retain];
}

+ (void)setDefaultBackgroundColor:(UIColor *)color{
    if (defalutBackgroundColor) {
        [defalutBackgroundColor release];
    }
    defalutBackgroundColor = [color retain];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initSelf];
    }
    return self;
}


- (id)init
{
    self = [super init];
    if ( self )
    {
        [self initSelf];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initSelf];
}

- (void)initSelf{
    _viewBuilt = NO;
    self.statusBarStyle = [HMUIConfig sharedInstance].statusBarStyle;
    self.allowedLandscape = [HMUIConfig sharedInstance].allowedLandscape;
    self.allowedPortrait = [HMUIConfig sharedInstance].allowedPortrait;
    self.allowedLandscapeRight = [HMUIConfig sharedInstance].allowedLandscapeRight;
    self.allowedPortraitUpside = [HMUIConfig sharedInstance].allowedPortraitUpside;
    self.includesOpaque = [HMUIConfig sharedInstance].includesOpaque;
    
//    if ([HMUIConfig sharedInstance].defaultNavigationTitleFont!=nil)
//    [self setNavigationBarTitleFont:[HMUIConfig sharedInstance].defaultNavigationTitleFont];
//    
//    if ([HMUIConfig sharedInstance].defaultNavigationTitleColor!=nil)
//    [self setNavigationBarTitleColor:[HMUIConfig sharedInstance].defaultNavigationTitleColor];
//    
//    if ([HMUIConfig sharedInstance].defaultNavigationBarColor!=nil)
//    [self setNavigationBarBackgroundColor:[HMUIConfig sharedInstance].defaultNavigationBarColor];
//    
//    if ([HMUIConfig sharedInstance].defaultNavigationBarShadowImage!=nil)
//    [self setNavigationBarShadowImage:[HMUIConfig sharedInstance].defaultNavigationBarShadowImage];
//    
//    if ([HMUIConfig sharedInstance].defaultNavigationBarImage!=nil)
//    [self setNavigationBarBackgroundImage:[HMUIConfig sharedInstance].defaultNavigationBarImage];
//    
//    [self setNavigationBarTranslucent:[HMUIConfig sharedInstance].defaultNavigationBarTranslucent];
//    
//    if ([HMUIConfig sharedInstance].defaultNavigationBarOriginalColor!=nil)
//        [self setNavigationBarOriginalColor:[HMUIConfig sharedInstance].defaultNavigationBarOriginalColor noShadow:NO];
    
    [self load];
}
- (void)dealloc
{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"UIBoard",@"%@>>>>>>>>>>>>>>out",[self class]);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    
    [_tableView release];
    _tableView = nil;
    self.nickname = nil;
    [self cancelAndDisableDial:[HMWebAPI WebAPI] byResponder:self];
    [self unload];
    HM_SUPER_DEALLOC();
}

- (void)load{
    
}

- (void)unload{
    self.urlMap = nil;
    self.parentBoard = nil;
}

- (void)viewDidLayoutSubviews{
    
}

- (UITableView *)tableView{
    if (_tableView==nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)loadView{
    [super loadView];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        if ( !self.includesOpaque)
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        else
        {
            self.edgesForExtendedLayout = UIRectEdgeAll;
            self.extendedLayoutIncludesOpaqueBars = YES;
            self.modalPresentationCapturesStatusBarAppearance = YES;
        }
        [self setNeedsStatusBarAppearanceUpdate];
    }
   
#endif	// #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewBuilt = YES;
    if (defalutBackgroundImage) {
        self.view.backgroundImage = defalutBackgroundImage;
    }
    if (defalutBackgroundColor) {
        self.view.backgroundColor = defalutBackgroundColor;
    }else{
         self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_tableView.dataSource==nil) {
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"UIBoard",@"%@>>Appear>visable:%@",[self class],self.viewVisable?@"true":@"false");
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"UIBoard",@"%@>>Disappear>visable:%@",[self class],self.viewVisable?@"true":@"false");
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//override style for ios7
-(BOOL)prefersStatusBarHidden{
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"UIBoard",@"%@>>prefersStatusBarHidden>:%@",[self class],self.statusBarHidden?@"true":@"false");
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    return self.statusBarHidden;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
//#if (__ON__ == __HM_DEVELOPMENT__)
//    CC( @"UIBoard",@"%@>>preferredStatusBarStyle>:%@",[self class],self.statusBarStyle?@"UIStatusBarStyleLightContent":@"UIStatusBarStyleDefault");
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    return self.statusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}


//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    if ( _viewBuilt )
//    {
////        [self sendSignal:HMUIBoard.ORIENTATION_WILL_CHANGE];
//    }
//}
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    if ( _viewBuilt )
//    {
////        [self sendSignal:HMUIBoard.ORIENTATION_WILL_CHANGE];
//    }
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    if ( _viewBuilt )
//    {
////        [self sendSignal:HMUIBoard.ORIENTATION_DID_CHANGED];
//    }
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
//    
//}

#if defined(__IPHONE_6_0)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSUInteger orientation = UIInterfaceOrientationMaskPortrait;
    
    if ( _allowedPortrait )
    {
        orientation |= UIInterfaceOrientationMaskPortrait;
    }
    
    if (_allowedPortraitUpside) {
        orientation |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    if ( _allowedLandscape )
    {
        orientation |= UIInterfaceOrientationMaskLandscape;
    }
    
    if (!_allowedLandscapeRight) {
        orientation &= ~UIInterfaceOrientationLandscapeRight;
    }
    
    return orientation;
}

- (BOOL)shouldAutorotate
{
    
    if ( !_allowedLandscape||!_allowedPortrait)
    {
        if ((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)&&_allowedLandscape)||(UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)&&_allowedPortrait)) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

#endif	// #if defined(__IPHONE_6_0)

//- (NSString *)description{
//    if (self.name==nil) {
//        return [super description];
//    }
//    return [NSString stringWithFormat:@"%@{%@}",[super description],self.name];
//}

#pragma mark -


#pragma  mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"listCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell= [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
