//
//  HMUIStack.m
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMViewCategory.h"
#import "HMMacros.h"
#import "HMFoundation.h"


#undef	UNUSED
#define UNUSED( __x )	(void)(__x)

@implementation UINavigationController (HMUIStackNavigation)

- (void)updateNavigationBar{
    UINavigationBar *bar = self.navigationBar;
    bar.barTintColor = [HMUIConfig sharedInstance].defaultNavigationBarColor;
    
   [bar setBackgroundImage:[HMUIConfig sharedInstance].defaultNavigationBarImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    
    if ([HMUIConfig sharedInstance].defaultNavigationTitleColor) {
        
        [attrs setValue:[HMUIConfig sharedInstance].defaultNavigationTitleColor forKey:NSForegroundColorAttributeName];
    }
    
    if ([HMUIConfig sharedInstance].defaultNavigationTitleFont) {
        
        [attrs setValue:[HMUIConfig sharedInstance].defaultNavigationTitleFont forKey:NSFontAttributeName];
    }
    
    if ([HMUIConfig sharedInstance].defaultNavigationBarShadowImage) {
        
        [bar setShadowImage:[HMUIConfig sharedInstance].defaultNavigationBarShadowImage];
    }
    
    [bar setTitleTextAttributes:attrs];
    
    [bar setTranslucent:[HMUIConfig sharedInstance].defaultNavigationBarTranslucent];
}

//// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ( self.topViewController )
	{
		return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
	}
	return YES;
}

#if defined(__IPHONE_6_0)

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (self.topViewController) {
        return [self.topViewController preferredInterfaceOrientationForPresentation];
    }
    return UIInterfaceOrientationPortrait;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{

//	return UIInterfaceOrientationMaskAll;
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    if (self.topViewController) {
       return [self.topViewController shouldAutorotate];
    }
    return YES;
}

#endif	// #if defined(__IPHONE_6_0)


@end

@interface HMUIStack ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation HMUIStack

- (void)dealloc
{
    HM_SUPER_DEALLOC();
}
- (NSArray *)boards
{
	NSMutableArray * array = [NSMutableArray nonRetainingArray];
	
	for ( UIViewController * controller in self.viewControllers )
	{
		if ( [controller isKindOfClass:[HMUIBoard class]] )
		{
			[array addObject:controller];
		}
	}
	
	return array;
}

- (HMUIBoard *)topBoard
{
	UIViewController * controller = self.topViewController;
	if ( controller && [controller isKindOfClass:[HMUIBoard class]] )
	{
		HMUIBoard * board = (HMUIBoard *)controller;
		UNUSED( board.view ); // force to load
		return board;
	}
	else
	{
		return nil;
	}
}

- (instancetype)initCustomBarWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithNavigationBarClass:[HMUINavigationBar class] toolbarClass:nil];
    if (self) {
        [self pushViewController:rootViewController animated:NO];
        [self load];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        [self load];
    }
    return self;
}

//- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
//    self = [super initWithRootViewController:rootViewController];
//    if (self) {
//        [self load];
//    }
//    return self;
//}

//- (id)init
//{
//    self = [super init];
//	
//	if ( self )
//	{
//		[self load];
//	}
//	return self;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self load];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (IOS7_OR_LATER) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        {
            self.interactivePopGestureRecognizer.delegate = self;
            self.delegate = self;
//            if ([HMUIConfig sharedInstance].allowControlerGestureBack)
//            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadView
{
    
	[super loadView];
    [self updateNavigationBar];
}


- (void)setTitle:(NSString *)title{
    [super setTitle:title];
    if ( self.topViewController && [self.topViewController isKindOfClass:[HMUIBoard class]] )
    {
        HMUIBoard * board = (HMUIBoard *)self.topViewController;
        [board setTitle:title];
    }
}
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
    didShowViewController:(UIViewController *)viewController
                 animated:(BOOL)animate
{

    if ([HMUIConfig sharedInstance].allowControlerGestureBack) {
        if (self.viewControllers.count>1) {
            [HMUIConfig sharedInstance].allowControlerGestureAutoControl = NO;
        }else{
            [HMUIConfig sharedInstance].allowControlerGestureAutoControl = YES;
        }
    }
    
}
#pragma mark -
//override style for ios7
-(BOOL)prefersStatusBarHidden{
    if ( self.topViewController )
	{
		return [self.topViewController prefersStatusBarHidden];
	}
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.topViewController) {
        return [self.topViewController preferredStatusBarStyle];
    }
    return [HMUIConfig sharedInstance].statusBarStyle;
}


#endif	// #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000


@end
